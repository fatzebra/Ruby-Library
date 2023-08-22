# frozen_string_literal: true

module FatZebra
  class APIOperation
    ##
    # == Search resources for the API
    #
    module Search

      ##
      # Default params for the API
      DEFAULT_PARAMS = {
        offset: 0,
        limit: 10
      }.freeze

      module ClassMethods

        ##
        # Search for API Resources
        #
        # @param [Hash] params for the request
        # @param [Hash] Additional options for the request
        #
        # @return [FatZebra::Object] response from the API
        def search(params = {}, options = {})
          params = DEFAULT_PARAMS.merge(params)

          response = request(:get, resource_path, params, options)
          initialize_from(response)
        end

      end

      def self.included(base)
        base.extend(ClassMethods)
      end

    end
  end
end
