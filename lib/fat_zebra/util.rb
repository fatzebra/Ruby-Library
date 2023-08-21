# frozen_string_literal: true

module FatZebra
  module Util
    class << self

      DATE_FORMAT = '%Y/%m/%d'
      REGEXP_HTTP = %r{https?://}.freeze

      def cleanup_host(uri)
        uri.to_s.gsub(REGEXP_HTTP, '')
      end

      ##
      # Remove nil value from hash
      #
      # @return [Hash]
      def compact(hash)
        hash.reject { |_, value| value.nil? }
      end

      ##
      # Convert string to camelize
      #
      # @param [String]
      #
      # @example
      #   camelize('my_model') => 'MyModel'
      def camelize(string)
        string.split('_').map(&:capitalize).join
      end

      ##
      # Encodes a hash of parameters in a way that's suitable for use as query
      # parameters in a URI or as form parameters in a request body. This mainly
      # involves escaping special characters from parameter keys and values (e.g.
      # `&`).
      def encode_parameters(params = {})
        params.map { |k, v| "#{url_encode(k)}=#{url_encode(v)}" }.join('&')
      end

      ##
      # Encodes a string in a way that makes it suitable for use in a set of
      # query parameters in a URI or in a set of form parameters in a request
      # body.
      def url_encode(key)
        CGI.escape(key.to_s).gsub('%5B', '[').gsub('%5D', ']')
      end

      ##
      # Convert string to underscore
      #
      # @param [String]
      #
      # @example
      #   underscore('MyModel') => 'my_model'
      def underscore(string)
        string
          .gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
          .gsub(/([a-z\d])([A-Z])/, '\1_\2')
          .tr('-', '_')
          .downcase
      end

      def hash_except(hash, *keys)
        copy = hash.dup
        keys.each { |key| copy.delete(key) }
        copy
      end

      ##
      # Format Date attribute in the params
      #
      # @param [Hash] params
      #
      # @return [Hash] date formated params
      def format_dates_in_hash(hash)
        hash.each do |(key, value)|
          hash[key] = value.strftime(DATE_FORMAT) if value.is_a?(DateTime) || value.is_a?(Time) || value.is_a?(Date)
        end

        hash
      end

    end
  end
end
