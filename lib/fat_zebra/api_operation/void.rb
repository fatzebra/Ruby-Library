# frozen_string_literal: true

module FatZebra
  class APIOperation
    ##
    # == Void a resource for the API
    #
    module Void
      module ClassMethods

        ##
        # Void an API Resource and validate params for the API
        #
        # @param [String] id for the request
        # @param [Hash] params for the request
        # @param [Hash] Additional options for the request
        #
        # @return [FatZebra::Object] response from the API
        def void(id, params = {}, options = {})
          valid!(params, :void) if respond_to?(:valid!)

          params = {
            id: id
          }.merge(params)

          response = request(:post, "#{resource_path}/void", params, options)
          initialize_from(response)
        end

      end

      ##
      # Void an API Resource
      #
      # @param [Hash] params for the request
      # @param [Hash] Additional options for the request
      #
      # @return [FatZebra::Object] response from the API
      def void(params = {}, options = {})
        params = {
          id: id
        }.merge(params)

        response = request(:post, "#{resource_path}/void", params, options)
        update_from(response)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

    end
  end
end
