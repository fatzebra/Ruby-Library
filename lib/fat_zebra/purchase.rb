# frozen_string_literal: true

module FatZebra
  ##
  # == FatZebra \Purchase
  #
  # Manage purchase for the API
  #
  # * search
  # * save
  # * find
  # * void
  # * settlement
  # * refund
  # * capture
  #
  class Purchase < APIResource

    include FatZebra::APIOperation::Find
    include FatZebra::APIOperation::Search
    include FatZebra::APIOperation::Save
    include FatZebra::APIOperation::Void

    validates :card_number, required: { unless: %i[card_token wallet] }, on: :create
    validates :card_token, required: { unless: %i[card_number wallet] }, on: :create
    validates :card_expiry, required: { unless: %i[card_token wallet] }, on: :create
    validates :amount, required: true, type: :positive_integer, on: :create
    validates :reference, required: true, on: :create
    validates :customer_ip, required: true, on: :create

    validates :from, required: true, on: :settlement
    validates :to, required: true, on: :settlement

    class << self

      ##
      # Create a payment plan
      # Default currency to AUD
      #
      # @param [Hash] params
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::PaymentPlan]
      def create(params, options = {})
        params[:currency] ||= 'AUD'

        super(params, options)
      end

      ##
      # Return all the settlements
      #
      # @param [Hash] params (from and to are date required)
      # @param [Hash] options for the request, and configurations (Optional)
      #
      # @return [FatZebra::Purchase]
      def settlement(params = {}, options = {})
        valid!(params, :settlement) if respond_to?(:valid!)

        response = request(:get, "#{resource_path}/settlement", params, options)
        initialize_from(response)
      end

    end

    ##
    # Refunds the current purchase
    #
    # @param [Hash] params for refund API (Optional)
    # @param [Hash] options for the request, and configurations (Optional)
    #
    # @return [FatZebra::Refund] object
    def refund(params = {}, options = {})
      Refund.create({
        transaction_id: id,
        amount: amount,
        reference: reference
      }.merge(params), options)
    end

    ##
    # Captures an authorization
    #
    # @param [Hash] params for capture API (Optional)
    # @param [Hash] options for the request, and configurations (Optional)
    #
    # @return [Response] Purchase response object
    def capture(params = {}, options = {})
      params = {
        amount: amount
      }.merge(params)

      response = request(:post, resource_path("purchases/#{id}/capture"), params, options)
      update_from(response)
    end

    ##
    # Extends an authorization expiry (if not already expired)
    #
    # @param [Hash] options for the request, and configurations (Optional)
    #
    # @return [Response] Purchase response object
    def extend!(options = {})
      response = request(:put, resource_path("purchases/#{id}"), { extend: true }, options)
      update_from(response)
    end

    ##
    # Increments an authorization amount
    #
    # @param [Int] amount to increment the authorization by
    # @param [Hash] options for the request, and configurations (Optional)
    #
    # @return [Response] Purchase response object
    def increment!(additional_amount, options = {})
      raise ArgumentError, 'Amount must be a positive amount' unless additional_amount > 0

      response = request(:put, resource_path("purchases/#{id}"), { amount: amount + additional_amount }, options)
      update_from(response)
    end
  end
end
