# frozen_string_literal: true

class IiifManifestCollectionService
  def initialize(request:, ability: nil, thematic_collection: nil)
    @request = request
    @ability = ability
    @thematic_collection = thematic_collection
  end

  def build
    {
      '@context' => 'http://iiif.io/api/presentation/2/context.json',
      '@id' => collection_url,
      '@type' => 'sc:Collection',
      'label' => 'Manifiestos IIIF',
      'manifests' => manifest_entries
    }
  end

  private

  attr_reader :request, :ability, :thematic_collection

  def collection_url
    "#{request.base_url}/iiif/collection"
  end

  def manifest_entries
    works_with_image_file_sets.map do |work|
      solr_document = ::SolrDocument.find(work.id)
      next if filter_by_thematic_collection?(solr_document)

      presenter = Hyrax::IiifManifestPresenter.new(solr_document).tap do |p|
        p.hostname = request.base_url
        p.ability = ability if ability
      end

      manifest_builder.manifest_for(presenter: presenter)
    end.compact
  end

  def filter_by_thematic_collection?(solr_document)
    return false if thematic_collection.blank?

    values = Array.wrap(solr_document['thematic_collection_tesim'])
    values.exclude?(thematic_collection)
  end

  def works_with_image_file_sets
    parents = {}

    FileSet.where(mime_type_ssi: FileSet.image_mime_types).each do |file_set|
      begin
        parent = file_set.parent
      rescue StandardError
        parent = nil
      end
      next if parent.nil?
      next if ability && !ability.can?(:read, parent)

      parents[parent.id] ||= parent
    end

    parents.values
  end

  def manifest_builder
    Flipflop.cache_work_iiif_manifest? ? Hyrax::CachingIiifManifestBuilder.new : Hyrax::ManifestBuilderService.new
  end
end
