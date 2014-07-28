require_relative "board"
require_relative "cell_pair"

class AStar
	attr_reader :path, :board_obj, :start_cell, :end_cell

	def initialize(board_obj, type: "astar")
		@board_obj = board_obj
		board = @board_obj.board
		@start_cell = @board_obj.start
		@end_cell = @board_obj.end

		if type == "astar"
			astar(@board_obj)
		elsif type == "jump"
			jump(board)
		end
	end

	def astar(board_obj)
		@open = [CellPair.new(child: @start_cell, parent: @start_cell, distance_from_start: 0)]
		@closed = {}
		(1...board_obj.board_size[:length]-1).each { |i| @closed[i] = {} }

		while !@path && !@open.empty?
			@open.concat(evaluate_next_paths(@open.delete(@open.first), @closed))
			@open = sort_paths(@open)
			if contains_cell?(@closed, @end_cell)
				@path = get_path_with_cell(@end_cell, @closed)
			end
		end
	end

	def jump(board_obj)

	end

	def to_s
		board = @board_obj.board
		board.each_index do |i|
			cell = board[i]
			if cell == @start_cell
				print "S"
			elsif cell == @end_cell
				print "E"
			elsif @path && @path.include?(cell)
				print "."
			elsif contains_cell?(@closed, cell)
				print "C"
			elsif is_in_cell_pair_list?(@open, cell)
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

	private

	def contains_cell?(closed, cell)
		row, col = @board_obj.find_cell(cell)
		if !(closed[row] && closed[row][col]).nil?
			closed[row][col]
		end
	end

	def is_in_cell_pair_list?(list, cell)
		list.each do |pair|
			if pair.child == cell
				return true
			end
		end
		false
	end

	def find_cell_pair(cell_pair, cell)
		row, col = @board_obj.find_cell(cell_pair.child)
		cell[row][col]
	end

	def get_path_with_cell(cell, closed)
		row, col = @board_obj.find_cell(cell)
		path = []
		while !path.include?(@start_cell)
			cell_pair = closed[row][col]
			path.insert(0, cell_pair.child)
			row, col = @board_obj.find_cell(cell_pair.parent)
		end
		path
	end

	def sort_paths(paths)
		sorted_paths = paths.sort { |a, b| a <=> b }
	end

	def evaluate_next_paths(cell_pair, closed)
		last_cell = cell_pair.child
		row, col = @board_obj.find_cell(last_cell)
		right_cell = @board_obj.get_cell(row, col+1)
		left_cell = @board_obj.get_cell(row, col-1)
		up_cell = @board_obj.get_cell(row+1, col)
		down_cell = @board_obj.get_cell(row-1, col)

		new_open_pairs = []
		new_open_pairs.insert(-1, evaluate_next_cell(right_cell, last_cell, cell_pair.distance_from_start, closed))
		new_open_pairs.insert(-1, evaluate_next_cell(left_cell, last_cell, cell_pair.distance_from_start, closed))
		new_open_pairs.insert(-1, evaluate_next_cell(up_cell, last_cell, cell_pair.distance_from_start, closed))
		new_open_pairs.insert(-1, evaluate_next_cell(down_cell, last_cell, cell_pair.distance_from_start, closed))

		move_to_closed(row, col, cell_pair, closed)

		new_open_pairs.compact
	end

	def evaluate_next_cell(cell, parent, distance_from_start, closed)
		if cell && !cell.blocked
			row, col = @board_obj.find_cell(cell)
			cell_pair_in_closed = closed[row][col]
			if !cell_pair_in_closed || (cell_pair_in_closed && cell_pair_in_closed.score > distance_from_start + 1)
				CellPair.new(child: cell, parent: parent, distance_from_start: distance_from_start + 1)
			end
		end
	end

	def move_to_closed(row, col, cell_pair, closed)
		cell_pair_in_closed = find_cell_pair(cell_pair, closed)
		if !cell_pair_in_closed || (cell_pair_in_closed && cell_pair_in_closed.score > cell_pair.score)
			closed[row][col] = cell_pair
		end
	end
end
