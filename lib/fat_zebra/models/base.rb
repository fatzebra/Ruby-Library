module FatZebra
	module Models
		class Base
			def initialize(attrs = {})
				attrs.each do |key, val|
					self.send("#{key}=", val) if self.respond_to?("#{key}=")
				end
			end
		end
	end
end