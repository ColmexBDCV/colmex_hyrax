module IndexParentWorks

  def to_solr(solr_doc={})
  solr_doc = super(solr_doc)
    solr_doc['parent_work_ids_ssim'] = self.member_of.map(&:id) unless self.member_of.map(&:id).empty?
    solr_doc['parent_work_titles_tesim'] = self.member_of.map(&:title) unless self.member_of.map(&:title).empty?
    solr_doc
  end

end
