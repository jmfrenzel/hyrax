# frozen_string_literal: true

module Hyrax
  ##
  # Indexes properties common to PCDM Collections
  class PcdmCollectionIndexer < Hyrax::ValkyrieIndexer
    include Hyrax::ResourceIndexer
    include Hyrax::PermissionIndexer
    include Hyrax::VisibilityIndexer
    include Hyrax::Indexer(:core_metadata)
    include Hyrax::Indexer(:basic_metadata)

    def to_solr
      super.tap do |index_document|
        index_document[:collection_type_gid_ssim] = Array(resource.try(:collection_type_gid)&.to_s)
        index_document[:generic_type_sim] = ['Collection']
        index_document[:thumbnail_path_ss] = Hyrax::CollectionThumbnailPathService.call(resource)
      end
    end
  end
end
