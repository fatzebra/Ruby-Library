module FatZebra
  class APIOperation
    ##
    # == Search resources for the API
    #
    module Search

      ##
      # Default params for the API
      DEFAULT_PARAMS = {
        offets: 0,
        limit: 10
      }.freeze

      ##
      # Search for API Resources
      #
      # @param [Hash] params for the request
      # @param [Hash] Additional options for the request
      #
      # @return [FatZebra::Object] response from the API
      def search(params = {}, options = {})
        params = DEFAULT_PARAMS.merge(params)
        params = Util.format_dates_in_hash(params)

        response = request(:get, resource_path, params, options)
        initialize_from(response)
      end

    end
  end
end
