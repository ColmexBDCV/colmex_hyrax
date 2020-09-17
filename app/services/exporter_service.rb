module ExporterService

    def self.start(work)
        gw = work.singularize.classify.constantize         
        CSV.open("export.csv", "wb") do |csv|
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
end
