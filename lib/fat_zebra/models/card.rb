module FatZebra
	module Models
		class Card < Base
			attribute :token, :card_holder, :card_number, :card_expiry, :transaction_count, :raw

    def charge!()

    end

    class << self
      # Tokenizes a credit card
      # 
      # @param [String] the credit card holder name
      # @param [String] the card number
      # @param [String] the credit card expiry date (mm/yyyy)
      # @param [String] the card CVV
      #
      # @return Response
      def create(card_holder, card_number, expiry, cvv)
        params = {
          :card_holder => card_holder,
          :card_number => card_number,
          :card_expiry => expiry,
          :cvv => cvv
        }

        response = FatZebra.gateway.make_request(:post, "credit_cards", params)
        Response.new(response, :card)
      end
    end
	end
end