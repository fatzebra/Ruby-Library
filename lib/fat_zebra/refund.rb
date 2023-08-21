# frozen_string_literal: true

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

    include FatZebra::APIOperation::Find
    include FatZebra::APIOperation::Search
    include FatZebra::APIOperation::Save
    include FatZebra::APIOperation::Void

    validates :amount, required: true, on: :create
    validates :reference, required: true, on: :create

    def declined?
      refunded == 'Declined'
    end

  end
end
