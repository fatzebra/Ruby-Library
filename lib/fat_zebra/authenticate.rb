module FatZebra
  ##
  # == FatZebra \Authenticate
  #
  # Manage 3DS authentication for the API
  #
  # * jwt_token
  # * authenticate
  # * decode_jwt
  #
  class Authenticate < APIResource
    @resource_name = 'authenticate'

    validates :card_number, required: true, on: :authenticate
    validates :card_expiry, required: true, on: :authenticate
    validates :sca, required: true, on: :authenticate
    validates :token, required: true, on: :decode_jwt

    class << self

      ##
      # Returns a JWT token for the 3DS authentication process
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::Authenticate]
      def jwt_token(params = {}, options = {})
        valid!(params, :jwt_token) if respond_to?(:valid!)

        response = request(:get, "#{resource_path}/jwt_token", params, options)
        initialize_from(response)
      end

      ##
      # Decodes a JWT token for the 3DS authentication process
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::Authenticate]
      def decode_jwt(params = {}, options = {})
        valid!(params, :decode_jwt) if respond_to?(:valid!)

        response = request(:post, "#{resource_path}/decode_jwt", params, options)
        initialize_from(response)
      end

      ##
      # Creates a lookup request to 3DS server
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::Authenticate]
      def authenticate(params = {}, options = {})
        valid!(params, :authenticate) if respond_to?(:valid!)

        response = request(:post, resource_path, params, options)
        initialize_from(response)
      end
    end

  end
end
