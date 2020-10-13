module FatZebra
  ##
  # == FatZebra \Paypal::Capture
  #
  # Manage PayPal Captures
  #
  # * search
  # * find
  # * refund
  #
  module Paypal
    class Capture < APIResource
      include FatZebra::APIOperation::Find
      include FatZebra::APIOperation::Search

      class << self
        def base_path
          super + '/paypal/'
        end

        ##
        # Refund a PayPal Capture
        #
        # @param [String] Capture id
        # @param [Hash] params (amount, note_to_payer)
        # @param [Hash] options for the request, and configurations (Optional)
        #
        # @return [FatZebra::Paypal::Refund]
        def refund(id, params = {}, options = {})
          response = request(:post, resource_path("captures/#{id}/refund"), params, options)
          FatZebra::Paypal::Refund.initialize_from(response)
        end
      end
    end
  end
end
