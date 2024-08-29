docs = []


@presenter.documents.each do |document|

  doc = document.to_h

  unless document[:parent_work_ids_ssim].nil?

    is_part_of = []

    document[:parent_work_ids_ssim].each do |parent_id|

      is_part_of << build_member_json_info(parent_id)
    end

    doc["is_part_of"] = is_part_of
  end

  docs << doc

end

json.response do
  json.docs docs
  json.facets @presenter.search_facets_as_json
  json.pages @presenter.pagination_info
end
