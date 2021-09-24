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
    create_for(record: record) if update.nil?
    update_for(record: record) unless update.nil?
    
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
      if work.singularize.classify.constantize.where(identifier: record.identifier).empty?
        info_stream << 'Creating record: ' \
                      "#{record.respond_to?(:title) ? record.title : record}"
        created    = import_type.new
        attributes = record.attributes
        attributes[:uploaded_files] = [file_for(record.representative_file)] if record.representative_file
        embargo_attributes(attributes, record)

        attributes = attributes.merge(member_of_collections_attributes: { '0' => { id: collection.first.id } }) unless collection.empty?
        
        actor_env = Hyrax::Actors::Environment.new(created,
                                                  ::Ability.new(creator),
                                                  attributes)
        
        Hyrax::CurationConcern.actor.create(actor_env)
        
        info_stream << "\nRecord created at: #{created.id} \n"
        
      else  
        info_stream << "\nRecord exist: #{record.respond_to?(:title) ? record.title : record}\n"
      end
      rescue Errno::ENOENT => e
          error_stream << e.message
    end

    def update_for(record:)
      gw = work.singularize.classify.constantize.where(identifier: record.identifier)
      if !gw.empty? && record.respond_to?(:identifier)
        gw = gw.first
        attrs = record.attributes  
        attrs.delete(:identifier)
        attrs.each do |key, val|
          gw.send("#{key}=",val)
        end
        gw.save

        if record.representative_file
          gw.file_set_ids.each do |fsid|
            FileSet.find(fsid).destroy
          end
          record.representative_file.each do |f|
            replace_file_set(f, gw)
          end  
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
end
