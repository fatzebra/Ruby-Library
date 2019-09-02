module FatZebra
  ##
  # == FatZebra \Authorise
  #
  # Manage 3DS authorisation for the API
  #
  # * token
  # * authorise
  #
  class Authorise < APIResource
    @resource_name = 'authorise'

    validates :card_number, required: true, on: :authorise
    validates :card_expiry, required: true, on: :authorise
    validates :threeds, required: true, on: :authorise

    class << self

      ##
      # Returns a JWT token for the 3DS authorisation process
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::Authorise]
      def jwt_token(params = {}, options = {})
        valid!(params, :jwt_token) if respond_to?(:valid!)

        response = request(:get, "#{resource_path}/jwt_token", params, options)
        initialize_from(response)
      end

      ##
      # Creates a lookup request to 3DS server
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::Authorise]
      def authorise(params = {}, options = {})
        valid!(params, :authorise) if respond_to?(:valid!)

        response = request(:post, resource_path, params, options)
        initialize_from(response)
      end
    end

  end
end
