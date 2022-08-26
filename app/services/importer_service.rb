require 'set'

module ImporterService
    
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

    def get_files_in_folder(sip)
        
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

    # report = ImporterService.validate_csv("TesisColmexMarzo2022","Video", true)
    def validate_csv(sip, work, repnal = false)
        # return "No existe carpeta metadatos o archivo de metadatos.csv no existe" unless metadata_exists?(sip)
        # return "No existe carpeta documentos_de_acceso o está esta vacia" unless documents_exists?(sip)
        
        parser = ColmexCsvParser.new(file: File.open("digital_objects/#{sip}/metadatos/metadatos.csv"), work: work)
        begin
            parser.validate 
        rescue
            return "El archivo metadatos.csv es invalido, revisar estructura"
        end

        licenses = get_licenses
        rights = get_rights_statements
        types_conacyt = get_types_conacyt if repnal
        pub_conacyt = get_pub_conacyt if repnal

        wt = work.singularize.classify.constantize
        

        records = Importer.new(parser: parser, work: work).records.to_a
        
        files_csv=records.map { |r| r.representative_file }.flatten
        files_folder = Dir["digital_objects/#{sip}/documentos_de_acceso/*"].map { |f| f.gsub("digital_objects/", '') }
        
        report = Hash.new
        records.each_with_index do |record,index|
            
            report["identifier"] = (report["identifier"] || []) << index + 2 unless record.respond_to?("identifier")
            report["title"] = (report["title"] || []) << index + 2 unless record.respond_to?("title")
            report["rights_statement"] = (report["rights_statement"] || []) << [index + 2, record.rights_statement] if record.respond_to?("rights_statement") && (record.rights_statement & rights).count == 0
            report["date_created"] = (report["date_created"] || []) << [index + 2, record.date_created] if record.respond_to?("date_created") && !check_date(record.date_created)
            report["exists"] = (report["exist"] || []) << [index + 2, record.identifier] if record.respond_to?("identifier") && wt.where(identifier: record.identifier).count > 0 
            report["based_near"] = (report["based_near"] || []) << [index + 2, record.based_near] if record.respond_to?("based_near") && !check_based_near(record.based_near)
            if repnal then
                report["license"] = (report["license"] || []) << [index + 2] if !record.respond_to?("license") || (record.license & licenses).count == 0
                report["license"] << record.license if record.respond_to?("license") && report.respond_to?("license")
                report["type_conacyt"] = (report["type_conacyt"] || []) << [index + 2] unless record.respond_to?("type_conacyt") || (record.respond_to?("type_conacyt") && !(types_conacyt.include? record.type_conacyt))
                report["type_conacyt"] << record.type_conacyt if record.respond_to?("type_conacyt") && report.respond_to?("type_conacyt")
                report["subject_conacyt"] = (report["subject_conacyt"] || []) << [index + 2] unless record.respond_to?("subject_conacyt") || (record.respond_to?("subject_conacyt") && !((1..7).include? record.type_conacyt))
                report["subject_conacyt"] << record.subject_conacyt if record.respond_to?("subject_conacyt") && report.respond_to?("subject_conacyt")
                report["pub_conacyt"] = (report["pub_conacyt"] || []) << [index + 2, record.pub_conacyt] if record.respond_to?("pub_conacyt") && (record.pub_conacyt & pub_conacyt).count == 0
            else
                report["license"] = (report["license"] || []) << [index + 2, record.license] if record.respond_to?("license") && (record.license & licenses).count == 0

            end

        end
         report["files_not_found"] = files_csv - files_folder
         report["files_not_referenced"] = files_folder - files_csv

        

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
end