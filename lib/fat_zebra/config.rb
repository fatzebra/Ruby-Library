module FatZebra
  class Config

    # Returns the config values in a hash
    def config
      @config ||= {}
    end

    [:username, :token, :test_mode, :sandbox, :options, :gateway, :proxy].each do |attr|
      define_method "#{attr}" do |value = nil|
        if value.nil?
          config[attr.to_s]
        else
          config[attr.to_s] = value
        end
      end
    end

    # Validates the configuration
    def validate!
      @errors = []

      @errors << "Username is required" if self.username.nil?
      @errors << "Token is required" if self.token.nil?

      raise "The following errors were raised during configuration: #{@errors.join(", ")}}" unless @errors.empty?
    end

    def self.from_hash(hash)
      c = new
      hash.each do |key, value|
        c.send key, value
      end

      c
    end
  end
end