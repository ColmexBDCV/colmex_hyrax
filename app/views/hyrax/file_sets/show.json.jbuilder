# frozen_string_literal: true
json.extract! @presenter, :id, :title, :label, :creator, :date_uploaded,
              :depositor, :date_modified, :mime_type

json.is_video @presenter.video?
json.is_audio @presenter.audio?
json.is_pdf @presenter.pdf?
json.is_office_document @presenter.office_document?              
json.parent do 
    json.id @presenter.parent.id 
    json.title @presenter.parent.title.first
    json.model_name @presenter.parent.model_name.name 
end