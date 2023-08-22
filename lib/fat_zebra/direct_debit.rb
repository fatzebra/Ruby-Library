# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Direct \Debit
  #
  # Manage direct debit for the API
  #
  # * search
  # * save
  # * find
  # * delete
  #
  class DirectDebit < APIResource

    include FatZebra::APIOperation::Find
    include FatZebra::APIOperation::Search
    include FatZebra::APIOperation::Save
    include FatZebra::APIOperation::Delete

    validates :description, required: true, on: :create
    validates :amount, required: true, type: :positive_float, on: :create
    validates :bsb, required: true, on: :create
    validates :account_name, required: true, on: :create
    validates :account_number, required: true, on: :create

  end
end
