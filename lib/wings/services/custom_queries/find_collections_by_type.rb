# frozen_string_literal: true
module Wings
  module CustomQueries
    ##
    # @see Hyrax::CustomQueries::FindCollectionsByType
    class FindCollectionsByType
      def self.queries
        [:find_collections_by_type]
      end

      def initialize(query_service:)
        @query_service = query_service
      end

      attr_reader :query_service
      delegate :resource_factory, to: :query_service

      ##
      # @param global_id [GlobalID] global id for a Hyrax::CollectionType
      #
      # @return [Enumerable<PcdmCollection>]
      def find_collections_by_type(global_id:)
        ::Collection.where(collection_type_gid_ssim: global_id.to_s).map(&:valkyrie_resource)
      end
    end
  end
end
