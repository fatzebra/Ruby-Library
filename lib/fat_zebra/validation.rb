module FatZebra
  module Validation

    def validates(name, options = {})
      validations[name] = options
    end

    def valid?(params, action = nil)
      @errors = []

      validations.each do |(field, options)|
        next unless options[:on] == action

        Util.hash_except(options, :on).each do |(validation_attribute, validation_options)|
          send("validate_#{validation_attribute}", field, validation_options, params)
        end
      end

      errors.empty?
    end

    def valid!(params, action = nil)
      raise RequestValidationError, "The following errors prevent the transaction from being submitted: #{errors.join(', ')}" unless valid?(params, action)
    end

    def errors
      @errors ||= []
    end

    private

    def validations
      @validations ||= {}
    end

    def validate_required(field, options, params)
      return if options.is_a?(Hash) && options[:unless] && options[:unless].any? { |f| params[f] }

      errors << "'#{field}' is required" if params[field].nil? || params[field] == ''
    end

    # rubocop:disable Metrics/CyclomaticComplexity
    def validate_type(field, options, params)
      regexp =
        case options
        when :positive_float
          /\A\d*\.\d+\z/
        when :positive_numeric
          /\A\d*\.?\d+\z/
        when :positive_integer
          /\A\d*\z/
        when :batch_filename
          /\ABATCH-(?<version>v\d)-(?<type>[A-Z]*)-((?<merchant_username>[A-Z0-9]*\-?[A-Z0-9]*)-)?(?<process_date>\d{8})-(?<reference>[a-zA-Z0-9\-_]*).csv\z/i
        when :file_type
          /\A\#\<File\:.*\z/
        when :boolean
          /\Atrue|false\z/
        else
          raise RequestValidationError, "Unknown type #{options} for #{field}"
        end

      errors << "'#{field}' is not a '#{options}'" unless params[field].to_s =~ regexp
    end
    # rubocop:enable Metrics/CyclomaticComplexity

  end
end
