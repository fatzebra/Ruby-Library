module FatZebra
	class Gateway
		attr_accessor :username, :token, :gateway_server, :options
		
		DEFAULT_OPTIONS = {:secure => true, :version => API_VERSION}

		class << self
			def configure(config)
				g = Gateway.new(config.username, config.token, config.gateway || GATEWAY_SERVER)
				g.options ||= {}
				g.options[:test_mode] = config.test_mode
				g.options.merge!(config.options || {})
				g.proxy = g.options[:proxy]

				g
			end
		end

		# Initializes a new gateway object
		#
		# @param [String] merchants username
		# @param [String] merchants token for authentication
		# @param [String] the server for the gateway, defaults to 'gateway.fatzebra.com.au'
		# @param [Hash] the options for the gateway connection (e.g. secure, version etc)
		#
		# @return FatZebra::Gateway instance
		def initialize(username, token, gateway_server = GATEWAY_SERVER, options = {})
			self.username = username
			self.token = token
			self.gateway_server = gateway_server
			self.options = DEFAULT_OPTIONS.merge(options)
			self.proxy = self.options[:proxy]

			require_field :username, :token, :gateway_server
		end

		# Set the proxy for RestClient
		#
		# @param [String] val the proxy
		#
		# @return Nil
		def proxy=(val)
			RestClient.proxy = val
		end

		# Get the proxy set for RestClient
		#
		# @return [String] the proxy set for RestClient
		def proxy
			RestClient.proxy
		end

		# Performs a purchase transaction against the gateway
		#
		# amount - the amount as an integer e.g. (1.00 * 100).to_i
		# card_data - a hash of the card data (example: {:card_holder => "John Smith", :number => "...", :expiry => "...", :cvv => "123"} or {:token => "abcdefg1"})
		# card_holder - the card holders name
		# card_number - the customers credit card number
		# card_expiry - the customers card expiry date (as Date or string [mm/yyyy])
		# cvv - the credit card verification value (cvv, cav, csc etc)
		# reference - a reference for the purchase
		# customer_ip - the customers IP address (for fraud prevention)
		# currency - the currency of the transaction, ISO 4217 code (http://en.wikipedia.org/wiki/ISO_4217)
		#
		# Returns a new FatZebra::Models::Response (purchase) object
		def purchase(amount, card_data, reference, customer_ip, currency = "AUD")
			warn "[DEPRECATED] Gateway#purchase is deprecated, please use Purchase.create instead" unless options[:silence]
			Models::Purchase.create(amount, card_data, reference, customer_ip, currency)
		end

		# Retrieves purchases specified by the options hash
		#
		# @param [Hash] options for lookup
		#               includes: 
		#                 - id (unique purchase ID)
		#                 - reference (merchant reference)
		# 				  - from (Date)
		# 				  - to (Date)
		#                 - offset (defaults to 0) - for pagination
		#                 - limit (defaults to 10) for pagination
		# @return [Array<Purchase>] array of purchases
		# @deprecated Please use Purchase.find(options) instead
		def purchases(options = {})
			warn "[DEPRECATED] Gateway#purchases is deprecated, please use Purchase.find instead" unless options[:silence]
			Models::Purchase.find(options)
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

		# Refunds a transaction
		#
		# @param [String] the ID of the original transaction to be refunded
		# @param [Integer] the amount to be refunded, as an integer
		# @param [String] the reference for the refund
		#
		# @return [Refund] refund result object
		# @deprecated Please use Refund.create or Purchase#refund instead
		def refund(transaction_id, amount, reference)
			warn "[DEPRECATED] Gateway#refund is deprecated, please use Refund.create or Purchase#refund instead`" unless options[:silence]
			Models::Refund.create(transaction_id, amount, reference)
		end

		# Pings the Fat Zebra service
		# 
		# @param [String] the data to be echoed back
		#
		# @return true if reply is valid, false if the request times out, or otherwise
		def ping(nonce = SecureRandom.hex)	
			begin
				response = RestClient.get(build_url("ping") + "?echo=#{nonce}")
				response = JSON.parse(response)

				response["echo"] == nonce
			rescue => e
				return false
			end
		end

		# Tokenizes a credit card
		# 
		# @param [String] the credit card holder name
		# @param [String] the card number
		# @param [String] the credit card expiry date (mm/yyyy)
		# @param [String] the card CVV
		#
		# @return Response
		# @deprecated Please use Card.create instead
		def tokenize(card_holder, card_number, expiry, cvv)
			warn "[DEPRECATED] Gateway#tokenize is deprecated, please use Card.create instead" unless options[:silence]
			Models::Card.create(card_holder, card_number, expiry, cvv)
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

			if [:post, :put, :patch].include?(method)
				data[:test] = options[:test_mode] if options[:test_mode]
				payload = data.to_json
			else
				payload = {}
			end

			headers = options[:headers] || {}

			if method == :get
				resource.send(method, headers) do |response, request, result, &block|
					handle_response(response)
				end
			else
				# Add in test flag is test mode...
				resource.send(method, payload, headers) do |response, request, result, &block|
					handle_response(response)
				end
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
			if version.nil?
				url = "#{proto}#{self.gateway_server}/#{resource}"
			else
				url = "#{proto}#{self.gateway_server}/v#{version}/#{resource}"
			end

			unless data.nil?
				url = url + "?" + 
				data.map do |key, value|
					"#{key}=#{value}" # TODO: URL Encode this
				end.join("&")
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
			if method == :get
				url = build_url(uri, data)
			else
				url = build_url(uri)
			end

			RestClient::Resource.new(url, opts.merge(ssl_options))
		end

		def handle_response(response)
			case response.code
			when 201
				JSON.parse(response)
			when 200
				JSON.parse(response)
			when 422
				JSON.parse(response)
			when 400
				raise RequestError, "Bad Data"
			when 401
				raise RequestError, "Unauthorized, please check your username and token"
			when 404	
				raise RequestError, "Requested Resource not found"
			when 500
				raise RequestError, "Server Error, please check with Gateway"
			when 501
				raise RequestError, "Problem processing your request - please check your data"
			end
		end
	end
end