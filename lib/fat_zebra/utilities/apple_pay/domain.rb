# frozen_string_literal: true

module FatZebra
  module Utilities
    module ApplePay
      class Domain < APIResource

        ENDPOINT_URL = '/v1.0/utilities/apple_pay/domains'

        class << self

          ##
          # List Apple Pay (web) domains
          #
          # @return [FatZebra::Utilities::ApplePay::Domains] response
          def list(options: {})
            params = {}
            response = request(:get, ENDPOINT_URL, params, options)
            initialize_from(response)
          end

          ##
          # Register an Apple Pay (web) domain
          #
          # @return [FatZebra::Utilities::ApplePay::Domains] response
          def register!(domain, params = {}, options: {})
            response = request(:post, path(domain), params, options)
            initialize_from(response)
          end

          ##
          # Check registration status of an Apple Pay (web) domain
          #
          # @return [FatZebra::Utilities::ApplePay::Domains] response
          def find!(domain, options: {})
            params = {}
            response = request(:get, path(domain), params, options)
            initialize_from(response)
          end

          ##
          # Delete an Apple Pay (web) domain
          #
          # @return [FatZebra::Utilities::ApplePay::Domains] response
          def delete!(domain, options: {})
            params = {}
            response = request(:delete, path(domain), params, options)
            initialize_from(response)
          end

          private

          def path(domain)
            "#{ENDPOINT_URL}/#{domain}"
          end
        end
      end
    end
  end
end
