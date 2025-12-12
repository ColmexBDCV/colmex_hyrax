module Hyrax
  module FileSetActorStackOverride
    def file_set_create_actor
      @file_set_create_actor ||= build_file_set_actor_stack(include_base_actor: false)
    end

    def file_set_update_actor
      @file_set_update_actor ||= build_file_set_actor_stack(include_base_actor: true)
    end

    private

    def build_file_set_actor_stack(include_base_actor:)
      stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
        middleware.use ::FileSetRecordChangeActor
        middleware.use Hyrax::Actors::InterpretVisibilityActor
        middleware.use Hyrax::Actors::BaseActor if include_base_actor
      end
      stack.build(Hyrax::Actors::Terminator.new)
    end
  end
end

Rails.application.config.to_prepare do
  concern = Hyrax::CurationConcern
  singleton = concern.singleton_class

  unless singleton.ancestors.include?(Hyrax::FileSetActorStackOverride)
    singleton.prepend(Hyrax::FileSetActorStackOverride)
  end

  if singleton.instance_variable_defined?(:@file_set_create_actor)
    singleton.send(:remove_instance_variable, :@file_set_create_actor)
  end
  if singleton.instance_variable_defined?(:@file_set_update_actor)
    singleton.send(:remove_instance_variable, :@file_set_update_actor)
  end
end
