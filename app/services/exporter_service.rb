require 'set'

module ExporterService
            
    def self.by_work_type(work_type,fields)
        work_ids = []
                 
        work_type.singularize.classify.constantize.all.each do |row|
            work_ids << row.id
        end
        self.export(work_ids, fields, work_type)
    end
    
    def self.by_collection(coll,fields)
        work_ids = Collection.where(title: coll)[0].member_work_ids
        self.export(work_ids,fields, coll)
    end

    def self.all(fields)
        work_ids = []
        Hyrax::config.registered_curation_concern_types.each do |wt|
            wt.singularize.classify.constantize.all.each do |row|
                work_ids << row.id
            end
        end
        self.export(work_ids, fields)
    end

    def self.by_thematic_collection(coll,fields)
        work_ids = []
        Hyrax::config.registered_curation_concern_types.each do |wt|
            wt.singularize.classify.constantize.where(thematic_collection: coll).each do |row|
                work_ids << row.id
            end
        end
        self.export(work_ids, fields, "thematic_collection")
    end

    def self.export(work_ids, fields,tag = "all")
        
        data=[]       
        keys = []
        keys.push("filenames")
        keys.push("identifier")
        keys.push("title")
        keys.push("thumbnail")
        work_ids.each do |id|
            obj = ActiveFedora::Base.find(id)
            
            keys = keys + obj.attributes.keys
            
            keys = keys.to_set.to_a;
            
            row = {}
            obj.attributes.each do |key, value|
                
                if value.is_a?(ActiveTriples::Resource) || value.is_a?(ActiveTriples::Relation) then
                    row[key] =  value.to_a.join(" | ")
                else
                    row[key] = value
                end
            end
            
           

            if obj.file_sets.count > 0 then
                filenames = ""
                obj.file_sets.each do |fs|
                    unless fs.title.first.nil? then
                        filenames += fs.title.first + " | "
                    end
                end

                
                row["filenames"] = filenames.chomp(" | ")
            end
                row["thumbnail"] = "https://repositorio.colmex.mx/downloads/#{obj.thumbnail_id}?file=thumbnail" if obj.respond_to?("thumbnail_id")
            data << row
            
        end
        
        keys = fields.split if !fields.nil? && fields.split.count > 0

        CSV.open("export_#{tag}.csv", "wb", :headers => keys, :write_headers => true) do |csv|               
            data.each do|v|
                csv << v.to_h
            end          
        end
    end 
end
