module FatZebra
  module Paypal
    class Refund < APIResource
      include FatZebra::APIOperation::Find
      include FatZebra::APIOperation::Search

      def self.base_path
        super + "/paypal/"
      end

    end
  end
end