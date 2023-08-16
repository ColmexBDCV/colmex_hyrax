# frozen_string_literal: true
module Hyrax
  module Forms
    # rubocop:disable Metrics/ClassLength
    class CollectionForm
      include HydraEditor::Form
      include HydraEditor::Form::Permissions
      # Used by the search builder
      attr_reader :scope

      delegate :id, :depositor, :permissions, :human_readable_type, :member_ids, :nestable?,
               :alternative_title, :visibility, to: :model

      class_attribute :membership_service_class

      # Required for search builder (FIXME)
      alias collection model

      self.model_class = Hyrax.config.collection_class

      self.membership_service_class = Collections::CollectionMemberSearchService

      delegate :blacklight_config, to: Hyrax::CollectionsController

      self.terms = [:title, :alternate_title, :other_title, :date_created, :description, :creator, 
        :contributor, :has_creator, :subject, :subject_person, :subject_family, :subject_work, :subject_corporate,
        :publisher, :language, :reviewer, :identifier, :keyword, :based_near, :subject_uniform_title, :thematic_collection,
        :license, :rights_statement, :handle, :geographic_coverage, :temporary_coverage, :writer_of_suplementary_textual_content,
        :gender_or_form, :notes, :classification, :supplementary_content_or_bibliography, :bibliographic_citation,
        :responsibility_statement, :other_related_persons, :system_requirements, :item_access_restrictions, :related_work_of_work, 
        :numbering_of_part, :table_of_contents, :doi, :isbn, :edition, :dimensions, :extension, :item_use_restrictions, :encoding_format_details,
        :type_of_content, :editor, :compiler, :narrator, :commentator, :translator, :digital_resource_generation_information,
        :interviewer, :interviewee, :draftsman, :organizer_collective_agent, :photographer, :collective_title, :part_of_place, 
        :provenance, :curator_collective_agent_of, :project, :owner_agent_of, :custodian_agent_of, :file_type_details, :has_system_of_organization,
        :is_subcollection_of, :depository_collective_agent_of, :depository_agent, :type_of_illustrations, :center, :mode_of_issuance, :source,  
        :corporate_body, :collective_agent, :contained_in, :digital_file_characteristics, :has_field_activity_of_agent, :place_of_publication,
        :related_url, :is_facsimile_of_manifestation_of, :beginning, :ending, 
        :date_of_manifestation, :researcher_agent_of, :thumbnail_id,
        :collector_collective_agent, :language_of_expression,
        :visibility, :organizer_collective_agent, :resource_access_restrictions, :resource_use_restrictions,
        :manifestation_access_restrictions, :manifestation_use_restrictions, :note_on_statement_of_responsibility,
        :note_of_timespan, :resource_type, :collection_type_gid]

      self.required_fields = [:title]

      ProxyScope = Struct.new(:current_ability, :repository, :blacklight_config) do
        def can?(*args)
          current_ability.can?(*args)
        end
      end

      # @param model [::Collection] the collection model that backs this form
      # @param current_ability [Ability] the capabilities of the current user
      # @param repository [Blacklight::Solr::Repository] the solr repository
      def initialize(model, current_ability, repository)
        super(model)
        @scope = ProxyScope.new(current_ability, repository, blacklight_config)
      end

      def permission_template
        @permission_template ||= begin
                                   template_model = PermissionTemplate.find_or_create_by(source_id: model.id)
                                   PermissionTemplateForm.new(template_model)
                                 end
      end

      # @return [Hash] All FileSets in the collection, file.to_s is the key, file.id is the value
      def select_files
        Hash[all_files_with_access]
      end

      # Terms that appear above the accordion
      def primary_terms
        [:title, :description]
      end

      # Terms that appear within the accordion
      def secondary_terms
        [:alternate_title, :other_title, :date_created, :description, :creator, 
          :contributor, :has_creator, :subject, :subject_person, :subject_family, :subject_work, :subject_corporate,
          :publisher, :language, :reviewer, :identifier, :keyword, :based_near, :subject_uniform_title, :thematic_collection,
          :license, :rights_statement, :handle, :geographic_coverage, :temporary_coverage, :writer_of_suplementary_textual_content,
          :gender_or_form, :notes, :classification, :supplementary_content_or_bibliography, :bibliographic_citation,
          :responsibility_statement, :other_related_persons, :system_requirements, :item_access_restrictions, :related_work_of_work, 
          :numbering_of_part, :table_of_contents, :doi, :isbn, :edition, :dimensions, :extension, :item_use_restrictions, :encoding_format_details,
          :type_of_content, :editor, :compiler, :narrator, :commentator, :translator, :digital_resource_generation_information,
          :interviewer, :interviewee, :draftsman, :organizer_collective_agent, :photographer, :collective_title, :part_of_place, 
          :provenance, :curator_collective_agent_of, :project, :owner_agent_of, :custodian_agent_of, :file_type_details, :has_system_of_organization,
          :is_subcollection_of, :depository_collective_agent_of, :depository_agent, :type_of_illustrations, :center, :mode_of_issuance, :source,  
          :corporate_body, :collective_agent, :contained_in, :digital_file_characteristics, :has_field_activity_of_agent, :place_of_publication,
          :related_url, :is_facsimile_of_manifestation_of, :beginning, :ending, 
          :date_of_manifestation, :researcher_agent_of, :thumbnail_id,
          :collector_collective_agent, :language_of_expression,
          :visibility, :organizer_collective_agent, :resource_access_restrictions, :resource_use_restrictions,
          :manifestation_access_restrictions, :manifestation_use_restrictions, :note_on_statement_of_responsibility,
          :note_of_timespan, :resource_type,]
      end

      def banner_info
        @banner_info ||= begin
          # Find Banner filename
          banner_info = CollectionBrandingInfo.where(collection_id: id, role: "banner")
          banner_file = File.split(banner_info.first.local_path).last unless banner_info.empty?
          alttext = banner_info.first.alt_text unless banner_info.empty?
          file_location = banner_info.first.local_path unless banner_info.empty?
          relative_path = "/" + banner_info.first.local_path.split("/")[-4..-1].join("/") unless banner_info.empty?
          { file: banner_file, full_path: file_location, relative_path: relative_path, alttext: alttext }
        end
      end

      def logo_info
        @logo_info ||= begin
          # Find Logo filename, alttext, linktext
          logos_info = CollectionBrandingInfo.where(collection_id: id, role: "logo")

          logos_info.map do |logo_info|
            logo_file = File.split(logo_info.local_path).last
            relative_path = "/" + logo_info.local_path.split("/")[-4..-1].join("/")
            alttext = logo_info.alt_text
            linkurl = logo_info.target_url
            { file: logo_file, full_path: logo_info.local_path, relative_path: relative_path, alttext: alttext, linkurl: linkurl }
          end
        end
      end

      # Do not display additional fields if there are no secondary terms
      # @return [Boolean] display additional fields on the form?
      def display_additional_fields?
        secondary_terms.any?
      end

      def thumbnail_title
        return unless model.thumbnail
        model.thumbnail.title.first
      end

      def list_parent_collections
        collection.member_of_collections
      end

      def list_child_collections
        collection_member_service.available_member_subcollections.documents
      end

      ##
      # @deprecated this implementation requires an extra db round trip, had a
      #   buggy cacheing mechanism, and was largely duplicative of other code.
      #   all versions of this code are replaced by
      #   {CollectionsHelper#available_parent_collections_data}.
      def available_parent_collections(scope:)
        return @available_parents if @available_parents.present?

        collection = model_class.find(id)
        colls = Hyrax::Collections::NestedCollectionQueryService.available_parent_collections(child: collection, scope: scope, limit_to_id: nil)
        @available_parents = colls.map do |col|
          { "id" => col.id, "title_first" => col.title.first }
        end.to_json
      end

      private

      def all_files_with_access
        member_presenters(member_work_ids).flat_map(&:file_set_presenters).map { |x| [x.to_s, x.id] }
      end

      # Override this method if you have a different way of getting the member's ids
      def member_work_ids
        response = collection_member_service.available_member_work_ids.response
        response.fetch('docs').map { |doc| doc['id'] }
      end

      def collection_member_service
        @collection_member_service ||= membership_service_class.new(scope: scope, collection: collection, params: blacklight_config.default_solr_params)
      end

      def member_presenters(member_ids)
        PresenterFactory.build_for(ids: member_ids,
                                   presenter_class: WorkShowPresenter,
                                   presenter_args: [nil])
      end
    end
    # rubocop:enable Metrics/ClassLength
  end
end
