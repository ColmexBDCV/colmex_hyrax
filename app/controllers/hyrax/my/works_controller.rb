# frozen_string_literal: true
module Hyrax
  module My
    class WorksController < MyController
      # Define collection specific filter facets.
      def self.configure_facets
        configure_blacklight do |config|
          config.search_builder_class = Hyrax::My::WorksSearchBuilder
          config.add_facet_field solr_name("human_readable_type", :facetable), label: "Type", limit: 5
          config.add_facet_field "admin_set_sim", limit: 5
          config.add_facet_field "member_of_collections_ssim", limit: 5
          config.add_facet_field "date_created_sim", limit: 5
          config.add_facet_field "creator_sim", limit: 5
          config.add_facet_field "contributor_sim", limit: 5
          config.add_facet_field "center_sim", limit: 5
          config.add_facet_field "director_sim", limit: 5
          config.add_facet_field "editor_sim", limit: 5
          config.add_facet_field "organizer_sim", limit: 5
          config.add_facet_field "compiler_sim", limit: 5
          config.add_facet_field "commentator_sim", limit: 5
          config.add_facet_field "reviewer_sim", limit: 5
          config.add_facet_field "traslator_sim", limit: 5
          config.add_facet_field "interviewer_sim", limit: 5
          config.add_facet_field "interviewee_sim", limit: 5
          config.add_facet_field "draftsman_sim", limit: 5
          config.add_facet_field "organizer_collective_agent_sim", limit: 5
          config.add_facet_field "place_of_publication_sim", limit: 5
          config.add_facet_field "related_work_of_work_sim", limit: 5
          config.add_facet_field "subject_work_sim", limit: 5
          config.add_facet_field "subject_person_sim", limit: 5
          config.add_facet_field "subject_corporate_sim", limit: 5
          config.add_facet_field "subject_sim", limit: 5
          config.add_facet_field "language_sim", limit: 5
          config.add_facet_field "based_near_label_sim", limit: 5
          config.add_facet_field "geographic_coverage_sim", limit: 5
          config.add_facet_field "temporary_coverage_sim", limit: 5
          config.add_facet_field "publisher_sim", limit: 5
          config.add_facet_field "source_sim", limit: 5
          config.add_facet_field "file_format_sim", limit: 5
          
          config.add_facet_field "degree_program_sim", limit: 5
          config.add_facet_field "type_of_illustrations_sim", limit: 5
          config.add_facet_field "contained_in_sim", limit: 5

          config.add_facet_field "researcher_agent_of_sim", limit: 5
          config.add_facet_field "guide_to_work_sim", limit: 5
          config.add_facet_field "production_method_sim", limit: 5
          config.add_facet_field "longitud_and_latitud_sim", limit: 5
          config.add_facet_field "digital_representation_of_cartographic_content_sim", limit: 5
          config.add_facet_field "related_place_of_timespan_sim", limit: 5
          config.add_facet_field "note_of_timespan_sim", limit: 5
          config.add_facet_field "is_part_or_work_sim", limit: 5
          config.add_facet_field "alternative_numeric_and_or_alphabethic_designation_and_or_alphabethic_designation_sim", limit: 5
          config.add_facet_field "photographer_sim", limit: 5
          config.add_facet_field "narrator_sim", limit: 5
          config.add_facet_field "writer_of_suplementary_textual_content_sim", limit: 5
          config.add_facet_field "photographer_corporate_body_of_work_sim", limit: 5
          config.add_facet_field "dimensions_of_still_image_sim", limit: 5
          config.add_facet_field "numbering_of_part_sim", limit: 5
          config.add_facet_field "speaker_agent_of_sim", limit: 5
          config.add_facet_field "assistant_sim", limit: 5
          config.add_facet_field "preceded_by_work_sim", limit: 5
          config.add_facet_field "primary_topic_sim", limit: 5
          config.add_facet_field "enacting_juridiction_of_sim", limit: 5
          config.add_facet_field "hierarchical_superior_sim", limit: 5
          config.add_facet_field "hierarchical_inferior_sim", limit: 5
          config.add_facet_field "subject_timespan_sim", limit: 5
          config.add_facet_field "is_title_of_item_of_sim", limit: 5
          config.add_facet_field "timespan_described_in_sim", limit: 5
          config.add_facet_field "related_person_of_sim", limit: 5
          config.add_facet_field "related_corporate_body_of_timespan_sim", limit: 5
          config.add_facet_field "related_family_timespan_sim", limit: 5
          config.add_facet_field "complainant_sim", limit: 5
          config.add_facet_field "contestee_sim", limit: 5
          config.add_facet_field "witness_sim", limit: 5
          config.add_facet_field "is_criminal_defendant_corporate_body_of_sim", limit: 5
          config.add_facet_field "is_criminal_defendant_person_of_sim", limit: 5
          config.add_facet_field "collector_collective_agent_sim", limit: 5   
          config.add_facet_field "subject_uniform_title_sim", limit: 5
          config.add_facet_field "thematic_collection_sim", limit: 5
          config.add_facet_field "has_system_of_organization_sim", limit: 5
          config.add_facet_field "is_subcollection_of_sim", limit: 5
          config.add_facet_field "depository_collective_agent_of_sim", limit: 5
          config.add_facet_field "corporate_body_sim", limit: 5
          config.add_facet_field "beginning_sim", limit: 5
          config.add_facet_field "ending_sim", limit: 5
        end
      end
      configure_facets

      class_attribute :create_work_presenter_class
      self.create_work_presenter_class = Hyrax::SelectTypeListPresenter

      def index
        
        # The user's collections for the "add to collection" form
        @user_collections = collections_service.search_results(:deposit)

        add_breadcrumb t(:'hyrax.controls.home'), root_path
        add_breadcrumb t(:'hyrax.dashboard.breadcrumbs.admin'), hyrax.dashboard_path
        add_breadcrumb t(:'hyrax.admin.sidebar.works'), hyrax.my_works_path
        managed_works_count
        @create_work_presenter = create_work_presenter_class.new(current_user)
        super
        
      end

      private

      def collections_service
        Hyrax::CollectionsService.new(self)
      end

      def search_action_url(*args)
        hyrax.my_works_url(*args)
      end

      # The url of the "more" link for additional facet values
      def search_facet_path(args = {})
        hyrax.my_dashboard_works_facet_path(args[:id])
      end

      def managed_works_count
        @managed_works_count = Hyrax::Works::ManagedWorksService.managed_works_count(scope: self)
      end
    end
  end
end
