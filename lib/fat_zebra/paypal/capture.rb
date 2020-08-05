module FatZebra
  module Paypal
    class Capture < APIResource
      include FatZebra::APIOperation::Find
      include FatZebra::APIOperation::Search

      def self.base_path
        super + "/paypal/"
      end

      def refund(params = {}, options = {})
        response = request(:post, resource_path("captures/#{id}/refund"), params, options)
        FatZebra::Paypal::Refund.initialize_from((response)
      end
    end
  end
end