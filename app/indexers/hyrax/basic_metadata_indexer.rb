module Hyrax
  # This class gets called by ActiveFedora::IndexingService#olrize_rdf_assertions
  class BasicMetadataIndexer < ActiveFedora::RDF::IndexingService
    class_attribute :stored_and_facetable_fields, :stored_fields, :symbol_fields
    self.stored_and_facetable_fields = %i[other_title alternate_title resource_type creator
       contributor has_creator keyword publisher language based_near geographic_coverage
       temporary_coverage gender_or_form subject_person subject_family 
       subject_work subject subject_corporate notes classification has_field_activity_of_agent
       item_access_restrictions digital_resource_generation_information place_of_publication
       interviewer interviewee organizer_collective_agent photographer narrator
       collective_title part_of_place provenance curator_collective_agent_of
       project owner_agent_of custodian_agent_of file_type_details is_facsimile_of_manifestation_of
       depository_collective_agent depository_agent corporate_body collective_agent
       supplementary_content_or_bibliography responsibility_statement beginning ending
       other_related_persons table_of_contents type_of_content organizer_collective_agent
       item_use_restrictions encoding_format_details type_of_illustrations 
       center license rights_statement date_created bibliographic_citation date_of_manifestation
       source reviewer mode_of_issuance edition dimensions extension system_requirements
       editor translator compiler commentator contained_in writer_of_suplementary_textual_content
       resource_access_restrictions resource_use_restrictions manifestation_access_restrictions
       manifestation_use_restrictions item_access_restrictions item_use_restrictions]

    self.stored_fields = %i[description identifier doi isbn related_url handle digital_file_characteristics]
    self.symbol_fields = %i[import_url]

    private

      # This method overrides ActiveFedora:RDF::IndexingService
      # @return [ActiveFedora::Indexing::Map]
      def index_config
        merge_config(
          merge_config(
            merge_config(super, stored_and_facetable_index_config),
            stored_searchable_index_config
          ),
          symbol_index_config
        )
      end

      # This can be replaced by a simple merge once
      # https://github.com/samvera/active_fedora/pull/1227
      # is available to us
      # @param [ActiveFedora::Indexing::Map] first
      # @param [Hash] second
      def merge_config(first, second)
        first_hash = first.instance_variable_get(:@hash).deep_dup
        ActiveFedora::Indexing::Map.new(first_hash.merge(second))
      end

      def stored_and_facetable_index_config
        stored_and_facetable_fields.each_with_object({}) do |name, hash|
          hash[name] = index_object_for(name, as: [:stored_searchable, :facetable])
        end
      end

      def stored_searchable_index_config
        stored_fields.each_with_object({}) do |name, hash|
          hash[name] = index_object_for(name, as: [:stored_searchable])
        end
      end

      def symbol_index_config
        symbol_fields.each_with_object({}) do |name, hash|
          hash[name] = index_object_for(name, as: [:symbol])
        end
      end

      def index_object_for(attribute_name, as: [])
        ActiveFedora::Indexing::Map::IndexObject.new(attribute_name) do |idx|
          idx.as(*as)
        end
      end
  end
end
