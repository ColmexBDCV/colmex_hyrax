module IndexChildrenWorks

  def to_solr(solr_doc={})
    solr_doc = super(solr_doc)
    children_titles = []
    self.members.each do |m|
      if m.class.to_s != "FileSet" then
        children_titles += m.title.to_a #este es un arreglo, se debe arreglar
      end
    end
    solr_doc['children_work_titles_tesim'] = children_titles

    solr_doc
  end

end
