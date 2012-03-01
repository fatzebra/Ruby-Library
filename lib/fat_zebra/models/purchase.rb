module FatZebra
	module Models
		class Purchase < Base
			attr_accessor :id, :amount, :reference
		end
	end
end