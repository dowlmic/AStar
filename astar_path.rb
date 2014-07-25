class AStarPath
	attr_accessor :path, :score

	def initialize(path: [], score: 0)
		@path = path
		@score = score
	end

	def <=>(other)
		path_comparison = self.score <=> other.score
		if path_comparison == 0
			path_comparison = self.path.length <=> other.path.length
		end
		path_comparison
	end
end
