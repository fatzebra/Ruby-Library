module FatZebra
  module Paypal
    class Authorization < APIResource
      include FatZebra::APIOperation::Find
      include FatZebra::APIOperation::Search

      def self.base_path
        super + "/paypal/"
      end

      def capture(params = {}, options = {})
        response = request(:post, resource_path("authorizations/#{id}/capture"), params, options)
        FatZebra::Paypal::Capture.initialize_from(response)
      end

      def void(id, options = {})
        response = request(:post, resource_path("authorizations/#{id}/capture"), params, options)
        update_from(response)
      end
    end
  end
end