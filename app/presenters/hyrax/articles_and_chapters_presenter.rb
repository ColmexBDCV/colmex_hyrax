module Hyrax
    module ArticlesAndChaptersPresenter
        delegate :contained_in, :is_part_or_work, :database, to: :solr_document
    end
end