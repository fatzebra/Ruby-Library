# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Web \Hook
  #
  # Manage web hook for the API
  #
  # * search
  # * save
  # * delete
  #
  class WebHook < APIResource

    include FatZebra::APIOperation::Search
    include FatZebra::APIOperation::Save
    include FatZebra::APIOperation::Delete

    validates :events, required: true, on: :create
    validates :mode, required: true, on: :create
    validates :address, required: true, on: :create

  end
end
