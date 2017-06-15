module FatZebra
  ##
  # == FatZebra \Refund
  #
  # Manage refund for the API
  #
  # * search
  # * save
  # * find
  # * void
  #
  class Refund < APIResource

    extend FatZebra::APIOperation::Find
    extend FatZebra::APIOperation::Search

    include FatZebra::APIOperation::Save
    include FatZebra::APIOperation::Void

    validates :transaction_id, required: true, on: :create
    validates :amount, required: true, on: :create
    validates :reference, required: true, on: :create

  end
end
