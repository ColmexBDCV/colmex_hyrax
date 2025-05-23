# rubocop:disable Metrics/ClassLength
module Hyrax
  module Forms
    # @abstract
    class WorkForm
      include HydraEditor::Form
      include HydraEditor::Form::Permissions
      attr_accessor :current_ability

      # This is required so that fields_for will draw a nested form.
      # See ActionView::Helpers#nested_attributes_association?
      #   https://github.com/rails/rails/blob/v5.0.2/actionview/lib/action_view/helpers/form_helper.rb#L1890
      delegate :work_members_attributes=, :member_of_collections_attributes=, to: :model

      delegate :human_readable_type, :open_access?, :authenticated_only_access?,
               :open_access_with_embargo_release_date?, :private_access?,
               :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo,
               :visibility_during_lease, :lease_expiration_date, :visibility_after_lease,
               :visibility, :in_works_ids, :depositor, :on_behalf_of, :permissions,
               :member_ids, to: :model

      attr_reader :agreement_accepted

      self.terms = [:title, :alternate_title, :other_title, :date_created, :description, :creator,
                    :contributor, :has_creator, :subject, :subject_person, :subject_family, :subject_work, :subject_corporate,
                    :publisher, :language, :reviewer, :identifier, :keyword, :based_near, :subject_uniform_title, :thematic_collection,
                    :license, :rights_statement, :handle, :geographic_coverage, :temporary_coverage, :writer_of_suplementary_textual_content,
                    :gender_or_form, :notes, :classification, :has_organizer_corporate_body, :supplementary_content_or_bibliography, :bibliographic_citation,
                    :responsibility_statement, :other_related_persons, :system_requirements, :item_access_restrictions, :related_work_of_work,
                    :numbering_of_part, :table_of_contents, :doi, :isbn, :edition, :dimensions, :extension, :item_use_restrictions, :encoding_format_details,
                    :type_of_content, :editor, :compiler, :narrator, :commentator, :translator, :digital_resource_generation_information,
                    :interviewer, :interviewee, :draftsman, :organizer_collective_agent, :photographer, :collective_title, :part_of_place,
                    :provenance, :curator_collective_agent_of, :project, :owner_agent_of, :custodian_agent_of, :file_type_details, :has_system_of_organization,
                    :is_subcollection_of, :depository_collective_agent_of, :depository_agent, :type_of_illustrations, :center, :mode_of_issuance, :source,
                    :corporate_body, :collective_agent, :contained_in, :digital_file_characteristics, :has_field_activity_of_agent, :place_of_publication,
                    :related_url, :representative_id, :thumbnail_id, :rendering_ids, :files, :is_facsimile_of_manifestation_of, :beginning, :ending,
                    :visibility_during_embargo, :embargo_release_date, :visibility_after_embargo, :date_of_manifestation, :researcher_agent_of,
                    :visibility_during_lease, :lease_expiration_date, :visibility_after_lease, :collector_collective_agent, :language_of_expression,
                    :visibility, :ordered_member_ids, :in_works_ids, :organizer_collective_agent, :resource_access_restrictions, :resource_use_restrictions,
                    :manifestation_access_restrictions, :manifestation_use_restrictions, :note_on_statement_of_responsibility, :is_person_member_of_collective_agent,
                    :has_person_member_of_collective_agent, :member_of_collection_ids, :admin_set_id, :note_of_timespan, :local_resource_identifier,
                    :has_carrier_type, :has_transformation_by_genre, :is_transformation_by_genre, :is_dancer_agent_of]

      self.required_fields = [:title,
                              # :creator,
                              # :keyword,
                              # :rights_statement
                            ]

      # The service that determines the cardinality of each field
      self.field_metadata_service = Hyrax::FormMetadataService

      def initialize(model, current_ability, controller)
        @current_ability = current_ability
        @agreement_accepted = !model.new_record?
        @controller = controller
        super(model)
      end

      # when the add_works_to_collection parameter is set, they mean to create
      # a new work and add it to that collection.
      def member_of_collections
        base = model.member_of_collections
        return base unless @controller.params[:add_works_to_collection]
        base + [Collection.find(@controller.params[:add_works_to_collection])]
      end

      # @return [String] an etag representing the current version of this form
      def version
        model.etag
      end

      # backs the child work search element
      # @return [NilClass]
      def find_child_work; end

      def member_of_collections_json
        member_of_collections.map do |coll|
          {
            id: coll.id,
            label: coll.to_s,
            path: @controller.url_for(coll)
          }
        end.to_json
      end

      def work_members_json
        work_members.map do |child|
          {
            id: child.id,
            label: child.to_s,
            path: @controller.url_for(child)
          }
        end.to_json
      end

      # The value for some fields should not be set to the defaults ([''])
      # because it should be an empty array instead
      def initialize_field(key)
        return if [:embargo_release_date, :lease_expiration_date].include?(key)
        # rubocop:disable Lint/AssignmentInCondition
        if class_name = model_class.properties[key.to_s].try(:class_name)
          # Initialize linked properties such as based_near
          self[key] += [class_name.new]
        else
          super
        end
        # rubocop:enable Lint/AssignmentInCondition
      end

      # @param [Symbol] key the field to read
      # @return the value of the form field.
      def [](key)
        return model.member_of_collection_ids if key == :member_of_collection_ids
        super
      end

      # The possible values for the representative_id dropdown
      # @return [Hash] All file sets in the collection, file.to_s is the key, file.id is the value
      def select_files
        Hash[file_presenters.map { |file| [file.to_s, file.id] }]
      end

      ##
      # Fields that are automatically drawn on the page above the fold
      #
      # @return [Enumerable<Symbol>] symbols representing each primary term
      def primary_terms
        primary = (required_fields & terms)

        (required_fields - primary).each do |missing|
          Rails.logger.warn("The form field #{missing} is configured as a " \
                            'required field, but not as a term. This can lead ' \
                            'to unexpected behavior. Did you forget to add it ' \
                            "to `#{self.class}#terms`?")
        end

        primary
      end

      ##
      # Fields that are automatically drawn on the page below the fold
      #
      # @return [Enumerable<Symbol>]
      def secondary_terms
        terms - primary_terms -
          [:files, :visibility_during_embargo, :embargo_release_date,
           :visibility_after_embargo, :visibility_during_lease,
           :lease_expiration_date, :visibility_after_lease, :visibility,
           :thumbnail_id, :representative_id, :rendering_ids, :ordered_member_ids,
           :member_of_collection_ids, :in_works_ids, :admin_set_id]
      end

      # Do not display additional fields if there are no secondary terms
      # @return [Boolean] display additional fields on the form?
      def display_additional_fields?
        secondary_terms.any?
      end

      # @return [Array] a list of works that are members of the primary work on this form.
      def work_members
        model.works
      end

      # Get a list of collection id/title pairs for the select form
      def collections_for_select
        service = Hyrax::CollectionsService.new(@controller)
        CollectionOptionsPresenter.new(service).select_options(:edit)
      end
      deprecation_deprecate collections_for_select: "will be removed in Hyrax 3"

      # Sanitize the parameters coming from the form. This ensures that the client
      # doesn't send us any more parameters than we expect.
      # In particular we are discarding any access grant parameters for works that
      # are going into a mediated deposit workflow.
      def self.sanitize_params(form_params)
        admin_set_id = form_params[:admin_set_id]
        return super if admin_set_id && workflow_for(admin_set_id: admin_set_id).allows_access_grant?
        params_without_permissions = permitted_params.reject { |arg| arg.respond_to?(:key?) && arg.key?(:permissions_attributes) }
        form_params.permit(*params_without_permissions)
      end

      # This describes the parameters we are expecting to receive from the client
      # @return [Array] a list of parameters used by sanitize_params
      def self.build_permitted_params
        super + [
          :on_behalf_of,
          :version,
          :add_works_to_collection,
          {
            based_near_attributes: [:id, :_destroy],
            member_of_collections_attributes: [:id, :_destroy],
            work_members_attributes: [:id, :_destroy]
          }
        ]
      end

      # TODO: This method should probably move out of this class
      # @param [String] admin_set_id
      # @return Sipity::Workflow the current active workflow for the given AdminSet
      def self.workflow_for(admin_set_id:)
        begin
          workflow = Hyrax::PermissionTemplate.find_by!(source_id: admin_set_id).active_workflow
        rescue ActiveRecord::RecordNotFound
          raise "Missing permission template for AdminSet(id:#{admin_set_id})"
        end
        raise Hyrax::MissingWorkflowError, "PermissionTemplate for AdminSet(id:#{admin_set_id}) does not have an active_workflow" unless workflow
        workflow
      end
      private_class_method :workflow_for

      private

        # @return [Array<FileSetPresenter>] presenters for the file sets in order of the ids
        def file_presenters
          @file_sets ||=
            Hyrax::PresenterFactory.build_for(ids: model.member_ids,
                                              presenter_class: FileSetPresenter,
                                              presenter_args: current_ability)
        end
    end
  end
end
# rubocop:enable Metrics/ClassLength
