module FatZebra
  ##
  # == FatZebra \API \Resource
  #
  # Define the API requests methods
  class APIResource < FatZebraObject
    include APIHelper

    class << self

      def base_path
        "#{configurations.api_version}/"
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
      # rubocop:disable Metrics/AbcSize
      def request(method, path, payload = {}, options = {})
        payload[:test] = true if configurations.test_mode
        payload        = Util.format_dates_in_hash(payload)
        url_params     = Util.encode_parameters(payload) if method == :get
        uri            = build_endpoint_url(configurations.gateway, path, url_params, http_secure: configurations.http_secure)

        request_options = Util.compact(
          method:  method,
          url:     uri.to_s,
          payload: payload,
          proxy:   configurations.proxy,
          use_ssl: configurations.http_secure
        ).merge(authentication).merge(default_headers).merge(configurations.global_options).merge(options)

        Request.execute(request_options).body
      rescue FatZebra::RequestError => error
        return error.http_body if error.http_status == 422
        raise
      end
      # rubocop:enable Metrics/AbcSize

      private

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

      def configurations
        FatZebra.configurations
      end

    end
  end
end
