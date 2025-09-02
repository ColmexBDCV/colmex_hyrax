require 'set'

module ImporterService
  METADATA_FIELDS_TO_IGNORE = [:file_name, :messagedigest].freeze

    def name_sip(sip)
        i = Import.where(name:sip).where(status: "Procesado")
        return true if i.count > 0
    end

    def get_qa()
        { licenses: get_licenses,
          rights: get_rights_statements,
          types: get_types_conacyt,
          pub: get_pub_conacyt
        }
    end

    def get_size_sip(sip)
        size_b = Dir.glob("digital_objects/#{sip}/**/*").select { |f| File.file?(f) }.sum { |f| File.size(f) }
        size_m = size_b.to_f / (1024 * 1024)
        size_m.round(2)
    end

    def list_sips
        list_folders("digital_objects").map { |sip| { sip: sip, size: get_size_sip(sip)}}
    end

    def get_pub_conacyt
        [   "administrators",
            "beneficiariesFundsFederalAppli",
            "librarians",
            "counsellors",
            "companies",
            "students",
            "communityGroups",
            "researchers",
            "teachers",
            "newsMedia",
            "other",
            "parentsAndFamilies",
            "schoolSupportStaff",
            "legislators",
            "studentFinancialAidProviders",
            "generalPublic"
        ]
    end

    def metadata_exists?(sip)
        File.exists?("digital_objects/#{sip}/metadatos/metadatos.csv")
    end

    def documents_exists?(sip)
        File.directory?("digital_objects/#{sip}/documentos_de_acceso") && Dir.entries("digital_objects/#{sip}/documentos_de_acceso").count > 0
    end

    def list_folders(folder)
        Dir.entries(folder).select {|entry| File.directory? File.join(folder,entry) and !(entry =='.' || entry == '..') }
    end

    def get_licenses
        license_service = Hyrax.config.license_service_class.new
        license_service.select_active_options.map { |e| e[1] }
    end

    def get_rights_statements
        rights_statement_service = Hyrax.config.rights_statement_service_class.new
        rights_statement_service.select_active_options.map { |e| e[1] }
    end

    def get_resource_types
        file_path = Rails.root.join('config', 'authorities', 'resource_types.yml')

        # Carga y parsea el archivo YAML
        resource_types = YAML.load_file(file_path)
        types = Array.new()
        # Extrae y muestra los términos
        resource_types['terms'].each do |term|
            types.push term['term']
        end
        return types

    end

    def get_types_conacyt
        [
            "info:eu-repo/semantics/article",
            "info:eu-repo/semantics/bachelorThesis",
            "info:eu-repo/semantics/masterThesis",
            "info:eu-repo/semantics/doctoralThesis",
            "info:eu-repo/semantics/book",
            "info:eu-repo/semantics/bookPart",
            "info:eu-repo/semantics/review",
            "info:eu-repo/semantics/conferenceObject",
            "info:eu-repo/semantics/lecture",
            "info:eu-repo/semantics/workingPaper",
            "info:eu-repo/semantics/preprint",
            "info:eu-repo/semantics/report",
            "info:eu-repo/semantics/annotation",
            "info:eu-repo/semantics/contributionToPeriodical",
            "info:eu-repo/semantics/patent",
            "info:eu-repo/semantics/other",
        ]
    end

    def parse_errors(errors)
        result = []
        errors.to_a.each do |e|
            result << e[:description]
        end
        return result
    end

    def validate_date_created(record, index)
        return nil unless record.respond_to?("date_created")
        unless check_date(record.date_created)
            return [index + 2, record.date_created]
        end
        nil
    end

    def get_bad_fields(headers, work_type)
      work_instance = work_type.new
      (headers.reject { |h| work_instance.respond_to?(h) }) - METADATA_FIELDS_TO_IGNORE
    end

    def validate_files_and_duplicates(records, headers, sip, work)
        errors = {}
        files_csv = records.map { |r| r.representative_file }.flatten.compact
        identifiers = records.map { |r| r.identifier if r.respond_to? :identifier}
        i_d = (identifiers.select { |i| identifiers.count(i) > 1 }).to_set.to_a
        files_folder = Dir["digital_objects/#{sip}/documentos_de_acceso/*"].map { |f| f.gsub("digital_objects/", '') }
        identifiers.each_with_index do |identifier, index|
            if i_d.include?(identifier) && headers.include?(:identifier)
                errors["El identifier #{identifier} se encuentra duplicado en las siguientes filas"] = (errors["El identifier #{identifier} se encuentra duplicado en las siguientes filas"] || []) << index + 2
            end
        end
        unless (files_csv - files_folder).empty?
            errors["No se encuentran los archivos referenciados, favor de verificar que existan en la carpeta documentos_de_acceso y los nombres sean exactamente iguales"] = files_csv - files_folder
        end
        unless (files_folder - files_csv).empty?
            errors["Los siguientes archivos no tienen registros asociados a ellos en el campo file_name dentro del CSV"] = files_folder - files_csv
        end
        wt = work.singularize.classify.constantize
        bad_fields = get_bad_fields(headers, wt)
        if bad_fields.count > 0
            errors["Los siguientes campos utilizados, no corresponden a la plantilla seleccionada (#{t('hyrax.admin.validations.'+work.underscore.downcase)})"] = bad_fields
        end
        errors
    end

    # report = ImporterService.validate_csv("TesisColmexMarzo2022","Video", true)
    def validate_csv(sip, work, repnal = false)

        return { Error: "No existe carpeta metadatos o archivo de metadatos.csv no existe"} unless metadata_exists?(sip)
        return { Error: "No existe carpeta documentos_de_acceso o está esta vacia"} unless documents_exists?(sip)

        parser = ColmexCsvParser.new(file: File.open("digital_objects/#{sip}/metadatos/metadatos.csv"), work: work)

        unless parser.validate then
            return { Error: "El archivo metadatos.csv es invalido y no lo puede ser interpretado, una de las causas comunes es que existan columnas vacias o columnas sin nombre del campo. SYSTEM_LOG: #{parse_errors(parser.errors).to_s}" }
        end

        begin

            records = Importer.new(parser: parser, work: work).records.to_a
            csv = CSV.table("digital_objects/#{sip}/metadatos/metadatos.csv", {:headers => :first_row, :liberal_parsing=> true})
        rescue Exception => e
            return { Error: "El archivo metadatos.csv es invalido y no lo puede ser interpretado, una de las causas comunes es que existan columnas vacias o columnas sin nombre del campo, SYSTEM_LOG: #{e}"}
        end

        context = build_validation_context(work, repnal)

        headers = csv.headers

        # unless headers.include?(:identifier)  then
        #     return {Error: "El campo identifier no se encuentra definido en los metadatos"}
        # end

        # unless headers.include?(:title)  then
        #     return {Error: "El campo title no se encuentra definido en los metadatos"}
        # end

        report = process_records_and_report(records, headers, sip, work, context, repnal)

        return report
    end

    def build_validation_context(work, repnal)
        {
            wt: work.singularize.classify.constantize,
            licenses: get_licenses,
            rights: get_rights_statements,
            resource_types: get_resource_types,
            types_conacyt: repnal ? get_types_conacyt : [],
            pub_conacyt: repnal ? get_pub_conacyt : []
        }
    end

    def process_records_and_report(records, headers, sip, work, context, repnal)
        report = Hash.new
        records.each_with_index do |record, index|
            errors = validate_record(record, index, context[:wt], context[:rights], context[:licenses], context[:resource_types], context[:types_conacyt], context[:pub_conacyt], repnal)
            errors.each do |k, v|
                next unless v && !v.empty?
                report[k] = (report[k] || []) + v
            end
        end
        begin
            file_errors = validate_files_and_duplicates(records, headers, sip, work)
            file_errors.each do |k, v|
                report[k] = v
            end
        rescue Exception => e
            return { Error: "Error de sistema, favor de enviar una captura de pantalla a la CID y - #{e.to_s}"}
        end
        if report.empty?
            report["success"] = records.map { |r| r.identifier if r.respond_to? :identifier}
        end
        report
    end

    def check_date(date)
        match = true
        date.each { |d| match = false unless d.match?(/^([0-9]{1,4})?$/) }
        return match
    end

    def check_based_near(based_near)
        match = true
        based_near.each { |bn| match = false unless bn.match?(/https:\/\/sws\.geonames\.org\/[0-9]*\//) }
        return match
    end

    def self.delete_records_by_identifiers(id_import, work, identifiers)

        identifiers = JSON.parse identifiers
        wt = work.singularize.classify.constantize
        identifiers.each do |i|
            begin
                w = wt.where(identifier: i)

                if w.count > 0 then
                    filesets = w.first.members
                    w.first.destroy
                    fileset.each { |f| f.destroy }

                end
            rescue Exception => e
                puts e
            end
        end
        i = Import.find(id_import)
        i.status = "Cancelado"
        i.save
    end

    def validate_identifier(record, index, wt)
        return nil if record.respond_to?("identifier")
        index + 2
    end

    def validate_title(record, index)
        return nil if record.respond_to?("title")
        index + 2
    end

    def validate_rights_statement(record, index, rights)
        return nil unless record.respond_to?("rights_statement")
        return nil if (record.rights_statement & rights).count > 0
        [index + 2, record.rights_statement]
    end

    def validate_duplicate_identifier(record, index, wt)
        return nil unless record.respond_to?("identifier")
        return nil unless wt.where(identifier: record.identifier).count > 0
        [index + 2, [record.identifier]]
    end

    def validate_duplicate_isbn(record, index, wt)
        return nil unless record.respond_to?("isbn")
        return nil unless wt.where(isbn: record.isbn).count > 0
        [index + 2, [record.isbn]]
    end

    def validate_based_near(record, index)
        return nil unless record.respond_to?("based_near")
        return nil if check_based_near(record.based_near)
        [index + 2, record.based_near]
    end

    def validate_license(record, index, licenses)
        return nil unless record.respond_to?("license")
        return nil if (record.license & licenses).count > 0
        [index + 2, record.license]
    end

    def validate_resource_type(record, index, resource_types)
        return nil unless record.respond_to?("resource_type")
        return nil if (record.resource_type & resource_types).count > 0
        [index + 2, record.resource_type]
    end

    def validate_type_conacyt(record, index, types_conacyt)
        return nil unless record.respond_to?("type_conacyt")
        return nil if types_conacyt.include?(record.type_conacyt)
        [index + 2, [record.type_conacyt]]
    end

    def validate_subject_conacyt(record, index)
        return nil unless record.respond_to?("subject_conacyt")
        return nil if (1..7).include? record.subject_conacyt.to_i
        [index + 2, [record.subject_conacyt]]
    end

    def validate_pub_conacyt(record, index, pub_conacyt)
        return nil unless record.respond_to?("pub_conacyt")
        return nil if (record.pub_conacyt & pub_conacyt).count > 0
        [index + 2, record.pub_conacyt]
    end

    def validate_missing_license(record, index)
        return nil if record.respond_to?("license")
        index + 2
    end

    def validate_missing_type_conacyt(record, index)
        return nil if record.respond_to?("type_conacyt")
        index + 2
    end

    def validate_missing_subject_conacyt(record, index)
        return nil if record.respond_to?("subject_conacyt")
        index + 2
    end

    def validate_record(record, index, wt, rights, licenses, resource_types, types_conacyt, pub_conacyt, repnal)
        errors = {}
        id_error = validate_identifier(record, index, wt)
        errors["Los registros de las siguientes filas carecen de la información en el campo identifier o este no se encuentra definido dentro del CSV"] = [id_error] if id_error
        title_error = validate_title(record, index)
        errors["Los registros de las siguientes filas carecen de la información en el campo title o este no se encuentra definido dentro del CSV"] = [title_error] if title_error
        rights_error = validate_rights_statement(record, index, rights)
        errors["El campo rights_statement no corresponde al vocabulario controlado"] = [rights_error] if rights_error
        date_error = validate_date_created(record, index)
        errors["El campo date_created no esta expresado en el formato correcto (yyyy)"] = [date_error] if date_error
        dup_id_error = validate_duplicate_identifier(record, index, wt)
        errors["Los registros que se encuentran en las siguientes Filas tienen un identificador que ya existe en el sistema  (campo identifier)"] = [dup_id_error] if dup_id_error
        dup_isbn_error = validate_duplicate_isbn(record, index, wt)
        errors["Los registros que se encuentran en las siguientes Filas tienen un ISBN que ya existe en el sistema  (campo isbn)"] = [dup_isbn_error] if dup_isbn_error
        based_near_error = validate_based_near(record, index)
        errors["El campo based_near no esta expresado en el formato correcto (https://sws.geonames.org/<id>/)"] = [based_near_error] if based_near_error
        license_error = validate_license(record, index, licenses)
        errors["Los registros de las siguientes filas carecen de la información en el campo license no corresponde con el vocabularo controlado"] = [license_error] if license_error
        resource_type_error = validate_resource_type(record, index, resource_types)
        errors["Los registros de las siguientes filas carecen de la información en el campo resource_type no corresponde con el vocabularo controlado"] = [resource_type_error] if resource_type_error
        if repnal
            missing_license_error = validate_missing_license(record, index)
            errors["Los registros de las siguientes filas carecen de la información en el campo license o este no se encuentra definido dentro del CSV"] = [missing_license_error] if missing_license_error
            type_conacyt_error = validate_type_conacyt(record, index, types_conacyt)
            errors["El campo type_conacyt no corresponde con el vocabularo controlado"] = [type_conacyt_error] if type_conacyt_error
            missing_type_conacyt_error = validate_missing_type_conacyt(record, index)
            errors["Los registros de las siguientes filas carecen de la información en el campo type_conacyt o este no se encuentra definido dentro del CSV"] = [missing_type_conacyt_error] if missing_type_conacyt_error
            subject_conacyt_error = validate_subject_conacyt(record, index)
            errors["El campo subject_conacyt no corresponde con el vocabularo controlado"] = [subject_conacyt_error] if subject_conacyt_error
            missing_subject_conacyt_error = validate_missing_subject_conacyt(record, index)
            errors["Los registros de las siguientes filas carecen de la información en el campo subject_conacyt o este no se encuentra definido dentro del CSV"] = [missing_subject_conacyt_error] if missing_subject_conacyt_error
            pub_conacyt_error = validate_pub_conacyt(record, index, pub_conacyt)
            errors["El campo pub_conacyt no corresponde con el vocabularo controlado"] = [pub_conacyt_error] if pub_conacyt_error
        end
        errors
    end

end
