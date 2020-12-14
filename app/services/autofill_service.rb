module AutofillService
  
    def self.person(person)
      begin    
        conn = Faraday.new :url =>'https://api-na.hosted.exlibrisgroup.com/primo/v1/search?apikey=l8xxaa0f4ca6a15043078852823d79d6ef5c&scope=default_scope&tab=default_tab&vid=52COLMEX_AUTH&q=any,contains,'+person
        person = conn.get
        data = JSON.parse(person.body.force_encoding('utf-8'))
      end  
      names = []
      
      data["docs"].each do |doc|
        
        hash = {}
        name = doc["pnx"]["search"]["title"].first.split(",")
        name = name.take(2) if name.count > 2 
        name = name.join(",")        
        
        names.push(name)
      end
      
      return names
  
    end
end