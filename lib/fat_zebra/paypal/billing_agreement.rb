module FatZebra
  ##
  # == FatZebra \Paypal::BillingAgreement
  #
  # Manage PayPal Billing Agreements
  #
  # * search
  # * find
  # * charge
  # * cancel
  #
  module Paypal
    class BillingAgreement < APIResource
      include FatZebra::APIOperation::Find
      include FatZebra::APIOperation::Search

      validates :purchases, required: true, on: :charge
      validates :amount, required: true, on: :charge
      validates :currency, required: true, on: :charge
      validates :reference, required: true, on: :charge

      class << self
        def base_path
          super + '/paypal/'
        end

        ##
        # Charge a PayPal Billing Agreement
        #
        # @param [String] Billing Agreement id
        # @param [Hash] params (currency, reference, amount, purchases)
        # @param [Hash] options for the request, and configurations (Optional)
        #
        # @return [FatZebra::Paypal::Order]
        def charge(id, params, options = {})
          valid!(params, :charge) if respond_to?(:valid!)

          response = request(:post, resource_path("billing_agreements/#{id}/charge"), params, options)
          FatZebra::Paypal::Order.initialize_from(response)
        end

        ##
        # Cancel a PayPal Billing Agreement
        #
        # @param [String] Billing Agreement id
        # @param [Hash] options for the request, and configurations (Optional)
        #
        # @return [FatZebra::BillingAgreement]
        def cancel(id, options = {})
          response = request(:post, resource_path("billing_agreements/#{id}/cancel"), {}, options)
          initialize_from(response)
        end
      end
    end
  end
end
