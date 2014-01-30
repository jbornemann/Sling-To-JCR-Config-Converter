

module ConfigConvert

	class Property

		attr_reader :name, :value, :type

		def initialize(name, value, type)
			@name = name
			@value = value
			@type = type
		end

	end

end