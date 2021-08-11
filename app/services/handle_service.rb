module HandleService

    
    @@handle_id = ENV['HANDLE_ID'] || "20.500.11986/COLMEX/"
    @@conn = Faraday.new :url => ENV['HANDLE_URL'] || 'http://sandbox.colmex.mx:8010/'

    def self.create(url)
        begin    
            handle_obj = @@conn.post("handle/create", {name: "#{@@handle_id}", url: url}.to_json, {'Content-Type'=>'application/json'})
            data = JSON.parse(handle_obj.body.force_encoding('utf-8'))
            return data
        rescue Faraday::ConnectionFailed 
            retry
        end  
    end
   
    def update(url, handle_id)
        handle_id.slice!("http://hdl.handle.net")
        handle_id.slice!("https://hdl.handle.net")
        begin    
            handle_obj = @@conn.put("handle/update", {name: "#{handle_id}", url: url}.to_json, {'Content-Type'=>'application/json'})
            data = JSON.parse(handle_obj.body.force_encoding('utf-8'))
            return data
        rescue Faraday::ConnectionFailed 
            retry
        end  
    end

    def delete(handle_id)
        begin    
            
            handle_obj = @@conn.delete("handle/delete/#{handle_id}")
            data = JSON.parse(handle_obj.body.force_encoding('utf-8'))
            return data
        rescue Faraday::ConnectionFailed 
            retry
        end  
    end

    def self.assing_handle_for_all
        
        url = ENV['HANDLE_OBJ_URL'] || "https://repositorio.colmex.mx/concern/"
        Hyrax::config.registered_curation_concern_types.each do |wt|
            wt.singularize.classify.constantize.where(handle: nil).each do |row|
                if row.member_ids.count > 0
                    handle = self.create("#{url}#{row.human_readable_type.underscore.pluralize}/#{row.id}")
                    if handle["handleDesc"] == "SUCCESS"
                        row.handle = handle["url"] 
                        row.save
                    end
                end
            end
        end
    end

end