module FatZebra
  ##
  # == FatZebra \Card
  #
  # Manage credit card for the API
  #
  # * save
  #
  class Card < APIResource
    @resource_name = 'credit_cards'

    include FatZebra::APIOperation::Save

    validates :card_holder, required: true, on: :create
    validates :card_number, required: true, on: :create
    validates :card_expiry, required: true, on: :create
    validates :cvv, required: true, on: :create

    validates :card_expiry, required: true, on: :update

  end
end
