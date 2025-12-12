class RecordChangeActor < Hyrax::Actors::AbstractActor
      
    def update(env)

        original_record = env.curation_concern.attributes.to_h
        updated_record = env.attributes.to_h
        original_record["visibility"] = env.curation_concern.visibility

        changes = get_changes(original_record, updated_record)
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
  
    def get_changes(original_record, updated_record)
        updated_fields = {}
        
        updated_record.each do |field, updated_value|
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