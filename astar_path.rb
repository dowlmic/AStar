class AStarPath
	attr_accessor :path, :heuristic_score

	def initialize(path: [], heuristic_score: 0)
		@path = path
		@heuristic_score = heuristic_score
	end

	def <=>(other)
		path_comparison = self.heuristic_score <=> other.heuristic_score
		if path_comparison == 0
			path_comparison = self.path.length <=> other.path.length
		end
		path_comparison
	end
end
