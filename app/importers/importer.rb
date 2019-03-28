# frozen_string_literal: true
class Importer < Darlingtonia::Importer
  ##
  # @return [Hash<Symbol, Object>]
  def self.config
    Rails.application.config_for(:importer)
  end

  attr_accessor :parser, :record_importer, :work, :collection, :update

  def initialize(parser:, work:, collection: nil, update: nil, info_stream: Darlingtonia.config.default_info_stream, error_stream: Darlingtonia.config.default_error_stream )
    self.work = work
    self.collection = collection.nil? ? "" : collection 
    self.parser          = parser
    self.update = update ? true : nil
    self.record_importer = default_record_importer
    @info_stream = info_stream
    @error_stream = error_stream
    # record_importer: default_record_importer
    # super
  end

  def config
    self.class.config
  end

  def import
    records.each { |record| record_importer.import(record: record) }
    #@info_stream << "event: finish_import, batch_id: #{record_importer.batch_id}, successful_record_count: #{record_importer.success_count}, failed_record_count: #{record_importer.failure_count}"
    @info_stream << "\n\nFinish\n\n"

  end

  private

    def default_creator
      User.find_or_create_system_user(config['user_key'])
    end

    def default_record_importer
      ColmexRecordImporter.new(creator:   default_creator,
                                file_path: config['file_path'],
                                work: work,
                                collection: collection,
                                update: update
                                )
    end
   
end
