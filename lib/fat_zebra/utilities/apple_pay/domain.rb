# frozen_string_literal: true

module FatZebra
  module Utilities
    module ApplePay
      class Domain < APIResource

        ENDPOINT_URL = '/v1.0/utilities/apple_pay/domains'

        class << self

          ##
          # Register an Apple Pay (web) domain
          #
          # @return [FatZebra::Utilities::ApplePay::Domains] response
          def register!(domain, params = {})
            response = request(:post, path(domain), params)
            initialize_from(response)
          end

          ##
          # Check registration status of an Apple Pay (web) domain
          #
          # @return [FatZebra::Utilities::ApplePay::Domains] response
          def find!(domain)
            response = request(:get, path(domain))
            initialize_from(response)
          end

          ##
          # Delete an Apple Pay (web) domain
          #
          # @return [FatZebra::Utilities::ApplePay::Domains] response
          def delete!(domain)
            response = request(:delete, path(domain))
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
