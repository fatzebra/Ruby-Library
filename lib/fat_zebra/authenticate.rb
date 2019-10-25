module FatZebra
  ##
  # == FatZebra \Authenticate
  #
  # Manage 3DS2/SCA authentication for the API
  #
  # * session
  # * authenticate
  # * decode_session
  #
  class Authenticate < APIResource
    @resource_name = 'authenticate'

    validates :card_token, required: true, on: :authenticate
    validates :sca, required: true, on: :authenticate
    validates :token, required: true, on: :decode_session

    class << self

      ##
      # Returns a JWT token for the 3DS authentication process
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::Authenticate]
      def session(params = {}, options = {})
        valid!(params, :session) if respond_to?(:valid!)

        response = request(:post, "#{resource_path}/session", params, options)
        initialize_from(response)
      end

      ##
      # Decodes a JWT token for the 3DS authentication process
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::Authenticate]
      def decode_session(params = {}, options = {})
        valid!(params, :decode_session) if respond_to?(:valid!)

        response = request(:get, "#{resource_path}/decode_session", params, options)
        initialize_from(response)
      end

      ##
      # Authenticates a 3ds request
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
