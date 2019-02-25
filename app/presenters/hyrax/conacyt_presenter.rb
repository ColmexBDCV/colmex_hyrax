module Hyrax
    module ConacytPresenter
        delegate :subject_conacyt, :creator_conacyt, :contributor_conacyt, :pub_conacyt, :type_conacyt, to: :solr_document
    end
end