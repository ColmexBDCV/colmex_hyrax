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
    CreateHandleJob.perform_later()
  end

  def initialize_collection()
    coll = Collection.where(title: collection).first
    coll.reindex_extent = Hyrax::Adapters::NestingIndexAdapter::LIMITED_REINDEX
    self.collection = coll
  end

  def get_record_objects()
    
    works = []
    records.each do |record|  
      wt = work.singularize.classify.constantize.where(identifier: record.identifier).first
      works << wt unless wt.nil?
    end
    return works
  end

  def get_record_ids()
    work_ids = []
    get_record_objects.each do |w|
      work_ids << w.id
    end
    return work_ids
  end

  def to_collection_add()
    initialize_collection
    collection.add_member_objects(get_record_ids) unless collection.nil?
  end

  def from_collection_remove()
    initialize_collection
    unless collection.nil? then
      get_record_objects.each do |r|
        r.member_of_collections.delete(collection)
        r.save
      end
    end
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