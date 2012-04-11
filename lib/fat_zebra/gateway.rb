module FatZebra
	class Gateway
		attr_accessor :username, :token, :gateway_server, :options
		
		DEFAULT_OPTIONS = {:secure => true, :version => API_VERSION}

		# Public: initializes a new gateway object
		#
		# username - merchants username
		# token - merchants token for authentication
		# gateway_server - the server for the gateway, defaults to 'gateway.fatzebra.com.au'
		# options - the options for the gateway connection (e.g. secure, version etc)
		#
		# Returns a new FatZebra::Gateway instance
		def initialize(username, token, gateway_server = GATEWAY_SERVER, options = {})
			self.username = username
			self.token = token
			self.gateway_server = gateway_server
			self.options = DEFAULT_OPTIONS.merge(options)

			require_field :username, :token, :gateway_server
		end

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
		def purchase(amount, card_data, reference, customer_ip)
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

			response = make_request(:post, "purchases", params)
			FatZebra::Models::Response.new(response)
		end

		# Retrieves purchases specified by the options hash
		#
		# @param [Hash] options for lookup
		#               includes: 
		#                 - id (unique purchase ID)
		#                 - reference (merchant reference)
		#                 - offset (defaults to 0) - for pagination
		#                 - limit (defaults to 10) for pagination
		# @return [Array<Purchase>] array of purchases
		def purchases(options = {})
			id = options.delete(:id)
			options.merge!({offets: 0, limit: 10})

			if id.nil?
				response = make_request(:get, "purchases", options)
				if response["successful"]
					purchases = []
					response["response"].each do |purchase|
						purchases << FatZebra::Models::Purchase.new(purchase)
					end

					purchases.size == 1 ? purchases.first : purchases
				else
					# TODO: This should raise a defined exception
					raise StandardError, "Unable to query purchases, #{response["errors"].inspect}"
				end
			else
				response = make_request(:get, "purchases/#{id}.json")
				if response["successful"]
					FatZebra::Models::Purchase.new(response["response"])
				else
					raise StandardError, "Unable to query purchases, #{response["errors"].inspect}"
				end
			end
		end

		# Public: Performs an authorization transaction against the gateway
		# Note: Successful transactions must then be captured for funds to settle.
		#
		# amount - the amount as an integer e.g. (1.00 * 100).to_i
		# card_number - the customers credit card number
		# card_expiry - the customers card expiry date
		# cvv - the credit card verification value (cvv, cav, csc etc)
		# reference - a reference for the purchase
		# customer_ip - the customers IP address (for fraud prevention)
		#
		# Returns a new FatZebra::Models::Purchase object
		def authorize(amount, card_number, card_expiry, cvv, reference, customer_ip)
			raise "Sorry we haven't compelted this functionality yet."
		end

		# Public: Captures a pre-authorized transaction
		#
		# transaction_id - the authorization ID
		# amount - the amount to capture, as an integer
		#
		# Returns a new FatZebra::Models::Purchase object
		def capture(transaction_id, amount)
			raise "Sorry we haven't compelted this functionality yet."
		end

		# Public: Refunds a transaction
		#
		# transaction_id - the ID of the original transaction to be refunded
		# amount - the amount to be refunded, as an integer
		# reference - the reference for the refund
		#
		# Returns a new FatZebra::Models::Refund object
		def refund(transaction_id, amount, reference)
			params = {
				:transaction_id => transaction_id,
				:amount => amount,
				:reference => reference
			}

			response = make_request(:post, "refunds", params)
			FatZebra::Models::Response.new(response, :refund)
		end

		# Public: Pings the Fat Zebra service
		# 
		# nonce - the data to be echoed back
		#
		# Returns true if reply is valid, false if times out or otherwise
		def ping(nonce = SecureRandom.hex)	
			begin
				response = RestClient.get(build_url("ping") + "?echo=#{nonce}")
				response = JSON.parse(response)

				response["echo"] == nonce
			rescue => e
				return false
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

		# Private: Verifies a require field is present and has a value
		#
		# fields - array of fields required to be present
		#
		# Returns nil
		# Raises InvalidArgumentError if field is missing
		def require_field(*fields)
			fields.each do |field|
				val = self.send(field)
				raise InvalidArgumentError, "Parameter #{field} is required", caller if (val.nil? || val.to_s.length == 0)
			end
		end

		# Public: Builds the URL for the request
		# If data is provided it will append as name/value pairs for a get request
		#
		# resource - the resource to append to the URL (e.g. purchases for https://something.com/purchases)
		# data (optional) - a hash of the data name value pairs - if nil it will be ignored
		#
		# Returns the URL as a string
		def build_url(resource, data = nil)
			proto = case options[:secure]
			when true
				"https://"
			when false
				"http://"
			end
			version = options[:version]
			url = "#{proto}#{self.gateway_server}/v#{version}/#{resource}"
			unless data.nil?
				url = url + "?"
				data.each do |key, value|
					url += "#{key}=#{value}" # TODO: URL Encode this
				end
			end

			url
		end

		# Public: Builds a new RestClient resource object
		#
		# uri - the full URI for the request
		# method - the method for the request - either :post or :get
		# data - the data for the request - only required for :get methods
		#
		# Returns a new RestClient resource
		def get_resource(uri, method = :post, data = nil)
			url = build_url(uri, (method == :get ? data : nil))
			ssl_options = options[:secure] ? {
				:ssl_ca_file =>  File.expand_path(File.dirname(__FILE__) + "/../../vendor/cacert.pem"),
  				:verify_ssl => OpenSSL::SSL::VERIFY_PEER
  			} : {}

  			opts = {:user => self.username, :password => self.token}
			RestClient::Resource.new(build_url(uri), opts.merge(ssl_options))
		end

		# Public: Performs the HTTP(s) request and returns a response object, handing errors etc
		#
		# method - the request method (:post or :get)
		# resource - the resource for the request
		# data - a hash of the data for the request
		#
		# Returns hash of response data
		def make_request(method, resource, data = nil)
			resource = get_resource(resource, method, data)

			payload = (method == :post) ? data.to_json : {}

			resource.send(method, payload) do |response, request, result, &block|
				case response.code
				when 201
					JSON.parse(response)
				when 200
					JSON.parse(response)
				when 400
					raise RequestError, "Bad Data"
				when 401
					raise RequestError, "Unauthorized, please check your username and token"
				when 404	
					raise RequestError, "Requested URL not found"
				when 500
					raise RequestError, "Server Error, please check https://www.fatzebra.com.au"
				when 501
					raise RequestError, "Problem processing your request - please check your data"
				end

			end
		end
	end
end