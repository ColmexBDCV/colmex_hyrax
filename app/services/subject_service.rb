module SubjectService
    mattr_accessor :authority
  
    def self.areascono
      begin    
        conn = Faraday.new :url =>'http://catalogs.repositorionacionalcti.mx/webresources/'
        areas = conn.get 'areacono'
        data = JSON.parse(areas.body.force_encoding('utf-8'))
      rescue 
        data = SubjectService::areas_data
      end  
        
      areascono = []
      
      data.each do |dato|
        
        hash = {}
        hash[:id] = dato["idArea"] ? dato["idArea"] : dato[:idArea]
        hash[:label] = dato["descripcion"] ? dato["descripcion"] : dato[:description]
  
        areascono.push(hash)
      end
      
      areascono.map { |e| [e[:label], e[:id]] }
  
    end
    
    def self.areas_data
      [{"cveArea":"2","descripcion":"BIOLOGÍA Y QUÍMICA","description":"BIOLOGÍA Y QUÍMICA","idArea":2},
       {"cveArea":"6","descripcion":"CIENCIAS AGROPECUARIAS Y BIOTECNOLOGÍA","description":"CIENCIAS AGROPECUARIAS Y BIOTECNOLOGÍA","idArea":6},
       {"cveArea":"1","descripcion":"CIENCIAS FÍSICO MATEMÁTICAS Y CIENCIAS DE LA TIERRA","description":"CIENCIAS FÍSICO MATEMÁTICAS Y CIENCIAS DE LA TIERRA","idArea":1},
       {"cveArea":"5","descripcion":"CIENCIAS SOCIALES","description":"CIENCIAS SOCIALES","idArea":5},
       {"cveArea":"4","descripcion":"HUMANIDADES Y CIENCIAS DE LA CONDUCTA","description":"HUMANIDADES Y CIENCIAS DE LA CONDUCTA","idArea":4},
       {"cveArea":"7","descripcion":"INGENIERÍA Y TECNOLOGÍA","description":"INGENIERÍA Y TECNOLOGÍA","idArea":7},
       {"cveArea":"3","descripcion":"MEDICINA Y CIENCIAS DE LA SALUD","description":"MEDICINA Y CIENCIAS DE LA SALUD","idArea":3}]
    end



  end