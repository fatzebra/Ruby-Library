module FatZebra
  ##
  # == FatZebra \Bank \Account
  #
  # Manage bank account for the API
  #
  # * search
  # * save
  #
  class BankAccount < APIResource

    extend FatZebra::APIOperation::Search

    include FatZebra::APIOperation::Save

    validates :account_name, required: true, on: :create
    validates :account_number, required: true, on: :create
    validates :bsb, required: true, on: :create

  end
end
