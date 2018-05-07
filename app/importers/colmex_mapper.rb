# frozen_string_literal: true
class ColmexMapper < Darlingtonia::HashMapper
  TERMS_NO_MAP = [:file_name]
  
  def representative_file
    @metadata[:file_name]
  end

  
  def fields
    return [] if metadata.nil?
    mt = metadata.keys.map(&:to_sym)
    mt.delete(:file_name)
    mt
  end


  

  def map_field(name)
    return if TERMS_NO_MAP.include?(name)
    metadata[name]
    
  end
 
end  