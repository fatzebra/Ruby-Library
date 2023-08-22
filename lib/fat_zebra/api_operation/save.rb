# frozen_string_literal: true

module FatZebra
  class APIOperation
    ##
    # == Save (create or update) a resource for the API
    #
    module Save
      module ClassMethods

        ##
        # Create an API Resource and validate the params for the API.
        #
        # @param [Hash] params for the request
        # @param [Hash] Additional options for the request
        #
        # @return [FatZebra::Object] response from the API
        def create(params = {}, options = {})
          valid!(params, :create) if respond_to?(:valid!)

          response = request(:post, resource_path, params, options)
          initialize_from(response)
        end

        ##
        # Update an API Resource and validate params for the API
        #
        # @param [String] id for the request
        # @param [Hash] params for the request
        # @param [Hash] Additional options for the request
        #
        # @return [FatZebra::Object] response from the API
        def update(id, params = {}, options = {})
          valid!(params, :update) if respond_to?(:valid!)

          response = request(:put, "#{resource_path}/#{id}", params, options)
          initialize_from(response)
        end

      end

      ##
      # Create or Update an API Resource
      #
      # @param [Hash] params for the request
      # @param [Hash] Additional options for the request
      #
      # @return [FatZebra::Object] response from the API
      def save(params = {}, options = {})
        path   = singleton_methods.include?(:id) ? "#{resource_path}/#{id}" : resource_path
        method = singleton_methods.include?(:id) ? :put : :post

        params_for_save = to_hash.merge(params)

        # Remove the id from the params to save, it should not be updated.
        params_for_save.delete('id')

        response = request(method, path, params_for_save, options)
        update_from(response)
      end
      alias update save

      def self.included(base)
        base.extend(ClassMethods)
      end

    end
  end
end
