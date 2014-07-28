class CellPair
	attr_accessor :child, :parent, :distance_from_start, :score

	def initialize(child: nil, parent: nil, distance_from_start: 0)
		@child = child
		@parent = parent
		@distance_from_start = distance_from_start
		@score = @distance_from_start + child.distance
	end

	def <=>(other)
		comparison = self.score <=> other.score
		if comparison == 0
			comparison = self.child.distance <=> other.child.distance
		end
		comparison
	end
end
