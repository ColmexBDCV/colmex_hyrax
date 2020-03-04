module HyraxHelper
  include ::BlacklightHelper
  include Hyrax::BlacklightOverride
  include Hyrax::HyraxHelperBehavior
  
  def build_citation(presenter)
    if presenter.resource_type.include? "Tesis" then
      "#{build_authors(presenter)} (#{presenter.date_created.first}), #{presenter} (#{presenter.resource_type.first}), El Colegio de México, México"
    end
  end

  def build_authors(presenter)
    s = ""
    presenter.creator.each do |a|
      n = a.split(', ')
      s = s + [ n[0], n[1][0] ].join(" ")+"., "
    end

    presenter.contributor.each do |a|
      n = a.split(', ')
      s = s + [ n[0], n[1][0] ].join(" ")+"., "
    end
    
    return s.chomp(", ")
  end
  

  #apply locale config to sort_fields
  def translate_sort_fields(sort_fields)
    tsf = []
    sort_fields.each do |f|
      tsf.push( [t('blacklight.search.sort.'+f[0]), f[1]])
    end
    return tsf
  end
end
