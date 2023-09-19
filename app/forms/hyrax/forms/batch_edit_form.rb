# frozen_string_literal: true
module Hyrax
  module Forms
    class BatchEditForm < Hyrax::Forms::WorkForm
      # Used for drawing the fields that appear on the page
      self.terms = [
        :resource_type, :creator, :contributor, :has_creator, :description, :keyword,
        :license, :thematic_collection, :rights_statement, :publisher, :date_created,
        :subject, :subject_person, :subject_family, :subject_work, :subject_corporate,
        :language, :based_near, :geographic_coverage, :temporary_coverage,
        :gender_or_form, :related_url, :bibliographic_citation, :source, :related_work_of_work,
        :numbering_of_part, :notes, :center, :classification,
        :supplementary_content_or_bibliography, :responsibility_statement, :other_related_persons,
        :table_of_contents, :type_of_content, :type_of_illustrations, :language_of_expression,
        :reviewer, :organizer, :editor, :compiler, :commentator, :translator,
        :mode_of_issuance, :edition, :dimensions, :extension, :system_requirements,
        :encoding_format_details, :digital_resource_generation_information, :contained_in,
        :collector_collective_agent, :researcher_agent_of, :has_system_of_organization,
        :is_subcollection_of, :interviewer, :interviewee, :draftsman, :photographer,
        :narrator, :collective_title, :part_of_place, :provenance, :curator_collective_agent_of,
        :project, :owner_agent_of, :custodian_agent_of, :depository_collective_agent_of,
        :depository_agent, :file_type_details, :corporate_body, :collective_agent,
        :digital_file_characteristics, :writer_of_suplementary_textual_content,
        :organizer_collective_agent, :has_field_activity_of_agent, :place_of_publication,
        :is_facsimile_of_manifestation_of, :beginning, :ending, :date_of_manifestation,
        :subject_uniform_title, :resource_access_restrictions, :resource_use_restrictions,
        :manifestation_access_restrictions, :manifestation_use_restrictions, :item_access_restrictions,
        :item_use_restrictions, :note_of_timespan, :note_on_statement_of_responsibility
      ]
      self.required_fields = []
      self.model_class = Hyrax.primary_work_type

      # Contains a list of titles of all the works in the batch
      attr_accessor :names

      # @param [ActiveFedora::Base] model the model backing the form
      # @param [Ability] current_ability the user authorization model
      # @param [Array<String>] batch_document_ids a list of document ids in the batch
      def initialize(model, current_ability, batch_document_ids)
        @names = []
        @batch_document_ids = batch_document_ids
        @combined_attributes = initialize_combined_fields
        super(model, current_ability, nil)
      end

      attr_reader :batch_document_ids

      # Returns a list of parameters we accept from the form
      # rubocop:disable Metrics/MethodLength
      def self.build_permitted_params
        [{ resource_type: [] },
        { creator: [] },
        { contributor: [] },
        { has_creator: [] },
        { description: [] },
        { keyword: [] },
        { license: [] },
        { thematic_collection: [] },
        { rights_statement: [] },
        { publisher: [] },
        { date_created: [] },
        { subject: [] },
        { subject_person: [] },
        { subject_family: [] },
        { subject_work: [] },
        { subject_corporate: [] },
        { language: [] },
        { based_near: [] },
        { geographic_coverage: [] },
        { temporary_coverage: [] },
        { gender_or_form: [] },
        { related_url: [] },
        { bibliographic_citation: [] },
        { source: [] },
        { related_work_of_work: [] },
        { notes: [] },
        { center: [] },
        { classification: [] },
        { supplementary_content_or_bibliography: [] },
        { responsibility_statement: [] },
        { other_related_persons: [] },
        { table_of_contents: [] },
        { type_of_content: [] },
        { type_of_illustrations: [] },
        { language_of_expression: [] },
        { reviewer: [] },
        { organizer: [] },
        { editor: [] },
        { compiler: [] },
        { commentator: [] },
        { translator: [] },
        { edition: [] },
        { encoding_format_details: [] },
        { digital_resource_generation_information: [] },
        { contained_in: [] },
        { collector_collective_agent: [] },
        { researcher_agent_of: [] },
        { has_system_of_organization: [] },
        { is_subcollection_of: [] },
        { interviewer: [] },
        { interviewee: [] },
        { draftsman: [] },
        { photographer: [] },
        { narrator: [] },
        { collective_title: [] },
        { part_of_place: [] },
        { provenance: [] },
        { curator_collective_agent_of: [] },
        { project: [] },
        { owner_agent_of: [] },
        { custodian_agent_of: [] },
        { depository_collective_agent_of: [] },
        { depository_agent: [] },
        { file_type_details: [] },
        { corporate_body: [] },
        { collective_agent: [] },
        { digital_file_characteristics: [] },
        { writer_of_suplementary_textual_content: [] },
        { organizer_collective_agent: [] },
        { has_field_activity_of_agent: [] },
        { place_of_publication: [] },
        { is_facsimile_of_manifestation_of: [] },
        { resource_access_restrictions: [] },
        { resource_use_restrictions: [] },
        { manifestation_access_restrictions: [] },
        { manifestation_use_restrictions: [] },
        { item_access_restrictions: [] },
        { item_use_restrictions: [] },
        { note_of_timespan: [] },
        { note_on_statement_of_responsibility: [] },
        { permissions_attributes: [:type, :name, :access, :id, :_destroy] },
        :on_behalf_of,
        :version,
        :add_works_to_collection,
        :visibility_during_embargo,
        :embargo_release_date,
        :visibility_after_embargo,
        :visibility_during_lease,
        :lease_expiration_date,
        :visibility_after_lease,
        :visibility,
        :mode_of_issuance,
        :dimensions,
        :extension,
        :system_requirements,
        :numbering_of_part,
        :beginning,
        :ending,
        :date_of_manifestation,
        subject_uniform_title,
        { based_near_attributes: [:id, :_destroy] }
      ]
      end
      # rubocop:enable Metrics/MethodLength

      private

      attr_reader :combined_attributes

      # override this method if you need to initialize more complex RDF assertions (b-nodes)
      # @return [Hash<String, Array>] the list of unique values per field
      def initialize_combined_fields
        # For each of the files in the batch, set the attributes to be the concatenation of all the attributes
        batch_document_ids.each_with_object({}) do |doc_id, combined_attributes|
          work = Hyrax.query_service.find_by(id: doc_id)
          terms.each do |field|
            combined_attributes[field] ||= []
            combined_attributes[field] = (combined_attributes[field] + work[field].to_a).uniq
          end
          names << work.to_s
        end
      end

      def initialize_field(key)
        # if value is empty, we create an one element array to loop over for output
        return model[key] = combined_attributes[key] if combined_attributes[key].present?
        super
      end
    end
  end
end
