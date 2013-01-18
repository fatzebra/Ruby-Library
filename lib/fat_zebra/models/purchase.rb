module FatZebra
	module Models
		class Purchase < Base
			attribute :id, :amount, :reference, :message, :authorization, :transaction_id, :card_number,
					  :card_holder, :card_expiry, :authorized, :successful, :card_token, :raw, :currency

      def approved?
        self.successful
      end

      def card_type
        cards = []
        cards[4] = "VISA"
        cards[5] = "MasterCard"
        cards[3] = "AMEX/JCB"
      end
		end
	end
end