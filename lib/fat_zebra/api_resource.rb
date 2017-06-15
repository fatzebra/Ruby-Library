module FatZebra
  ##
  # == FatZebra \API \Resource
  #
  # Define the API requests methods
  class APIResource < FatZebraObject

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

    class << self

      ##
      # @return [String] resource path
      def resource_path(path = nil)
        "/#{configurations.api_version}/#{path || @resource_name || CGI.escape(resource_name)}"
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
      #
      # @param [Symbol] method for the request
      # @param [String] endpoint for the request
      # @param [Hash] options
      # @param [Hash] Payload
      #
      # @return [Hash] response
      # @raise [FatZebra::RequestError] if the request is invalid
      def request(method, path, payload = {}, options = {})
        payload[:test] = true if configurations.test_mode

        if method == :get
          url_params = !payload.empty? && Util.encode_parameters(payload)
          payload    = nil
        end

        uri = build_endpoint_url(path, url_params)

        request_options = Util.compact(
          method:  method,
          url:     uri.to_s,
          payload: payload,
          proxy:   configurations.proxy,
          use_ssl: configurations.http_secure
        ).merge(authentication).merge(headers).merge(options)

        request = Request.execute(request_options)

        request.body
      end

      private

      def build_endpoint_url(path, params = nil)
        host, port = configurations.gateway.split(':')

        url_params = Util.compact(
          host:  host,
          path:  path,
          port:  port,
          query: params
        )

        return URI::HTTPS.build(url_params) if configurations.http_secure
        URI::HTTP.build(url_params)
      end

      def ssl_options
        return {} unless configurations.http_secure
        {
          ca_file:     File.expand_path(File.dirname(__FILE__) + '/../../vendor/cacert.pem'),
          verify_mode: OpenSSL::SSL::VERIFY_PEER
        }
      end

      def authentication
        {
          basic_auth: {
            user:     configurations.username,
            password: configurations.token
          }
        }
      end

      def headers
        {
          headers: {
            accept:       'application/json',
            content_type: 'application/json'
          }
        }
      end

      def configurations
        FatZebra.configurations
      end

    end
  end
end
