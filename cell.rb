class Cell
	attr_accessor :blocked, :distance

	def initialize(blocked: false)
		@blocked = blocked
		@distance = Float::INFINITY
	end
end
