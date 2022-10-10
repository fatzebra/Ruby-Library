module FatZebra
  ##
  # == FatZebra \Reports::Payouts
  #
  # Fetch Payout Reports
  #
  # * for_date
  #
  module Reports
    class Payouts < APIResource
      class << self
        def base_path
          super + 'reports/payouts/'
        end

        ##
        # Fetch a payout report for a given date
        #
        # @param [Date] Date object of the payout report
        # @param [Hash] options for the request, and configurations (Optional)
        #
        # @return [FatZebra::Reports::Payout]
        def for_date(date, options = {})
          raise Errors::MustUseDateObject unless date.is_a?(Date)
          response = request(:get, resource_path(date.strftime('%Y-%m-%d')), {}, options)
          initialize_from(response)
        end
      end
    end

    module Errors
      class MustUseDateObject < StandardError
        def message
          'must pass in a ruby date object'
        end
      end
    end
  end
end
