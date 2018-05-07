# frozen_string_literal: true
class Importer < Darlingtonia::Importer
  ##
  # @return [Hash<Symbol, Object>]
  def self.config
    Rails.application.config_for(:importer)
  end

  attr_accessor :parser, :record_importer, :work

  def initialize(parser:, work: )
    self.work = work
    self.parser          = parser
    self.record_importer = default_record_importer
    # record_importer: default_record_importer
    # super
  end

  def config
    self.class.config
  end

  private

    def default_creator
      User.find_or_create_system_user(config['user_key'])
    end

    def default_record_importer
      ColmexRecordImporter.new(creator:   default_creator,
                                file_path: config['file_path'],
                                work: work
                                )
    end
end
