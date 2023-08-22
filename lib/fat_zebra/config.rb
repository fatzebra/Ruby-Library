# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Config
  #
  # Represent the FatZebra configuration for the API
  class Config

    GATEWAY_URLS = {
      production: 'gateway.fatzebra.com.au',
      sandbox: 'gateway.sandbox.fatzebra.com.au'
    }.freeze

    ##
    # @return [String] Username
    attr_accessor :username

    ##
    # @return [String] Token
    attr_accessor :token

    ##
    # @return [String] Test mode
    attr_accessor :test_mode

    ##
    # @return [String] Gateway url
    attr_accessor :gateway

    ##
    # @return [String] Proxy url
    attr_accessor :proxy

    ##
    # @return [String] http secure
    attr_accessor :http_secure

    ##
    # @return [String] api version
    attr_accessor :api_version

    ##
    # @return [String] global request options
    attr_accessor :global_options

    ##
    # @param [Hash{Symbol=>Object}]
    # Initialize and validate the configuration
    def initialize(options = {})
      self.token          = options[:token]
      self.username       = options[:username]
      self.gateway        = options[:gateway] || :production
      self.test_mode      = options[:test_mode] || false
      self.http_secure    = options[:http_secure] || true
      self.api_version    = options[:api_version] || 'v1.0'
      self.proxy          = options[:proxy]
      self.global_options = options[:global_options] || {}

      valid! unless options.empty?
    end

    ##
    # validate the configuration
    # Raise when configuration is not valid
    # Remove "http://" or "https://" from urls
    #
    # @return [Boolean] true
    def valid!
      format!

      %i[username token gateway api_version].each do |field|
        validate_presence(field)
      end

      true
    end

    private

    def format!
      self.gateway = GATEWAY_URLS[gateway] if gateway.is_a?(Symbol)

      self.gateway = Util.cleanup_host(gateway)
    end

    def validate_presence(field)
      raise FatZebra::ConfigurationError, "#{field} can't be blank" if send(field).nil? || send(field).empty?
    end

  end
end
