# frozen_string_literal: true

# @curation_concern = Wings::ActiveFedoraConverter.convert(resource: @curation_concern) if
#   @curation_concern.is_a? Hyrax::Resource
array_of_ids = @presenter.list_of_item_ids_to_display
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
    else
        records.push  [ member.id, member.model_name.name ]
    end
end

json.extract! @curation_concern, *[:id] + @curation_concern.class.fields.reject { |f| [:has_model].include? f }
json.videos videos
json.audios audios
json.file_sets file_sets
json.records records
json.version @curation_concern.try(:etag)
