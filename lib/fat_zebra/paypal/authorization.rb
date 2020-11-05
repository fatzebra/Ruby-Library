module FatZebra
  ##
  # == FatZebra \Paypal::Authorization
  #
  # Manage PayPal Authorizations
  #
  # * search
  # * find
  # * capture
  # * void
  #
  module Paypal
    class Authorization < APIResource
      include FatZebra::APIOperation::Find
      include FatZebra::APIOperation::Search

      class << self
        def base_path
          super + '/paypal/'
        end

        ##
        # Capture a PayPal Authorization
        #
        # @param [String] Authorization id
        # @param [Hash] params (amount, final_capture, note_to_payer)
        # @param [Hash] options for the request, and configurations (Optional)
        #
        # @return [FatZebra::Paypal::Capture]
        def capture(id, params = {}, options = {})
          response = request(:post, resource_path("authorizations/#{id}/capture"), params, options)
          FatZebra::Paypal::Capture.initialize_from(response)
        end

        ##
        # Void a PayPal Authorization
        #
        # @param [String] Authorization id
        # @param [Hash] options for the request, and configurations (Optional)
        #
        # @return [FatZebra::Authorization]
        def void(id, options = {})
          response = request(:post, resource_path("authorizations/#{id}/void"), {}, options)
          initialize_from(response)
        end
      end
    end
  end
end
