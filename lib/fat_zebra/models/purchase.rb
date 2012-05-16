module FatZebra
	module Models
		class Purchase < Base
			attribute :id, :amount, :reference, :message, :authorization, :transaction_id, :card_number,
					  :card_holder, :card_expiry, :authorized, :successful, :card_token, :raw
		end
	end
end