require 'set'

module ExporterService

    def self.by_work_type(work_type)
        gw = work_type.singularize.classify.constantize         
        CSV.open("export_#{work_type}.csv", "wb") do |csv|
            csv << gw.first.attributes.keys
            gw.all.each do |obj| 
                values = []
                obj.attributes.values.each do |o|
                    if o.is_a?(ActiveTriples::Resource) || o.is_a?(ActiveTriples::Relation) then
                        values << o.to_a.join(" | ")
                    else
                        values << o
                    end
                end
                csv << values
            end
        end
    end 
    def self.by_collection(coll)
        work_ids = Collection.where(title: coll)[0].member_work_ids
        keys = []
        data = []
        
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
            
            data << row
            
        end
        
        CSV.open("export_#{coll}.csv", "wb", :headers => keys, :write_headers => true) do |csv|               
            data.each do|v|
                csv << v.to_h
            end          
        end
    end 
end
