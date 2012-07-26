module FatZebra
	class Card < Models::Base
		attribute :token, :card_holder, :card_number, :card_expiry, :transaction_count, :raw
	end
end