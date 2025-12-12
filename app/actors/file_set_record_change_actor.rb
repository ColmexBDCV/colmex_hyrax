class FileSetRecordChangeActor < Hyrax::Actors::AbstractActor
  def create(env)
    log_relevant_changes(env)
    next_actor.create(env)
  end

  def update(env)
    log_relevant_changes(env)
    next_actor.update(env)
  end

  private

  def log_relevant_changes(env)
    file_set = env.curation_concern
    persisted = persisted_record_for(file_set)
    work_id = parent_id_for(file_set)
    changes = {file_set: "#{file_set.id} - #{file_set.label}"}
        
    visibility_change = build_visibility_change(env, file_set, persisted)
    changes.merge!(visibility_change) if visibility_change.present?

    title_change = build_title_change(env, file_set, persisted)
    changes.merge!(title_change) if title_change.present?

    return if changes.empty?

    RecordChangeLog.create(
      change: changes.to_json,
      user: env.user,
      template: file_set.class.name,
      record_id: work_id,
      identifier: file_set.id
    )
  end

  def build_visibility_change(env, file_set, persisted)
    new_visibility = env.attributes[:visibility] || env.attributes['visibility']
    return {} unless new_visibility.present?

    original_visibility = persisted.visibility
    return {} if original_visibility.to_s == new_visibility.to_s

    { "visibility": { before: original_visibility, after: new_visibility } }
  end

  def build_title_change(env, file_set, persisted)
    return {} unless env.attributes.key?(:title)

    new_title = normalized_title(env.attributes[:title] || env.attributes['title'])
    original_title = normalized_title(persisted.title)
    return {} if new_title == original_title

    { "title": { before: original_title, after: new_title } }
  end

  def normalized_title(value)
    collection =
      case value
      when ActionController::Parameters
        value.to_unsafe_h.values
      when Hash
        value.values
      else
        value
      end

    Array(collection).flatten.map { |v| v.to_s.strip }.reject(&:blank?)
  end

  def persisted_record_for(file_set)
    file_set.class.find(file_set.id)
  rescue StandardError
    file_set
  end

  def parent_id_for(file_set)
    parent = file_set.try(:parent)
    parent&.id
  end
end
