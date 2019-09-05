# Libraries
require 'securerandom'
require 'json'
require 'ostruct'
require 'net/http'
require 'cgi'
require 'date'

require 'fat_zebra/version'
require 'fat_zebra/util'
require 'fat_zebra/config'
require 'fat_zebra/errors'
require 'fat_zebra/validation'
require 'fat_zebra/object_helper'
require 'fat_zebra/fat_zebra_object'
require 'fat_zebra/request'
require 'fat_zebra/api_helper'
require 'fat_zebra/api_resource'

# API Operations
require 'fat_zebra/api_operation/find'
require 'fat_zebra/api_operation/search'
require 'fat_zebra/api_operation/save'
require 'fat_zebra/api_operation/delete'
require 'fat_zebra/api_operation/void'

# API Resources
require 'fat_zebra/purchase'
require 'fat_zebra/information'
require 'fat_zebra/card'
require 'fat_zebra/authenticate'
require 'fat_zebra/refund'
require 'fat_zebra/payment_plan'
require 'fat_zebra/customer'
require 'fat_zebra/direct_debit'
require 'fat_zebra/direct_credit'
require 'fat_zebra/bank_account'
require 'fat_zebra/web_hook'
require 'fat_zebra/batch'

##
# Implementation of the FatZebra
module FatZebra
  class << self

    ##
    # @return [FatZebra::Config] configurations
    attr_reader :configurations

    ##
    # Configures the FatZebra API
    #
    # @example Default configuration
    #   FatZebra.configure do |config|
    #     config.username = 'my-username'
    #     config.token    = 'my-token'
    #   end
    def configure
      yield @configurations = FatZebra::Config.new

      FatZebra.configurations.valid!
    end

  end
end
