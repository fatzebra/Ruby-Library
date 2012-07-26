module FatZebra
	class Purchase < Models::Base
		attribute :id, :amount, :reference, :message, :authorization, :transaction_id, :card_number,
				  :card_holder, :card_expiry, :authorized, :successful, :card_token, :raw
	
    class << self
      # Public: Performs a purchase transaction against the gateway
      #
      # amount - the amount as an integer e.g. (1.00 * 100).to_i
      # card_data - a hash of the card data (example: {:card_holder => "John Smith", :number => "...", :expiry => "...", :cvv => "123"} or {:token => "abcdefg1"})
      # card_holder - the card holders name
      # card_number - the customers credit card number
      # card_expiry - the customers card expiry date (as Date or string [mm/yyyy])
      # cvv - the credit card verification value (cvv, cav, csc etc)
      # reference - a reference for the purchase
      # customer_ip - the customers IP address (for fraud prevention)
      #
      # Returns a new FatZebra::Models::Response (purchase) object
      def create(amount, card_data, reference, customer_ip)
        params = {
          :amount => amount,
          :card_holder => card_data.delete(:card_holder),
          :card_number => card_data.delete(:number),
          :card_expiry => extract_date(card_data.delete(:expiry)),
          :cvv => card_data.delete(:cvv),
          :card_token => card_data.delete(:token),
          :reference => reference,
          :customer_ip => customer_ip
        }

        params.delete_if {|key, value| value.nil? } # If token is nil, remove, otherwise, remove card values

        response = FatZebra.gateway.make_request(:post, "purchases", params)
        Response.new(response)
      end

      # Retrieves purchases specified by the options hash
      #
      # @param [Hash] options for lookup
      #               includes: 
      #                 - id (unique purchase ID)
      #                 - reference (merchant reference)
      #           - from (Date)
      #           - to (Date)
      #                 - offset (defaults to 0) - for pagination
      #                 - limit (defaults to 10) for pagination
      # @return [Array<Purchase>] array of purchases
      def find(options = {})
        id = options.delete(:id)
        options.merge!({:offets => 0, :limit => 10})

        # Format dates for the request
        options[:from] = options[:from].strftime("%Y%m%dT%H%M") if options[:from]
        options[:to] = options[:to].strftime("%Y%m%dT%H%M") if options[:to]


        if id.nil?
          response = make_request(:get, "purchases", options)
          if response["successful"]
            purchases = []
            response["response"].each do |purchase|
              purchases << Purchase.new(purchase)
            end

            purchases.size == 1 ? purchases.first : purchases
          else
            # TODO: This should raise a defined exception
            raise StandardError, "Unable to query purchases, #{response["errors"].inspect}"
          end
        else
          response = make_request(:get, "purchases/#{id}.json")
          if response["successful"]
            Purchase.new(response["response"])
          else
            raise StandardError, "Unable to query purchases, #{response["errors"].inspect}"
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
          return value.strftime("%m/%Y")
        end
      end

    end
	end
end