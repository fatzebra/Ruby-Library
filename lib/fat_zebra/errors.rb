# frozen_string_literal: true

module FatZebra

  ##
  # Configuration Error
  class ConfigurationError < StandardError; end

  ##
  # Validations for the request
  class RequestValidationError < StandardError; end

  ##
  # Method unknown for the request
  class UnknownRequestMethod < StandardError; end

  ##
  # Request to API Error
  class RequestError < StandardError

    attr_reader :http_body, :http_status, :http_status_type, :http_message

    def initialize(response, message: nil)
      @http_status      = response.code.to_i
      @http_status_type = response.code_type
      @http_body        = response.body
      @http_message     = message || response.message
    end

    def to_s
      "Status #{http_status}: #{http_message}"
    end

  end

end
