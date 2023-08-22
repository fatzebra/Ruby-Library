# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Object
  #
  # Define the API objects
  class FatZebraObject
    include ObjectHelper
    extend Validation

    attr_reader :accepted
    alias accepted? accepted

    class << self

      ##
      # Initialize from the API response
      #
      # @return [FatZebra::FatZebraObject]
      def initialize_from(response)
        object = new

        object.load_response_api(response.is_a?(Hash) ? response : JSON.parse(response))

        if object.raw['response']
          if object.raw['response'].is_a?(Array)
            object.raw['response'].each { |response_object| object.add_data(initialize_from(response_object)) }
          else
            object.update_attributes(object.raw['response'])
          end
        else
          object.update_attributes(object.raw)
        end

        object
      end

    end

    ##
    # Update the object based on the response from the API
    # Remove and new acessor
    #
    # @param [Hash] response
    #
    # @return [FatZebra::FatZebraObject]
    def update_from(response)
      load_response_api(response.is_a?(Hash) ? response : JSON.parse(response))

      # attributes to remove
      (@values.keys - raw['response'].keys).each { |key| remove_accessor(key) }

      update_attributes(raw['response'])

      self
    end

    ##
    # Load the root components for the API response
    #
    # @param [Hash] values
    def load_response_api(response)
      @raw        = response
      @accepted   = response['successful']
      @errors     = response['errors']
    end

  end
end
