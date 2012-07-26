module FatZebra
	class Refund < Models::Base
		attribute :amount, :reference, :refunded, :id, :message, :transaction_id, :original_transaction_id, :raw

		def original_transaction
			@original_transaction ||= Purchase.find(self.original_transaction_id)
		end

		def successful
			self.refunded == "Approved"
		end
		alias successful? successful
	end
end