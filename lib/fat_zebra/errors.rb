module FatZebra

  ##
  # Configuration Error
  class ConfigurationError < StandardError; end

  ##
  # Request to API Error
  class RequestError < StandardError; end

  ##
  # Validations for the request
  class RequestValidationError < StandardError; end

  ##
  # Method unknown for the request
  class UnknownRequestMethod < StandardError; end

end
