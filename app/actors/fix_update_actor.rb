class FixUpdateActor < Hyrax::Actors::AbstractActor
      
    def update(env)
        wt = env.curation_concern.class.to_s 
        id = env.curation_concern.id
        attrs = env.attributes
        work = wt.singularize.classify.constantize.find id

        attrs.each do |key, val|
           
            next if key == "based_near_attributes"
            next if key == "permissions_attributes"
           
            if work.send(key).respond_to?("to_a") 
                unless work.send(key).to_a == val.to_a 
                    work.send("#{key}=", [])
                    work.send("#{key}=",val)
                end
            end
            
        end

        work.save

                
    end
end