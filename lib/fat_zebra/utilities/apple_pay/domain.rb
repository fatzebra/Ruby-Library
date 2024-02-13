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
          def register!
            response = request(:post, ENDPOINT_URL)
            initialize_from(response)
          end

          ##
          # Check registration status of an Apple Pay (web) domain
          #
          # @return [FatZebra::Utilities::ApplePay::Domains] response
          def registered?
            response = request(:get, ENDPOINT_URL)
            initialize_from(response)
          end

          ##
          # Delete an Apple Pay (web) domain
          #
          # @return [FatZebra::Utilities::ApplePay::Domains] response
          def delete!
            response = request(:delete, ENDPOINT_URL)
            initialize_from(response)
          end
        end
      end
    end
  end
end
