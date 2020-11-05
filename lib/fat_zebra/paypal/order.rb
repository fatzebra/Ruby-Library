module FatZebra
  ##
  # == FatZebra \Paypal::Order
  #
  # Manage PayPal Orders
  #
  # * search
  # * find
  #
  module Paypal
    class Order < APIResource
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
