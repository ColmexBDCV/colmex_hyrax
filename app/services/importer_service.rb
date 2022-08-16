require 'set'

module ImporterService
    
    def self.list_sips
        list_folders("digital_objects")
    end

    def self.metadata_exists?(sip)
        File.exists?("digital_objects/#{sip}/metadatos/metadatos.csv")       
    end

    def self.object_exists?(file)
        File.exists?("digital_objects/#{file}") 
    end

    def self.list_folders(folder)
        Dir.entries(folder).select {|entry| File.directory? File.join(folder,entry) and !(entry =='.' || entry == '..') }
    end

    def self.get_licenses
        license_service = Hyrax.config.license_service_class.new 
        license_service.select_active_options.map { |e| e[1] }
    end

    #report = ImporterService.validate_csv("TesisColmexMarzo2022/metadatos/metadatos.csv","Thesis")
    def self.validate_csv(file, work)
        parser = ColmexCsvParser.new(file: File.open("digital_objects/#{file}"), work: work)
        begin
            parser.validate 
        rescue
            return "El CSV es invalido, revisar estructura"
        end

        licenses = get_licenses

        records = Importer.new(parser: parser, work: work).records.to_a
        byebug
        report = Hash.new
        records.each_with_index do |record,index|
            
            report["identifier"] = (report["identifier"] || []) << index + 2 unless record.respond_to?("identifier")
            report["title"] = (report["title"] || []) << index + 2 unless record.respond_to?("title")
            report["license"] = (report["license"] || []) << index + 2 if record.respond_to?("license") && (record.license & licenses).count == 0
            report["date_created"] = (report["date_created"] || []) << index + 2 if record.respond_to?("date_created") && !check_date(record.date_created)

        end
        
        return report
    end
    
   def self.check_date(date)
        match = true
        date.each { |d| match = false unless d.match?(/^([0-9]{1,4})?$/) }
        return match
   end


end