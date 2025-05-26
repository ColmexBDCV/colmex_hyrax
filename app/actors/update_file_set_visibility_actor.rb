# app/actors/hyrax/actors/update_fileset_visibility_actor.rb

class UpdateFileSetVisibilityActor < Hyrax::Actors::AbstractActor
  def update(env)
    result = next_actor.update(env)

    work = env.curation_concern
    return result unless work.respond_to?(:item_access_restrictions)

    target_visibility = work.item_access_restrictions.present? ? 'restricted' : 'open'

    work.file_sets.each do |fs|
      next if fs.visibility == target_visibility

      fs.visibility = target_visibility
      fs.save(validate: false)
    end

    result
  end

end
