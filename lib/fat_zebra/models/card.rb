module FatZebra
  module Models
    class Card < Base
      attribute :token, :card_holder, :card_number, :card_expiry, :transaction_count, :raw

      def successful; true; end

      class << self
        # Tokenizes a credit card
        # 
        # @param [String] the credit card holder name
        # @param [String] the card number
        # @param [String] the credit card expiry date (mm/yyyy)
        # @param [String] the card CVV
        # @param [Hash] optional any additional data which should be merged into the request
        #
        # @return Response
        def create(card_holder, card_number, expiry, cvv, optional = {})
          params = {
            :card_holder => card_holder,
            :card_number => card_number,
            :card_expiry => expiry,
            :cvv => cvv
          }

          params.merge!(optional)
          
          response = FatZebra.gateway.make_request(:post, "credit_cards", params)
          Response.new(response, :card)
        end

        # Update the credit card expiry date
        #
        # @param [String] token the credit card token
        # @param [String] expiry the new expiry date (format: mm/yyyy)
        #
        # @return [Response]
        def update_expiry(token, expiry)
          params = {
                  card_expiry: expiry
          }

          response = FatZebra.gateway.make_request(:put, "credit_cards/#{token}", params)
          Response.new(response, :card)
        end
      end
    end
  end
end