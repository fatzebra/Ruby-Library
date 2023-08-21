# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Helper
  #
  # Help for the api resource
  module APIHelper

    module ClassMethods

      def base_path
        ''
      end

      ##
      # @return [String] resource path
      def resource_path(path = nil)
        "/#{base_path}#{path || @resource_name || CGI.escape(resource_name)}"
      end

      ##
      # @return [String] resource name
      def resource_name
        Util.underscore("#{class_name}s")
      end

      ##
      # @return [String] the class name
      def class_name
        name.split('::')[-1]
      end

      ##
      # Send a request to the API
      def request
        raise 'need to be implemented'
      end

      def build_endpoint_url(base_url, path, params = nil, options = {})
        host, port = base_url.split(':')
        port       = port.to_i if port

        url_params = Util.compact(
          host: host,
          path: path,
          port: port,
          query: params
        )

        return URI::HTTPS.build(url_params) if options[:http_secure]

        URI::HTTP.build(url_params)
      end

      def default_headers
        {
          headers: {
            accept: 'application/json',
            content_type: 'application/json'
          }
        }
      end

    end

    ##
    # @return [String] resource name
    def resource_name
      self.class.resource_name
    end

    ##
    # @return [String] resource path
    def resource_path(path = nil)
      self.class.resource_path(path)
    end

    ##
    # Send a request to the API
    #
    # @param [Symbol] method for the request
    # @param [String] endpoint for the request
    # @param [Hash] options
    # @param [Hash] Payload
    #
    # @return [Hash] response
    # @raise [FatZebra::RequestError] if the request is invalid
    def request(method, resource_path, payload = {}, options = {})
      self.class.request(method, resource_path, payload, options)
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

  end
end
