require_relative "board"
require_relative "astar_path"

class AStar
	attr_reader :path, :board, :start_cell, :end_cell

	def initialize(board_obj, type: "astar")
		@board_obj = board_obj
		@board = @board_obj.board
		@start_cell = @board_obj.start
		@end_cell = @board_obj.end
		@star_row, @start_col = @board_obj.find_cell(@start_cell)

		if type == "astar"
			astar(@board)
		elsif type == "jump"
			jump(@board)
		end
	end

	def astar(board)
		@paths = [AStarPath.new(path: [@start_cell], heuristic_score: @start_cell.distance)]
		while !@path
			@paths.concat(evaluate_next_paths(@paths.delete(@paths.first)))
			@paths = sort_paths(@paths)
			if contains_cell?(@paths, @end_cell)
				@path = get_path_with_cell(@paths, @end_cell)
			end
		end
	end

	def jump(board)

	end

	def to_s
		@board.each_index do |i|
			cell = @board[i]
			if cell == @start_cell
				print "S"
			elsif cell == @end_cell
				print "E"
			elsif @path && @path.path.include?(cell)
				print "."
			elsif contains_cell?(@paths, cell)
				print "O"
			elsif cell.blocked
				print "X"
			else
				print " "
			end

			if (i % (@board_obj.board_size[:width]) == @board_obj.board_size[:width] - 1)
				print "\n"
			end
		end
	end

	def duplicate_path(path)
		copied_path = []
		path.path.each do |cell|
			copied_path.insert(-1, cell)
		end
		score = path.heuristic_score

		AStarPath.new(path: copied_path, heuristic_score: score)
	end

	private

	def contains_cell?(paths, cell)
		if get_path_with_cell(paths, cell)
			true
		else
			false
		end
	end

	def get_path_with_cell(paths, cell)
		paths.each do |path|
			if path.path.include?(cell)
				return path
			end
		end
		nil
	end

	def sort_paths(paths)
		sorted_paths = paths.sort { |a, b| a <=> b }
	end

	def evaluate_next_paths(path)
		last_cell = path.path.last
		row, col = @board_obj.find_cell(last_cell)
		right_cell = @board_obj.get_cell(row, col+1)
		left_cell = @board_obj.get_cell(row, col-1)
		up_cell = @board_obj.get_cell(row+1, col)
		down_cell = @board_obj.get_cell(row-1, col)

		paths = []
		if right_cell && !right_cell.blocked
			tmp = duplicate_path(path)
			tmp.path.insert(-1, right_cell)
			tmp.heuristic_score = (tmp.path.length - 1) + right_cell.distance
			paths.insert(-1, tmp)
		end
		if left_cell && !left_cell.blocked
			tmp = duplicate_path(path)
			tmp.path.insert(-1, left_cell)
			tmp.heuristic_score = (tmp.path.length - 1) + left_cell.distance
			paths.insert(-1, tmp)
		end
		if up_cell && !up_cell.blocked
			tmp = duplicate_path(path)
			tmp.path.insert(-1, up_cell)
			tmp.heuristic_score = (tmp.path.length - 1) + up_cell.distance
			paths.insert(-1, tmp)
		end
		if down_cell && !down_cell.blocked
			tmp = duplicate_path(path)
			tmp.path.insert(-1, down_cell)
			tmp.heuristic_score = (tmp.path.length - 1) + down_cell.distance
			paths.insert(-1, tmp)
		end
		paths
	end
end
