module FatZebra
	module Models
		class Card < Base
			attribute :token, :card_holder, :card_number, :card_expiry, :transaction_count, :raw
		end
	end
end