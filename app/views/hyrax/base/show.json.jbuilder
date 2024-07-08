# frozen_string_literal: true

# @curation_concern = Wings::ActiveFedoraConverter.convert(resource: @curation_concern) if
#   @curation_concern.is_a? Hyrax::Resource
array_of_ids = @presenter.ordered_ids
members = @presenter.member_presenters_for(array_of_ids)
audios = []
videos = []
file_sets = []
records = []
members.each do |member|

    if member.model_name.name == "FileSet"
        tags = []
        derivatives = Hyrax::DerivativePath.derivatives_for_reference(member)
        derivatives.each { |d| tags.push d.split(".").first.split("-").last }
        tags.delete("thumbnail")
        tags.sort!

        videos.push({src: hyrax.download_path(member, file: tags.last), thumbnail: hyrax.download_path(member, file: "thumbnail"), title: member.title.first}) if member.video?

        audios.push ({src: hyrax.download_path(member, file: tags.first), title: member.title.first}) if member.audio?

        file_sets.push member.id
    end

    unless member.model_name.name == "FileSet"
        member.file_set_presenters.each do |file_set|

            tags = []
            derivatives = Hyrax::DerivativePath.derivatives_for_reference(file_set)
            derivatives.each { |d| tags.push d.split(".").first.split("-").last }
            tags.delete("thumbnail")
            tags.sort!
            videos.push({src: hyrax.download_path(file_set, file: tags.last), thumbnail: hyrax.download_path(file_set, file: "thumbnail"), title: file_set.title.first}) if file_set.video?

            audios.push ({src: hyrax.download_path(file_set, file: tags.first), title: file_set.title.first}) if file_set.audio?

        end

        records.push  [ member.id, member.model_name.name ]
    end

end

ids = @presenter.solr_document['parent_work_ids_ssim'] || []
titles = @presenter.solr_document['parent_work_titles_tesim'] || []

unless ids.empty? || titles.empty?
    is_part_of = ids.zip(titles).map do |id, title|
        { src:  "/concern/#{@presenter.solr_document["has_model_ssim"].first.downcase}/#{id}", title: title}
    end
end

json.extract! @curation_concern, *[:id] + @curation_concern.class.fields.reject { |f| [:has_model].include? f }
json.is_part_of is_part_of
json.videos videos
json.audios audios
json.file_sets file_sets
json.records records
json.version @curation_concern.try(:etag)
