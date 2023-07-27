# frozen_string_literal: true

class ColmexCsvParser < Darlingtonia::CsvParser
  attr_accessor :file, :validators, :work, :update
    attr_reader   :errors

    ##
    # @param file [File]
    def initialize(file:, work:,**_opts)
      self.file     = file
      
      Hyrax.config.curation_concerns.each_with_index do |tw, i|
        
        if tw.name == work
         self.work = Hyrax.config.curation_concerns[i].new
        end
      end
      
      @errors       = []
      @validators = _opts[:update] ? [Darlingtonia::CsvFormatValidator.new] : self.class::DEFAULT_VALIDATORS
      self.update = _opts[:update]  unless _opts[:update].nil?
      yield self if block_given?
    end

  DEFAULT_VALIDATORS = [Darlingtonia::CsvFormatValidator.new,
                        # Darlingtonia::TitleValidator.new,
                        #RepresentativeFileValidator.new
                        ].freeze

      

  def records
    return enum_for(:records) unless block_given?
    file.rewind
    csv = CSV.table(file.path, {:headers => :first_row})
    headers = csv.headers
    raise "El campo identifier no es repetible, por favor solo utilize un identifier por registro" if headers.tally[:identifier] > 1
    csv.each_with_index do |r, i|
      row = {}
      next if r.to_h.values.all?(&:nil?)
      (0...headers.length).each do |j|
        column_header = headers[j]
        column_value = r[j].to_s
        next unless field_available(column_header) 
        next if column_value.blank? && update.nil?
        if column_header == :file_name || is_multiple(column_header)
          row[column_header] ||= row[column_header] = []
          # column_value = YAML.load(column_value) unless column_value.instance_of? Integer
          column_value = column_value.split("|").map(&:strip) # unless column_value.instance_of? Integer
          row[column_header].push(column_value) unless column_value.instance_of? Array
          row[column_header] = row[column_header] + column_value if column_value.instance_of? Array
        else
          row[column_header] = column_value.strip
        end 
      end 
      yield Darlingtonia::InputRecord.from(metadata: row, mapper: ColmexMapper.new)
    end
    
  rescue CSV::MalformedCSVError
    # error reporting for this case is handled by validation
    []
  end

  private

    def field_available(field)
      if field == :file_name
        return true 
      else
        return work.respond_to?(field)
      end
    end

    def is_multiple(field)
      return work.send(field).instance_of? ActiveTriples::Relation
    end
end
