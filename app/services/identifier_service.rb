module IdentifierService
  
  def self.for_all
    ["Thesis", "Book", "Article", "BookChapter"].each do |w|
      self.work(w)
    end
  end

  def self.work(work)
    work.singularize.classify.constantize.all.each do |gw| 
      unless gw.creator.empty? then
        process(gw)
      end
    end
  end

  def self.format_name(name)

    unless name.include?(", ") then
      name = name.gsub(",", ", ")
    end
    
    n = name.split(', ')

    if n[1][-2] == " " || n[1][-3] == " " || n[1][-1] == "." then
      *n[1], remove = n[1].split(" ")
    end
    [ n[1], n[0] ].join(" ")
  end 
  
  def self.get_conacyt_authors(gw)
    creator = []
    contributor = []
    [:creator, :contributor].each do |p|
      unless gw.send(p).empty?
        gw.send(p).each do |c|
          break unless c.include? "," 

          nombre = format_name c

          buscar = I18n.transliterate(nombre).gsub(/[^0-9A-Za-z  ]/, '').gsub(" ", "%20")

          conn = Faraday.new :url =>'http://catalogs.repositorionacionalcti.mx/webresources/', :headers => { :Authorization => "Basic #{ENV['CONACYT_AUTH'] || "ZWNtOkVjTTA1XzA2"}"}
          begin          
            a = conn.get "persona/byNombreCompleto/params;nombre=#{buscar}"
          rescue Faraday::ConnectionFailed 
            retry
          end
          
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
    [creator, contributor]
  end

  def self.process(gw)
    puts gw.id
    creator, contributor = get_conacyt_authors(gw)
    puts gw.creator
    gw.creator_conacyt = nil
    gw.contributor_conacyt = nil
    gw.save  
    unless creator.empty?
      gw.creator_conacyt = creator
      gw.save
    end
    unless contributor.empty?
      gw.contributor_conacyt = contributor
      gw.save
    end
    
  end
  

end
