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
   
    def self.update(url, handle_id)
        handle_id = handle_id.sub("http://hdl.handle.net/","")
        handle_id = handle_id.sub("https://hdl.handle.net/","")
        begin    
            handle_obj = @@conn.put("handle/update", {name: "#{handle_id}", url: url}.to_json, {'Content-Type'=>'application/json'})
            data = JSON.parse(handle_obj.body.force_encoding('utf-8'))
            return data
        rescue Faraday::ConnectionFailed 
            retry
        end  
    end

    def self.delete(handle_id)
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
                    puts "#{url}#{wt.underscore.pluralize}/#{row.id}"
                    handle = self.create("#{url}#{wt.underscore.pluralize}/#{row.id}")
                    if handle["handleDesc"] == "SUCCESS"
                        row.handle = handle["url"] 
                        row.save
                    end
                end
            end
        end
    end

    def self.destroy_handle_for(work)
        
        url = "http://hdl.handle.net/"
        
        work.singularize.classify.constantize.where('handle_tesim:[* TO *]-handle_tesim:””').each do |row|
            puts row.handle.gsub(url,"")
            handle = self.delete(row.handle.gsub(url,""))
            if handle["handleDesc"] == "SUCCESS"
                row.handle = nil
                row.save
            end
        end
    end

end