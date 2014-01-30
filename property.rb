

module ConfigConvert

	class Property

		attr_accessor :name, :value, :type, :values

		def initialize(name, type)
			@name = name
			@value = value
			@type = type
		end

	end

end