# frozen_string_literal: true

module FatZebra
  module Utilities
    module Mastercard
      module ClickToPay
        class Registration < APIResource

          ENDPOINT_URL = '/v1.0/utilities/mastercard/click_to_pay/registration'

          class << self

            ##
            # Register with Mastercard Click To Pay
            #
            # @return [FatZebra::Utilities::Mastercard::ClickToPay::Registration] response
            def register!
              response = request(:post, ENDPOINT_URL)
              initialize_from(response)
            end

            ##
            # Lookup regisrtation with Mastercard Click To Pay
            #
            # @return [FatZebra::Utilities::Mastercard::ClickToPay::Registration] response
            def registered?
              response = request(:get, ENDPOINT_URL)
              initialize_from(response)
            end
          end
        end
      end
    end
  end
end