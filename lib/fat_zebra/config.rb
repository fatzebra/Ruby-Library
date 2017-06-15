module FatZebra
  ##
  # == FatZebra \Config
  #
  # Represent the FatZebra configuration for the API
  class Config

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
    # @return [String] Sandbox
    attr_accessor :sandbox

    ##
    # @return [String] Options
    attr_accessor :options

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
    # @param [Hash{Symbol=>Object}]
    # Initialize and validate the configuration
    def initialize(options = {})
      self.token       = options[:token]
      self.username    = options[:username]
      self.gateway     = options[:gateway] || 'gateway.fatzebra.com.au'
      self.test_mode   = options[:test_mode] || false
      self.http_secure = options[:http_secure] || true
      self.api_version = options[:api_version] || 'v1.0'
      self.sandbox     = options[:sandbox]
      self.options     = options[:options]
      self.proxy       = options[:proxy]
    end

    ##
    # validate the configuration
    # Raise when configuration is not valid
    # @return [Boolean] true
    def valid!
      %i[username token].each do |field|
        validate_presence(field)
      end

      true
    end

    private

    def validate_presence(field)
      raise FatZebra::ConfigurationError, "#{field} can't be blank" if send(field).nil? || send(field).empty?
    end

  end
end
