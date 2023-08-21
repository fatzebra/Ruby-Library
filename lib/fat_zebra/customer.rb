# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Customer
  #
  # Manage customer for the API
  #
  # * search
  # * save
  # * find
  # * delete
  #
  class Customer < APIResource

    include FatZebra::APIOperation::Search
    include FatZebra::APIOperation::Find
    include FatZebra::APIOperation::Save
    include FatZebra::APIOperation::Delete

    validates :first_name, required: true, on: :create
    validates :last_name, required: true, on: :create
    validates :reference, required: true, on: :create
    validates :email, required: true, on: :create
    validates :ip_address, required: true, on: :create

  end
end
