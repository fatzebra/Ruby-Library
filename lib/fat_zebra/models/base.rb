module FatZebra
	module Models
		class Base
			def initialize(attrs = {})
				attrs.each do |key, val|
					self.send("#{key}=", val)
				end
			end
		end
	end
end