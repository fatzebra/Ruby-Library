# frozen_string_literal: true

module FatZebra
  class APIOperation
    ##
    # == Find a resource for the API
    #
    module Find
      module ClassMethods

        ##
        # Find an API Resource
        #
        # @param [String] id for the request
        # @param [Hash] params for the request
        # @param [Hash] Additional options for the request
        #
        # @return [FatZebra::Object] response from the API
        def find(id, params = {}, options = {})
          response = request(:get, "#{resource_path}/#{id}", params, options)
          initialize_from(response)
        end

      end

      def self.included(base)
        base.extend(ClassMethods)
      end

    end
  end
end
