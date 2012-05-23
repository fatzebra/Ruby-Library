module FatZebra
	module Models
		class Response
			attr_accessor :successful, :result, :errors, :test, :raw
			def initialize(response, type = :purchase)
				self.raw = response.dup unless response.nil?
				self.test = response["test"]
				self.successful = response["successful"]
				self.errors = response["errors"]
				
				case type
					when :purchase
						self.result = Purchase.new(response["response"])
						alias purchase result
					when :refund
						self.result = Refund.new(response["response"])
						alias refund result
				end
			end

			def successful?
				self.successful
			end

			def test?
				self.test
			end
		end
	end
end