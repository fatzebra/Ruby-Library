module FatZebra
	module Models
		class Refund < Base
			attribute :amount, :reference, :refunded, :id, :message, :transaction_id, :original_transaction_id, :transaction_date, :settlement_date,
								:response_code, :message, :rrn, :authorisation, :raw

			# Returns the original transaction for this refund
			#
			# @return Purchase
			def original_transaction
				@original_transaction ||= Purchase.find(self.original_transaction_id)
			end

			# Indicates if the refund was successful or not
			#
			# @return Boolean
			def successful
				self.refunded == "Approved"
			end
			alias successful? successful

			class << self
				# Refunds a transaction
				#
				# @param [String] the ID of the original transaction to be refunded
				# @param [Integer] the amount to be refunded, as an integer
				# @param [String] the reference for the refund
				# @param [Hash] optional optional parameters to be included in the request
				#
				# @return [Refund] refund result object
				def create(transaction_id, amount, reference, optional = {})
					params = {
						:transaction_id => transaction_id,
						:amount => amount,
						:reference => reference
					}

					params.merge!(optional)

					response = FatZebra.gateway.make_request(:post, "refunds", params)
					Response.new(response, :refund)
				end
			end
		end
	end
end