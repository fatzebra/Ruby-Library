module FatZebra
  ##
  # == FatZebra \Payment \Plan
  #
  # Manage payment plan for the API
  #
  # * save
  # * find
  # * delete
  # * suspend!
  # * active!
  #
  class PaymentPlan < APIResource

    include FatZebra::APIOperation::Find
    include FatZebra::APIOperation::Save
    include FatZebra::APIOperation::Delete

    validates :payment_method, required: true, on: :create
    validates :customer, required: true, on: :create
    validates :reference, required: true, on: :create
    validates :setup_fee, required: true, on: :create
    validates :amount, required: true, on: :create
    validates :start_date, required: true, on: :create
    validates :frequency, required: true, on: :create
    validates :anniversary, required: true, on: :create
    validates :total_count, required: true, on: :create
    validates :total_amount, required: true, on: :create

    ##
    # Suspend a payment plan
    #
    # @param [Hash] params
    # @param [Hash] options for the request, and configurations (Optional)
    #
    # @return [FatZebra::PaymentPlan]
    def suspend!(params = {}, options = {})
      params = {
        new_status: 'Suspended'
      }.merge(params)

      save(params, options)
    end

    ##
    # Activate a payment plan
    #
    # @param [Hash] params
    # @param [Hash] options for the request, and configurations (Optional)
    #
    # @return [FatZebra::PaymentPlan]
    def active!(params = {}, options = {})
      params = {
        new_status: 'Active'
      }.merge(params)

      save(params, options)
    end

  end
end
