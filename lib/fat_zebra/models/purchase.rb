module FatZebra
	module Models
		class Purchase < Base
			attribute :id, :amount, :reference
		end
	end
end