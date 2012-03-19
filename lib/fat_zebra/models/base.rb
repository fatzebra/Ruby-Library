module FatZebra
  module Models
    class Base
      @@attributes = []
      def self.attribute(*values)
        @@attributes ||= []
        values.each do |val|
          @@attributes << val
        end
        attr_accessor *values
      end

      def initialize(attrs = {})
        attrs.each do |key, val|
          self.send("#{key}=", val) if self.respond_to?("#{key}=")
        end
      end

      def inspect
        inspection = @@attributes.collect { |name|
                        "#{name}: #{instance_variable_get("@#{name}")}"
                      }.compact.join(", ")
        "#<#{self.class} #{inspection}>"
      end

      def to_s
        inspect
      end
    end
  end
end