module AssignorService
  
  def self.work
    Work.all.each do |gw| 
      process(gw)
    end
  end

  def self.process(gw)
    creator = []
    contributor = []
    [:creator, :contributor].each do |p|
      unless gw.send(p).empty?
        gw.send(p).each do |c|
          n = c.split(', ')

          nombre = [ n[1], n[0] ].join(" ")

          buscar = I18n.transliterate(nombre).gsub(/[^0-9A-Za-z  ]/, '').gsub(" ", "%20")

          conn = Faraday.new :url =>'http://catalogs.repositorionacionalcti.mx/webresources/', :headers => { :Authorization => "Basic #{ENV['CONACYT_AUTH']}"}
          a = conn.get "persona/byNombreCompleto/params;nombre=#{buscar}"
          
          begin
            data = JSON.parse(a.body.force_encoding('utf-8'))
          rescue JSON::ParserError
            data = {}
          end
          
          unless data.empty?
            
            autor = ""
            
            data[0].each do |key, value| 
              if autor == ""
                autor += "#{key}: #{value}\n"  
              else
                autor += "#{key}: #{value}\n" 
              end
            end
            if p == :creator 
              creator.push(autor)
            elsif p == :contributor
              contributor.push(autor)
            end
              
          end
        end
      end
    end
    unless creator.empty?
      gw.creator_conacyt = creator
      gw.save
    else
      gw.creator_conacyt = nil
      gw.save  
    end
    unless contributor.empty?
      gw.contributor_conacyt = contributor
      gw.save
    else
      gw.contributor_conacyt = nil
      gw.save 
    end
    # puts "\n\n\n\n"
    # puts creator
    # puts "\n\n\n\n"
    # puts contributor
    # puts "\n\n\n\n"
  end
  

end
