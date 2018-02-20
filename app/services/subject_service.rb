module SubjectService
    mattr_accessor :authority
  
    def self.areascono
      conn = Faraday.new :url =>'http://catalogs.repositorionacionalcti.mx/webresources/'
  
      areas = conn.get 'areacono'
  
      data = JSON.parse(areas.body.force_encoding('utf-8'))
  
      areascono = []
  
      data.each do |dato|
        hash = {}
        hash[:id] = dato["idArea"]
        hash[:label] = dato["descripcion"]
  
        areascono.push(hash)
      end
  
      areascono.map { |e| [e[:label], e[:id]] }
  
    end
  end