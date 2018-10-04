module Hyrax
    module ConacytPresenter
        delegate :subject_conacyt, :creator_conacyt, :contributor_conacyt, :pub_conacyt, to: :solr_document
    end
end