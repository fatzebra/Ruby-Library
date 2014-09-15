module FatZebra
  module Models
    class Purchase < Base
      attribute :id, :amount, :reference, :message, :authorization, :transaction_id, :card_number,
            :card_holder, :card_expiry, :authorized, :successful, :card_token, :currency, :raw, :captured,
            :response_code, :rrn, :cvv_match, :fraud_result, :fraud_messages
  
      # Refunds the current transaction
      #
      # @param [Integer] amount the amount to be refunded
      # @param [String] reference the refund reference
      #
      # @return Response (Refund) object
      def refund(amount, reference)
        Refund.create(self.id, amount, reference)
      end

      # Returns the record as a Hash
      #
      # @return [Hash]
      def to_hash
        {
          id: self.id,
          amount: self.amount,
          reference: self.reference,
          message: self.message,
          authorization: self.authorization,
          card_number: self.card_number,
          card_holder: self.card_holder,
          card_expiry: self.card_expiry,
          card_token: self.card_token,
          currency: self.currency,
          authorized: self.authorized,
          successful: self.successful,
          captured: self.captured,
          response_code: self.response_code,
          cvv_match: self.cvv_match,
          rrn: self.rrn,
          fraud_result: self.fraud_result,
          fraud_messages: self.fraud_messages
        }
      end

      class << self
        # Performs a purchase transaction against the gateway
        #
        # @param [Integer] amount the amount as an integer e.g. (1.00 * 100).to_i
        # @param [Hash] card_data a hash of the card data (example: {:card_holder => "John Smith", :number => "...", :expiry => "...", :cvv => "123"} or {:token => "abcdefg1"})
        # @option card_data [String] card_holder the card holders name
        # @option card_data [String] card_number the customers credit card number
        # @option card_data [Date] expiry the customers card expiry date (as Date or string [mm/yyyy])
        # @option card_data [String] cvv the credit card verification value (cvv, cav, csc etc)
        # @param [String] reference a reference for the purchase
        # @param [String] customer_ip the customers IP address (for fraud prevention)
        # @param [String] currency currency code ("AUD", "USD", etc)
        # @param [Hash] optional any optional parameters to be included in the payload
        #
        # @return [Response] response (purchase) object
        def create(amount, card_data, reference, customer_ip, currency = 'AUD', optional = {})
          params = {
            :amount => amount,
            :card_holder => card_data.delete(:card_holder),
            :card_number => card_data.delete(:number),
            :card_expiry => extract_date(card_data.delete(:expiry)),
            :cvv => card_data.delete(:cvv),
            :card_token => card_data.delete(:token),
            :reference => reference,
            :customer_ip => customer_ip,
            :currency => currency
          }

          params.delete_if {|_, value| value.nil? } # If token is nil, remove, otherwise, remove card values
          params.merge!(optional)
          validate_params!(params)
          response = FatZebra.gateway.make_request(:post, 'purchases', params)
          Response.new(response)
        end

        # Retrieves purchases specified by the options hash
        #
        # @param [Hash] options for lookup
        # @option options [String] id the unique purchase ID
        # @option options [String] reference the merchant reference
        # @option options [DateTime] from the start date to search from
        # @option options [DateTime] to the end date time to search to
        # @option options [Integer] offset the start page for pagination
        # @option options [Integer] limit the maximum number of records to return in the query. Maximum 10
        #
        # @return [Array<Purchase>] array of purchases
        def find(options = {})
          id = options.delete(:id)
          options.merge!({:offets => 0, :limit => 10})

          # Format dates for the request
          options[:from] = options[:from].strftime('%Y%m%dT%H%M') if options[:from]
          options[:to] = options[:to].strftime('%Y%m%dT%H%M') if options[:to]


          if id.nil?
            response = FatZebra.gateway.make_request(:get, 'purchases', options)
            if response['successful']
              purchases = []
              response['response'].each do |purchase|
                purchases << Purchase.new(purchase)
              end

              purchases.size == 1 ? purchases.first : purchases
            else
              # TODO: This should raise a defined exception
              raise StandardError, "Unable to query purchases, #{response['errors'].inspect}"
            end
          else
            response = FatZebra.gateway.make_request(:get, "purchases/#{id}.json")
            if response['successful']
              Purchase.new(response['response'])
            else
              raise StandardError, "Unable to query purchases, #{response['errors'].inspect}"
            end
          end
        end

        private
        # Private: Extracts the date value from a Date/DateTime value
        #
        # value - the string or date value to extract the value from
        #
        # Returns date string as MM/YYYY
        def extract_date(value)
          return nil if value.nil?

          if value.is_a?(String)
            return value
          elsif value.respond_to?(:strftime)
            return value.strftime('%m/%Y')
          end
        end

        # Private: Validates the parameters provided meet the gateway requirements
        #
        # params - the parameter hash to be validated
        #
        # Returns nil
        # Raises FatZebra::RequestError if errors are present.
        def validate_params!(params)
          @errors = []
          @errors << 'number or token must be provided' unless params[:card_number].present? || params[:card_token].present? || params[:wallet].present?
          @errors << 'amount must be provided or greater then 0' unless params[:amount].present? && params[:amount].to_f > 0
          @errors << 'expiry must be provided' unless params[:card_token].present? || params[:card_expiry].present? || params[:wallet].present?
          @errors << 'reference must be provided' unless params[:reference].present?
          @errors << 'customer_ip must be provided' unless params[:customer_ip].present?

          raise FatZebra::RequestError.new("The following errors prevent the transaction from being submitted: #{@errors.to_sentence}") if @errors.any?
        end
      end
    end
  end
end