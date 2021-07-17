# Generated via
#  `rails generate hyrax:work ArchivalDocument`
module Hyrax
  class ArchivalDocumentPresenter < Hyrax::WorkShowPresenter
    delegate :is_finding_aid_for, to: :solr_document
  end
end
