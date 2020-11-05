module FatZebra
  ##
  # == FatZebra \Paypal::Refund
  #
  # Manage PayPal Refunds
  #
  # * search
  # * find
  #
  module Paypal
    class Refund < APIResource
      include FatZebra::APIOperation::Find
      include FatZebra::APIOperation::Search

      class << self
        def base_path
          super + '/paypal/'
        end
      end
    end
  end
end
