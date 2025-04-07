module VisibilityParamsHandler
  extend ActiveSupport::Concern

  def interpret_visibility_params(obj, params, ability)
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use Hyrax::Actors::InterpretVisibilityActor
    end
    env = Hyrax::Actors::Environment.new(obj, ability, params)
    last_actor = Hyrax::Actors::Terminator.new
    stack.build(last_actor).update(env)
  end

  def visibility_params
    ['visibility', 'lease_expiration_date', 'visibility_during_lease', 'visibility_after_lease',
     'embargo_release_date', 'visibility_during_embargo', 'visibility_after_embargo']
  end
end
