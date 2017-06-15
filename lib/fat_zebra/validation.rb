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

    def validate_class_type(field, options, params)
      errors << "'#{field}' is not a '#{options}'" unless params[field].is_a?(options)
    end

  end
end
