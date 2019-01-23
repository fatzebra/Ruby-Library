require 'fat_zebra/request/multipart/part'
require 'fat_zebra/request/multipart/stream'
require 'fat_zebra/request/multipart/epilogue'
require 'fat_zebra/request/multipart/file_io'
require 'fat_zebra/request/multipart/param'

module FatZebra
  ##
  # == FatZebra \Request
  #
  # Build request
  class Request
    class << self

      def execute(params = {})
        klass = new(params)

        if params[:method] == :post
          klass.post
        elsif params[:method] == :put
          klass.put
        elsif params[:method] == :delete
          klass.delete
        elsif params[:method] == :get
          klass.get
        else
          raise FatZebra::UnknownRequestMethod, "#{params[:method]} haven't been implemented"
        end
      end

      def post(params = {})
        new(params).post
      end

      def put(params = {})
        new(params).put
      end

      def get(params = {})
        new(params).get
      end

      def delete(params = {})
        new(params).delete
      end
    end

    attr_reader :params, :http, :request

    def initialize(params = {})
      @params = params
      @http   = Net::HTTP.new(uri.host,
                              uri.port,
                              proxy_host,
                              uri_proxy.port)

      setup_ssl if params[:use_ssl]
    end

    def post
      @request = Net::HTTP::Post.new(uri.path)

      setup_auth_basic if params[:basic_auth]

      if params[:payload] && params[:payload][:multipart]
        build_multipart_post
      elsif params[:payload] && params[:payload][:raw]
        build_raw_file_post
      else
        set_header
        request.body = params[:payload].to_json
      end

      handle_request
    end

    def put
      @request = Net::HTTP::Put.new(uri.path)

      setup_auth_basic if params[:basic_auth]
      set_header
      request.body = params[:payload].to_json

      handle_request
    end

    def get
      @request = Net::HTTP::Get.new(uri)

      setup_auth_basic if params[:basic_auth]
      set_header

      handle_request
    end

    def delete
      @request = Net::HTTP::Delete.new(uri.path)

      setup_auth_basic if params[:basic_auth]
      request.body = params[:payload].to_json

      handle_request
    end

    private

    def handle_request
      response = http.request(request)

      case [response.code_type]
      when [Net::HTTPOK], [Net::HTTPCreated], [Net::HTTPAccepted]
        response
      when [Net::HTTPUnauthorized]
        raise RequestError.new(response, message: 'Unauthorized, please check your authentication username or token')
      when [Net::HTTPNotFound]
        raise RequestError.new(response, message: 'Requested Resource not found')
      when [Net::HTTPRequestTimeOut]
        raise RequestError.new(response, message: 'Verify the address for the service')
      when [Net::HTTPInternalServerError]
        raise RequestError.new(response, message: 'Server Error, please check with service')
      when [Net::HTTPNotImplemented]
        raise RequestError.new(response, message: 'Problem processing your request - please check your data')
      else
        raise RequestError, response
      end
    end

    def build_multipart_post
      parts = []
      Util.hash_except(params[:payload], :multipart, :content_type).each do |(key, value)|
        parts << (value.is_a?(File) ? Multipart::FileIO.new(params[:payload]) : Multipart::Param.new(key, value))
      end
      parts << Multipart::Epilogue.new

      request.content_length = parts.inject(0) { |sum, part| sum + part.length }
      request.content_type = 'multipart/form-data; boundary=' + parts.first.boundary
      request.body_stream = Multipart::Stream.new(parts.map(&:to_io))
    end

    def build_raw_file_post
      request.body = File.read(params[:payload][:file])
    end

    def setup_auth_basic
      request.basic_auth(params[:basic_auth][:user], params[:basic_auth][:password])
    end

    def set_header
      params[:headers].each do |(type, value)|
        formated_type = type.to_s.split(/_/).map(&:capitalize).join('-')

        request[formated_type] = value
      end
    end

    def setup_ssl
      http.use_ssl     = true
      http.ca_file     = params[:ca_file]
      http.verify_mode = params[:verify_mode]
    end

    def uri
      @uri ||= URI(params[:url])
    end

    def uri_proxy
      @uri_proxy ||=
        if params[:proxy]
          URI(params[:proxy])
        else
          OpenStruct.new
        end
    end

    def proxy_host
      if !uri_proxy.host.nil?
        uri_proxy.host
      else
        :ENV
      end
    end
  end
end
