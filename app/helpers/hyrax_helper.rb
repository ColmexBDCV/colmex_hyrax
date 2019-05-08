module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  
  def build_citation(presenter)
    "#{build_authors(presenter)} (#{presenter.date_created.first}), #{presenter} (#{presenter.resource_type.first}), El Colegio de México, Ciudad de México, México"
  end

  def build_authors(presenter)
    s = ""
    presenter.creator.each do |a|
      n = a.split(', ')
      s = s + [ n[1], n[0] ].join(" ")+", "
    end

    presenter.contributor.each do |a|
      n = a.split(', ')
      s = s + [ n[1], n[0] ].join(" ")+", "
    end
    
    return s.chomp(", ")
  end
  

end
