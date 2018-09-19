# frozen_string_literal: true

##
# A `Darlingtonia::RecordImporter` that processes files and passes new works
# through the Actor Stack for creation.
class ColmexRecordImporter < Darlingtonia::RecordImporter
  ##
  # @!attribute [rw] creator
  #   @return [User]
  # @!attribute [rw] file_path
  #   @return [String]
  attr_accessor :creator, :file_path, :work

  ##
  # @param file_path [String]
  # @param creator   [User]
  def initialize(**opts)
    self.creator   = opts.delete(:creator)   || raise(ArgumentError)
    self.file_path = opts.delete(:file_path) || raise(ArgumentError)
    self.work = opts.delete(:work) || raise(ArgumentError)
    super
  end

  private

    ##
    # @private
    def embargo_attributes(attributes, record)
      if record.respond_to?(:embargo_release_date)
        date = record.embargo_release_date.first
        # records with an embargo Magic date of 9999-12-31
        # are meant to be private, but NOT embargoed.
        if Date.parse(date) < Date.parse('9999-12-31 00:00')
          attributes[:visibility_during_embargo] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          attributes[:embargo_release_date] = date
          attributes[:visibility_after_embargo] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          attributes[:visibility_during_lease] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
          attributes[:lease_expiration_date] = date
          attributes[:visibility_after_lease] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PRIVATE
          # Hyrax expects visibility to be "embargo"
          attributes[:visibility] = "embargo"
        end
      else
        # no embargo, and visibility AccessControls are public
        attributes[:visibility] = Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
      end
    end

    def create_for(record:)
      info_stream << 'Creating record: ' \
                     "#{record.respond_to?(:title) ? record.title : record}."
      created    = import_type.new
      attributes = record.attributes
      attributes[:uploaded_files] = [file_for(record.representative_file)] if record.representative_file
      embargo_attributes(attributes, record)
      
      actor_env = Hyrax::Actors::Environment.new(created,
                                                 ::Ability.new(creator),
                                                 attributes)
      
      Hyrax::CurationConcern.actor.create(actor_env)

      info_stream << "Record created at: #{created.id}"
    rescue Errno::ENOENT => e
      error_stream << e.message
    end

    def file_for(filenames)
      ids = []
      filenames.each do |filename|
        ids.push Hyrax::UploadedFile.create(file: File.open(file_path + filename), user: creator).id
      end
      return ids
    end

    def import_type
      raise 'No curation_concern found for import' unless
        defined?(Hyrax) && Hyrax&.config&.curation_concerns&.any?
      
      Hyrax.config.curation_concerns.each_with_index do |tw, i|
        
        if tw.name == work
          return Hyrax.config.curation_concerns[i]
        end
      end

    end

end