module FatZebra
  ##
  # == FatZebra \Direct \Credit
  #
  # Manage direct credit for the API
  #
  # * search
  # * save
  # * find
  # * delete
  #
  class DirectCredit < APIResource

    extend FatZebra::APIOperation::Find
    extend FatZebra::APIOperation::Search

    include FatZebra::APIOperation::Save
    include FatZebra::APIOperation::Delete

    validates :description, required: true, on: :create
    validates :amount, required: true, class_type: Integer, on: :create
    validates :bsb, required: true, on: :create
    validates :account_name, required: true, on: :create
    validates :account_number, required: true, on: :create

  end
end
