module FatZebra
  module Paypal
    class BillingAgreement < APIResource
      include FatZebra::APIOperation::Find
      include FatZebra::APIOperation::Search

      def self.base_path
        super + "/paypal/"
      end

      def charge(params = {}, options = {})
        response = request(:post, resource_path("billing_agreements/#{id}/charge"), params, options)
        FatZebra::Paypal::Order.initialize_from(response)
      end
    end
  end
end