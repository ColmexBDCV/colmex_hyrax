require 'set'

module ImporterService

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

    # report = ImporterService.validate_csv("TesisColmexMarzo2022","Video", true)
    def validate_csv(sip, work, repnal = false)
               
        return { Error: "No existe carpeta metadatos o archivo de metadatos.csv no existe"} unless metadata_exists?(sip)
        return { Error: "No existe carpeta documentos_de_acceso o está esta vacia"} unless documents_exists?(sip)
        
        parser = ColmexCsvParser.new(file: File.open("digital_objects/#{sip}/metadatos/metadatos.csv"), work: work)
        
        unless parser.validate then
            return { Error: "El archivo metadatos.csv es invalido, revisar estructura. SYSTEM_LOG: #{parse_errors(parser.errors).to_s}" }
        end

        begin
            
            records = Importer.new(parser: parser, work: work).records.to_a 
            csv = CSV.table("digital_objects/#{sip}/metadatos/metadatos.csv", {:headers => :first_row, :liberal_parsing=> true})
        rescue Exception => e
            return { Error: "El archivo metadatos.csv es invalido, revisar estructura, SYSTEM_LOG: #{e}"}
        end

        licenses = get_licenses
        rights = get_rights_statements
        types_conacyt = get_types_conacyt if repnal
        pub_conacyt = get_pub_conacyt if repnal

        wt = work.singularize.classify.constantize
       
        headers = csv.headers

        # unless headers.include?(:identifier)  then 
        #     return {Error: "El campo identifier no se encuentra definido en los metadatos"}
        # end

        # unless headers.include?(:title)  then 
        #     return {Error: "El campo title no se encuentra definido en los metadatos"}
        # end
        
        bad_fields = []
        headers.each_with_index do |h,i|
            bad_fields << h unless wt.new.respond_to?(h) 
        end


        #Campos permitidos fuera de las plantillas
        bad_fields.delete(:file_name)
        bad_fields.delete(:messagedigest)
        
        report = Hash.new
            
       
     
        records.each_with_index do |record,index|
            
            report["Los registros de las siguientes filas carecen de la información en el campo identifier o este no se encuentra definido dentro del CSV"] = (report["Los registros de las siguientes filas carecen de la información en el campo identifier o este no se encuentra definido dentro del CSV"] || []) << index + 2  unless record.respond_to?("identifier")
            report["Los registros de las siguientes filas carecen de la información en el campo title o este no se encuentra definido dentro del CSV"] = (report["Los registros de las siguientes filas carecen de la información en el campo title o este no se encuentra definido dentro del CSV"] || []) << index + 2 unless record.respond_to?("title")
            report["El campo rights_statement no corresponde al vocabulario controlado"] = (report["rights_statement"] || []) << [index + 2, record.rights_statement] if record.respond_to?("rights_statement") && (record.rights_statement & rights).count == 0
            report["El campo date_created no esta expresado en el formato correcto (yyyy)"] = (report["El campo date_created no esta expresado en el formato correcto (yyyy)"] || []) << [index + 2, record.date_created] if record.respond_to?("date_created") && !check_date(record.date_created)
            report["Los registros que se encuentran en las siguientes Filas tienen un identificador que ya existe en el sistema  (campo identifier)"] = (report["Filas que contienen un registro ya existente en el sistema (mismo identifier)"] || []) << [index + 2, [record.identifier]] if record.respond_to?("identifier") && wt.where(identifier: record.identifier).count > 0 
            report["El campo based_near no esta expresado en el formato correcto (https://sws.geonames.org/<id>/)"] = (report["El campo based_near no esta expresado en el formato correcto (https://sws.geonames.org/<id>/)"] || []) << [index + 2, record.based_near] if record.respond_to?("based_near") && !check_based_near(record.based_near)
            report["Los registros de las siguientes filas carecen de la información en el campo license no corresponde con el vocabularo controlado"] = (report["Los registros de las siguientes filas carecen de la información en el campo license no corresponde con el vocabularo controlado"] || []) << [index + 2, record.license] if record.respond_to?("license") && (record.license & licenses).count == 0
            if repnal then
                report["Los registros de las siguientes filas carecen de la información en el campo license o este no se encuentra definido dentro del CSV"] = (report["Los registros de las siguientes filas carecen de la información en el campo license o este no se encuentra definido dentro del CSV"] || []) << index + 2 unless record.respond_to?("license")
                report["El campo type_conacyt no corresponde con el vocabularo controlado"] = (report["Los registros de las siguientes filas carecen de la información en el campo type_conacyt no corresponde con el vocabularo controlado"] || []) << [index + 2, [record.type_conacyt]] if record.respond_to?("type_conacyt") && !types_conacyt.include?(record.type_conacyt)
                report["Los registros de las siguientes filas carecen de la información en el campo type_conacyt o este no se encuentra definido dentro del CSV"] = (report["Los registros de las siguientes filas carecen de la información en el campo type_conacyt o este no se encuentra definido dentro del CSV"] || []) << index + 2 unless record.respond_to?("type_conacyt") 
                report["El campo subject_conacyt no corresponde con el vocabularo controlado"] = (report["Los registros de las siguientes filas carecen de la información en el campo subjectconacyt no corresponde con el vocabularo controlado"] || []) << [index + 2, [record.subject_conacyt]] if record.respond_to?("subject_conacyt")  && !((1..7).include? record.subject_conacyt.to_i)
                report["Los registros de las siguientes filas carecen de la información en el campo subject_conacyt o este no se encuentra definido dentro del CSV"] = (report["Los registros de las siguientes filas carecen de la información en el campo subject_conacyt o este no se encuentra definido dentro del CSV"] || []) << index + 2 unless record.respond_to?("subject_conacyt")
                report["El campo pub_conacyt no corresponde con el vocabularo controlado"] = (report["El campo pub_conacyt no corresponde con el vocabularo controlado"] || []) << [index + 2, record.pub_conacyt] if record.respond_to?("pub_conacyt") && (record.pub_conacyt & pub_conacyt).count == 0
            end

        end
        
        # unless report.empty?
        #     return report
        # end

        begin
            files_csv = records.map { |r| r.representative_file }.flatten
            identifiers = records.map { |r| r.identifier if r.respond_to? :identifier}
            i_d = (identifiers.select { |i| identifiers.count(i) > 1 }).to_set.to_a
            files_folder = Dir["digital_objects/#{sip}/documentos_de_acceso/*"].map { |f| f.gsub("digital_objects/", '') }
            identifiers.each_with_index do |identifier, index| 
                if i_d.include?(identifier) && headers.include?(:identifier)  then
                    report["El identifier #{identifier} se encuentra duplicado en las siguientes filas"] = ( report["El identifier #{identifier} se encuentra duplicado en las siguientes filas"] || []) << index +2
                end

            end
            report["No se encuentran los archivos referenciados, favor de verificar que existan en la carpeta documentos_de_acceso y los nombres sean exactamente iguales"] = files_csv - files_folder unless (files_csv - files_folder).empty?
            report["Los siguientes archivos no tienen registros asociados a ellos en el campo file_name dentro del CSV"] = files_folder - files_csv unless (files_folder - files_csv).empty?
            report["Los siguientes campos utilizados, no corresponden a la plantilla seleccionada (#{t('hyrax.admin.validations.'+work.underscore.downcase)})"] = bad_fields if bad_fields.count > 0
        rescue Exception => e
            return { Error: "Error de sistema, favor de enviar una captura de pantalla a la CID y - #{e.to_s}"}
        end


        if report.empty?
            report["success"] = identifiers
        end
        # byebug 
        return report
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

end