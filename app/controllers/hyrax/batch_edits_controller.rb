# frozen_string_literal: true
module Hyrax
  class BatchEditsController < ApplicationController
    include FileSetHelper
    include Hyrax::Breadcrumbs
    include Hyrax::Collections::AcceptsBatches
    include VisibilityParamsHandler

    before_action :build_breadcrumbs, only: :edit
    before_action :filter_docs_with_access!, only: [:edit, :update, :destroy_collection]
    before_action :check_for_empty!, only: [:edit, :update, :destroy_collection]

    # provides the help_text view method
    helper PermissionsHelper

    with_themed_layout 'dashboard'

    def edit
      work = form_class.model_class.new
      work.depositor = current_user.user_key
      @form = form_class.new(work, current_user, batch)
    end

    def after_update
      respond_to do |format|
        format.json { head :no_content }
        format.html { redirect_to_return_controller }
      end
    end

    def after_destroy_collection
      redirect_back fallback_location: hyrax.batch_edits_path
    end

    def check_for_empty!
      return unless check_for_empty_batch?
      redirect_back fallback_location: hyrax.batch_edits_path
      false
    end

    def destroy_collection
      batch.each do |doc_id|
        resource = Hyrax.query_service.find_by(id: Valkyrie::ID.new(doc_id))
        transactions['collection_resource.destroy']
          .with_step_args('collection_resource.delete' => { user: current_user })
          .call(resource)
          .value!
      end
      flash[:notice] = "Batch delete complete"
      after_destroy_collection
    end

    def process_batch_update(batch_ids)
      batch_ids.each do |doc_id|
        begin
          obj = Hyrax.query_service.find_by_alternate_identifier(alternate_identifier: doc_id, use_valkyrie: false)
          update_document(obj)
        rescue => e
          logger.error "Error procesando #{doc_id}: #{e.message}"
        end
      end
    end

    def update_document(obj)
      interpret_visiblity_params(obj)
      obj.attributes = work_params(admin_set_id: obj.admin_set_id).except(*visibility_params)
      obj.date_modified = Time.current.ctime

      if obj.save
        InheritPermissionsJob.perform_later(obj, use_valkyrie: false)
        VisibilityCopyJob.perform_later(obj)
        true
      else
        logger.error "Error guardando #{obj.id}: #{obj.errors.full_messages}"
        false
      end
    end

    def update
      case params["update_type"]
      when "update"
        if params[:async] == "true"
          # Encolar job para procesamiento asíncrono
          BatchUpdateJob.perform_later(
            batch.to_a,
            work_params.to_h,
            current_user.id
          )
          flash[:notice] = "Actualización por lotes en segundo plano iniciada"
          after_update
        else
          # Procesamiento sincrónico (para debugging)
          process_batch_update(batch)
          after_update
        end
      when "delete_all"
        destroy_batch
      end
    end

    def set_current_user(user)
      @current_user = user
    end

    private

    def add_breadcrumb_for_controller
      add_breadcrumb I18n.t('hyrax.dashboard.my.works'), hyrax.my_works_path
    end

    def _prefixes
      # This allows us to use the templates in hyrax/base, while prefering
      # our local paths. Thus we are unable to just override `self.local_prefixes`
      @_prefixes ||= super + ['hyrax/base']
    end

    def destroy_batch
      batch.each do |id|
        resource = Hyrax.query_service.find_by(id: Valkyrie::ID.new(id))
        transactions['work_resource.destroy']
          .with_step_args('work_resource.delete' => { user: current_user })
          .call(resource)
          .value!
      end
      after_update
    end

    def form_class
      Forms::BatchEditForm
    end

    def terms
      form_class.terms
    end

    def work_params(extra_params = {})
      work_params = params[form_class.model_name.param_key] || ActionController::Parameters.new
      form_class.model_attributes(work_params.merge(extra_params))
    end

    def interpret_visiblity_params(obj)
      stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
        middleware.use Hyrax::Actors::InterpretVisibilityActor
      end
      env = Hyrax::Actors::Environment.new(obj, current_ability, work_params(admin_set_id: obj.admin_set_id))
      last_actor = Hyrax::Actors::Terminator.new
      stack.build(last_actor).update(env)
    end

    def visibility_params
      ['visibility',
       'lease_expiration_date',
       'visibility_during_lease',
       'visibility_after_lease',
       'embargo_release_date',
       'visibility_during_embargo',
       'visibility_after_embargo']
    end

    def redirect_to_return_controller
      if params[:return_controller]
        redirect_to hyrax.url_for(controller: params[:return_controller], only_path: true)
      else
        redirect_to hyrax.dashboard_path
      end
    end
  end
end
