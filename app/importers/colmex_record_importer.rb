# frozen_string_literal: true

##
# A `Darlingtonia::RecordImporter` that processes files and passes new works
# through the Actor Stack for creation.
class ColmexRecordImporter < Darlingtonia::RecordImporter
  ##
  # @!attribute [rw] creator
  #   @return [User]
  # @!attribute [rw] file_path
  #   @return [String]
  attr_accessor :creator, :file_path, :work, :collection, :update

  ##
  # @param file_path [String]
  # @param creator   [User]
  def initialize(**opts)
    self.creator   = opts.delete(:creator)   || raise(ArgumentError)
    self.file_path = opts.delete(:file_path) || raise(ArgumentError)
    self.work = opts.delete(:work) || raise(ArgumentError)
    self.collection = Collection.where(title: opts.delete(:collection) || raise(ArgumentError))
    self.update = opts.respond_to?(:update) ?  opts.delete(:update) : nil
    super
  end

  def import(record:)
    return create_for(record: record) if update.nil?
    return update_for(record: record) unless update.nil?

  rescue Faraday::ConnectionFailed, Ldp::HttpError => e
    error_stream << e
  rescue RuntimeError => e
    error_stream << e
    raise e

  end

  private

    ##
    # @private
    def embargo_attributes(attributes, record)
      if record.respond_to?(:embargo_release_date)
        date = record.embargo_release_date.first
        # records with an embargo Magic date of 9999-12-31
        # are meant to be private, but NOT embargoed.
        if Date.parse(date) < Date.parse('9999-12-31 00:00')
          attributes[:visibility_during_embargo] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          attributes[:embargo_release_date] = date
          attributes[:visibility_after_embargo] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          attributes[:visibility_during_lease] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          attributes[:lease_expiration_date] = date
          attributes[:visibility_after_lease] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          # Hyrax expects visibility to be "embargo"
          attributes[:visibility] = "embargo"
        end
      else
        # no embargo, and visibility AccessControls are public
        attributes[:visibility] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end
    end

    def create_for(record:)
      begin
        results = work.singularize.classify.constantize.where(identifier: record.identifier).select do |row|
          row.identifier == record.identifier
        end
        if results.empty?
          info_stream << 'Creating record: ' \
                        "#{record.respond_to?(:title) ? record.title : record}"
          created    = import_type.new
          attributes = record.attributes
          attributes[:uploaded_files] = [file_for(record.representative_file)] if record.representative_file

          embargo_attributes(attributes, record)
          locations = get_genomanes_data(attributes[:based_near]) if attributes.key? :based_near

          attributes = attributes.merge(member_of_collections_attributes: { '0' => { id: collection.first.id } }) unless collection.empty?

          actor_env = Hyrax::Actors::Environment.new(created,
                                                    ::Ability.new(creator),
                                                    attributes)

          Hyrax::CurationConcern.actor.create(actor_env)

          unless locations.nil?
            w = created.class.find(created.id)
            w.based_near = locations
            w.save!
          end

          info_stream << "\nRecord created at: #{created.id} \n"
          created.class.find(created.id).file_set_ids.each do |f_id|
            access_file_set(f_id,attributes[:item_access_restrictions].to_s)
          end
          return [record.identifier, "Importado exitosamente"]
        else
          info_stream << "\nRecord exist: #{record.respond_to?(:title) ? record.title : record}\n"
          return [record.identifier, "El identificador ya existe en el sistema"]

        end
      rescue  => e
          return [record.identifier, "Error: #{e.to_s}"]
      end
    end

    def update_for(record:)
      
      results = work.singularize.classify.constantize.where(identifier: record.identifier).select do |row|
        row.identifier == record.identifier
      end

      if not results.empty? && record.respond_to?(:identifier)
        gw = results.first
        
        # Capturar estado original desde persistencia (evita valores ya modificados en memoria)
        persisted_gw = gw.class.find(gw.id)
        original_record = capture_work_metadata(persisted_gw)
        
        attrs = record.attributes
        attrs.delete(:identifier)
        
        # Guardar qué campos vienen en el CSV (incluso si están vacíos)
        csv_fields = attrs.keys
        
        attrs.each do |key, val|
          gw.send("#{key}=",val)
        end


        locations = get_genomanes_data(attrs[:based_near]) if attrs.key? :based_near
        gw.based_near = locations unless locations.nil?
        gw.save

        if record.representative_file
          gw.file_set_ids.each do |fsid|
            FileSet.find(fsid).destroy
          end
          record.representative_file.each do |f|
            replace_file_set(f, gw)
          end
        end
        
        # Log changes to RecordChangeLog
        updated_record = capture_work_metadata(gw)
        changes = get_metadata_changes(original_record, updated_record, csv_fields)
        
        gw.file_set_ids.each do |f_id|
          access_file_set(f_id,attrs[:item_access_restrictions])
          if attrs[:item_access_restrictions].nil? then
            gw.item_access_restrictions = []
            gw.save
          end
        end

        info_stream << "\n[DEBUG] Campos a comparar: #{csv_fields.inspect}"
        info_stream << "\n[DEBUG] Cambios detectados: #{changes.inspect}"
        info_stream << "\n[DEBUG] Cambios vacíos?: #{changes.empty?}"
        
        unless changes.empty?
          begin
            log_entry = RecordChangeLog.new(
              change: changes.to_json,
              user_id: creator.id,
              template: gw.has_model.first,
              record_id: gw.id,
              identifier: record.identifier
            )
            info_stream << "\n[DEBUG] Log entry creado: user_id=#{creator.id}, template=#{gw.has_model.first}, record_id=#{gw.id}"
            if log_entry.save
              info_stream << "\n[LOG] Cambios guardados en RecordChangeLog para #{record.identifier}"
            else
              info_stream << "\n[ERROR] No se pudo guardar log: #{log_entry.errors.full_messages.join(', ')}"
            end
          rescue => e
            info_stream << "\n[ERROR] Exception al guardar log: #{e.message}\n#{e.backtrace.first(3).join("\n")}"
          end
        else
          info_stream << "\n[DEBUG] No se detectaron cambios para registrar"
        end

        info_stream << "\nRecord #{record.identifier} is updated"
      else
        info_stream << "\nRecord #{record.identifier} fail to update"
      end
    end

    def file_for(filenames)
      ids = []
      filenames.each do |filename|
        fileset = Hyrax::UploadedFile.create(file: File.open(file_path + filename), user: creator)
        ids.push  fileset.id
      end
      return ids
    end

    def import_type
      raise 'No curation_concern found for import' unless
        defined?(Hyrax) && Hyrax&.config&.curation_concerns&.any?

      Hyrax.config.curation_concerns.each_with_index do |tw, i|

        if tw.name == work
          return Hyrax.config.curation_concerns[i]
        end
      end
    end

    def access_file_set(f_id, permit)
      fs = FileSet.find f_id
      original_visibility = fs.visibility
      
      if permit != [] && !permit.nil? then
        fs.visibility = "restricted"
      else
        fs.visibility = "open"
      end

      fs.save
      
      # Log visibility changes for FileSet
      if original_visibility != fs.visibility
        work_id = fs.try(:parent)&.id
        changes = {
          file_set: "#{fs.id} - #{fs.label}",
          visibility: {
            before: original_visibility,
            after: fs.visibility
          }
        }
        
        RecordChangeLog.create(
          change: changes.to_json,
          user_id: creator.id,
          template: fs.class.name,
          record_id: work_id,
          identifier: fs.id
        )
      end
    end

    def get_genomanes_data(based_near)
      locations = []
      based_near.each do |bn|
        locations.push Hyrax::ControlledVocabularies::Location.new(::RDF::URI(bn))
      end
      return locations
    end

    def replace_file_set(f, gw)
      now = Time.now
      file = Hyrax::UploadedFile.create(file: File.open(file_path + f), user: creator)
      file_set = ::FileSet.new(depositor: creator.user_key,
                               date_uploaded: now,
                               date_modified: now,
                               creator: [creator.user_key])
      file_actor = ::Hyrax::Actors::FileSetActor.new(file_set, creator)
      file_actor.create_content(file)
      file_actor.attach_to_work(gw)
    end

    def capture_work_metadata(work)
      metadata = {}
      
      # Capturar todos los campos definidos en el modelo
      work.class.properties.keys.each do |field|
        next if ['has_model', 'create_date', 'modified_date'].include?(field)
        begin
          value = work.send(field)
          # Mantener el tipo original: arrays como arrays, strings como strings, etc.
          metadata[field] = value
        rescue
          metadata[field] = nil
        end
      end
      
      # Agregar visibilidad
      metadata['visibility'] = work.visibility
      
      metadata
    end
    
    def get_metadata_changes(original_record, updated_record, changed_fields)
      updated_fields = {}
      
      # Solo comparar los campos que se actualizaron en el CSV
      changed_fields.each do |field|
        field_str = field.to_s
        
        # Asegurar que capturamos el valor incluso si no está en original_record
        original_value = normalize_value(original_record[field_str])
        updated_value = normalize_value(updated_record[field_str])
        
        # Debug para ver valores originales vs nuevos
        info_stream << "\n[DEBUG] Campo #{field_str}: before=#{original_value.inspect} after=#{updated_value.inspect}"
        
        # Detectar cambios incluyendo cuando se vacía un campo ([] o nil o "")
        original_empty = value_empty?(original_value)
        updated_empty = value_empty?(updated_value)
        
        if original_value != updated_value || (original_empty != updated_empty)
          updated_fields[field_str] = {
            before: original_value,
            after: updated_value
          }
        end
      end
      
      # Comparar visibilidad siempre
      if original_record['visibility'] != updated_record['visibility']
        updated_fields['visibility'] = {
          before: original_record['visibility'],
          after: updated_record['visibility']
        }
      end
      
      updated_fields
    end
    
    def value_empty?(value)
      value.nil? || value == [] || value == ""
    end
    
    def normalize_value(value)
      return nil if value.nil?
      return [] if value == []
      
      # Si es un array, normalizar cada elemento
      if value.is_a?(Array)
        return value.map { |v| v.to_s.strip }.sort
      end
      
      # Si es string, limpiar espacios
      value.is_a?(String) ? value.strip : value
    end
end
