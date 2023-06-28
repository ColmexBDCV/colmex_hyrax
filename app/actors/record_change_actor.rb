class RecordChangeActor < Hyrax::Actors::AbstractActor
      
    def update(env)
        
        changes = get_changes env.curation_concern.attributes.to_h, env.attributes.to_h
        unless changes.empty?
            log = {
                change:  changes.to_json,
                user: env.user,
                template: env.curation_concern.has_model.first,
                record_id: env.curation_concern.id,
                identifier: env.attributes[:identifier],
            }
            record = RecordChangeLog.new(log)
            record.save
        end
        next_actor.update(env)
    end
  
    private
  
    def get_changes(original_record, updated_version)
        updated_fields = {}
        
        updated_version.each do |field, updated_value|
            if original_record.key?(field) && original_record[field] != updated_value
                unless original_record[field] == [] && updated_value == nil
                    updated_fields[field] = {
                        before: original_record[field],
                        after: updated_value
                    }
                end
            end
        end
        
        updated_fields
    end
  end