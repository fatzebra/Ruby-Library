require 'securerandom'
require 'json'
require 'rest_client'
require 'active_support/core_ext'

require 'fat_zebra/config'
require 'fat_zebra/errors'
require 'fat_zebra/version'
require 'fat_zebra/constants'
require 'fat_zebra/gateway'
require 'fat_zebra/models/base'
require 'fat_zebra/models/purchase'
require 'fat_zebra/models/refund'
require 'fat_zebra/models/card'
require 'fat_zebra/models/response'

module FatZebra
  extend self
  extend Forwardable

	attr_accessor :config
  attr_accessor :_gateway

  # Configure the Fat Zebra gateway
  def configure(auth = nil, &block)
		raise ArgumentError, "missing authentication parameters or block" unless auth || block_given?

  	if !auth
      self.config = Config.new
      if (block.arity > 0)
        block.call(self.config)
      else
        self.config.instance_eval(&block)
      end
    else
      self.config = Config.from_hash(auth)
    end

    self.config.validate!

    self.configure_gateway

    self.config
	end

  def configure_gateway
    self._gateway = Gateway.configure(self.config)
  end

  def gateway
    raise GatewayError.new("Please configure the Gateway before use. See FatZebra.configure { }") if self.config.nil?
    self._gateway
  end
end	