# frozen_string_literal: true

##
# A validator to ensures that each imported record has an import
class RepresentativeFileValidator < Darlingtonia::Validator
  def self.config
    Rails.application.config_for(:importer)
  end
  
  def config
    self.class.config
  end

  private

    ##
    # @private
    def run_validation(parser:)
      parser.records.each_with_object([]) do |record, errors|
        if record.representative_file.blank?
          errors <<
            Error.new(self, :missing_file, missing_message_for(record: record))
        else
          filenames = record.representative_file
          # next if File.exist?(path_for(filename: filename))
          next if path_for(filenames: filenames) 
            errors <<
            Error.new(self,
                      :file_not_readable,
                      not_readable_message_for(filenames: filenames))
        end
      end
    end

    def missing_message_for(record:)
      "No `file_name` value is present for imported record: #{record.title}\n" \
      "\tEach record must have a representative file to be successfully imported."
    end

    def not_readable_message_for(filenames:)
      msg = ""
      filenames.each do |filename| 
        msg +="\nNo file was found on disk for file: " + config['file_path']+filename
      end
      return msg
    end

    def path_for(filenames:)
      # "spec/fixtures/#{filename}"
      filenames.each do |filename| 
        return false unless File.exist?(config['file_path']+filename)
      end
      return true
    end
end
