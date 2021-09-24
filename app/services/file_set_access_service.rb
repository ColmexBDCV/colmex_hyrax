module FileSetAccessService
    def self.change_permissions(permission, text)
        Hyrax::config.registered_curation_concern_types.each do |wt|
            wt.singularize.classify.constantize.where(item_access_restrictions: text).each do |w|
                w.file_set_ids.each do |id|
                    fs = FileSet.find(id)
                    fs.visibility = permission
                    fs.save
                end
            end    
        end
    end
end
 