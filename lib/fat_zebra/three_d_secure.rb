# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \ThreeDSecure
  #
  # Manage 3DS2 authentication for the Cybersource REST API
  #
  # * setup
  # * enrollment
  # * validation
  #
  class ThreeDSecure < APIResource
    validates :card_token, required: true, on: :setup

    CHECK_ENROLLMENT_REQUIRED_FIELDS = %i[
      merchant_username
      card_token
      amount
      currency
      reference
      verification
      device_channel
      reference_id
      return_url
      acs_window_size
      browser_accept_content
      browser_language
      browser_java_enabled
      browser_color_depth
      browser_screen_height
      browser_screen_width
      browser_time_difference
      browser_user_agent
    ].freeze

    CHECK_ENROLLMENT_REQUIRED_FIELDS.each do |field|
      validates field, required: true, on: :check_enrollment
    end

    VALIDATE_AUTHENTICATION_REQUIRED_FIELDS = %i[
      merchant_username
      card_token
      amount
      currency
      authentication_transaction_id
    ].freeze

    VALIDATE_AUTHENTICATION_REQUIRED_FIELDS.each do |field|
      validates field, required: true, on: :validate_authentication
    end

    class << self

      def resource_name
        'three_d_secure'
      end

      def resource_path
        "/sdk/#{resource_name}"
      end

      ##
      # Sets up a 3ds request
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::ThreeDSecure]
      def setup(params = {}, options = {})
        valid!(params, :setup) if respond_to?(:valid!)

        response = request(:post, "#{resource_path}/setup", params, options)
        initialize_from(response)
      end

      ##
      # Enrols card
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::ThreeDSecure]
      def check_enrollment(params = {}, options = {})
        valid!(params, :check_enrollment) if respond_to?(:valid!)

        response = request(:post, "#{resource_path}/check_enrollment", params, options)
        initialize_from(response)
      end

      ##
      # Validates card
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::ThreeDSecure]
      def validate_authentication(params = {}, options = {})
        valid!(params, :validate_authentication) if respond_to?(:valid!)

        response = request(:post, "#{resource_path}/validate_authentication", params, options)
        initialize_from(response)
      end
    end
  end
end
