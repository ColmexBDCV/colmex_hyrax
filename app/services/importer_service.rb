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

   
    def self.validate_csv(file, work)
        parser = ColmexCsvParser.new(file: File.open("digital_objects/#{file}"), work: work)
        begin
            parser.validate 
        rescue
            return "El CSV es invalido, revisar estructura"
        end

        records = Importer.new(parser: parser, work: work).records.to_a
        report = Hash.new
        byebug
        records.each_with_index do |record,index|
            report["identifier"] = (report["identifier"] || []) << index + 2 unless record.respond_to?("identifier")


        end
        
        return report
        
    end
    
    


end