# frozen_string_literal: true

module FatZebra
  class APIOperation
    ##
    # == Delete a resource for the API
    #
    module Delete
      module ClassMethods
        ##
        # Delete an API Resource
        #
        # @param [String] id for the request
        # @param [Hash] Additional options for the request
        #
        # @return [FatZebra::Object] response from the API
        def delete(id, options = {})
          response = request(:delete, "#{resource_path}/#{id}", options)
          initialize_from(response)
        end
      end

      ##
      # Delete an API Resources
      #
      # @param [Hash] Additional options for the request
      #
      # @return [FatZebra::Object] response from the API
      def destroy(options = {})
        response = request(:delete, "#{resource_path}/#{id}", {}, options)
        update_from(response)
      end

      def self.included(base)
        base.extend(ClassMethods)
      end

    end
  end
end
