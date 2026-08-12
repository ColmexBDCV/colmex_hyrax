# frozen_string_literal: true

# Hyrax's stock implementation starts IngestJob before attaching the FileSet
# to its work. This is unsafe with ActiveJob's inline adapter because the
# derivative job runs synchronously and cannot reindex the parent without it.
class AttachFilesToWorkJob < Hyrax::ApplicationJob
  queue_as Hyrax.config.ingest_queue_name

  def perform(work, uploaded_files, **work_attributes)
    case work
    when ActiveFedora::Base
      perform_af(work, uploaded_files, work_attributes)
    else
      Hyrax::WorkUploadsHandler.new(work: work).add(files: uploaded_files).attach ||
        raise("Could not complete AttachFilesToWorkJob. Some of these are probably in an undesirable state: #{uploaded_files}")
    end
  end

  private

  def perform_af(work, uploaded_files, work_attributes)
    validate_files!(uploaded_files)
    depositor = proxy_or_depositor(work)
    user = User.find_by_user_key(depositor)

    work, work_permissions = create_permissions(work, depositor)
    uploaded_files.each do |uploaded_file|
      next if uploaded_file.file_set_uri.present?
      attach_work(user, work, work_attributes, work_permissions, uploaded_file)
    end
  end

  def attach_work(user, work, work_attributes, work_permissions, uploaded_file)
    actor = Hyrax::Actors::FileSetActor.new(FileSet.create, user)
    file_set_attributes = file_set_attrs(work_attributes, uploaded_file)
    metadata = visibility_attributes(work_attributes, file_set_attributes)
    uploaded_file.add_file_set!(actor.file_set)
    actor.file_set.permissions_attributes = work_permissions
    actor.create_metadata(metadata)

    # Attach before ingesting. With inline, IngestJob and derivative jobs run
    # here and need file_set.parent to reindex the work.
    actor.attach_to_work(work, metadata)
    actor.create_content(uploaded_file)
  end

  def create_permissions(work, depositor)
    work.edit_users += [depositor]
    work.edit_users = work.edit_users.dup
    [work, work.permissions.map(&:to_hash)]
  end

  def visibility_attributes(attributes, file_set_attributes)
    attributes.merge(file_set_attributes).slice(:visibility, :visibility_during_lease,
                                                :visibility_after_lease, :lease_expiration_date,
                                                :embargo_release_date, :visibility_during_embargo,
                                                :visibility_after_embargo)
  end

  def file_set_attrs(attributes, uploaded_file)
    attrs = Array(attributes[:file_set]).find do |fs|
      fs[:uploaded_file_id].present? && fs[:uploaded_file_id].to_i == uploaded_file&.id
    end
    Hash(attrs).symbolize_keys
  end

  def validate_files!(uploaded_files)
    uploaded_files.each do |uploaded_file|
      next if uploaded_file.is_a?(Hyrax::UploadedFile)
      raise ArgumentError, "Hyrax::UploadedFile required, but #{uploaded_file.class} received: #{uploaded_file.inspect}"
    end
  end

  def proxy_or_depositor(work)
    work.on_behalf_of.presence || work.depositor
  end
end