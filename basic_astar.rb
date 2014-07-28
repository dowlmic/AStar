require_relative "cell_pair"

class BasicAStar
	attr_accessor :path

	def initialize(board_obj, open, closed, start_cell, end_cell, astar_helpers)
		while !@path && !open.empty?
			open.concat(evaluate_next_paths(open.delete(open.first), closed, board_obj))
			open = sort_paths(open)
			if astar_helpers.contains_cell?(closed, end_cell, board_obj)
				@path = get_path_with_cell(end_cell, start_cell, closed, board_obj)
			end
		end
	end

	def find_cell_pair(cell_pair, cell, board_obj)
		row, col = board_obj.find_cell(cell_pair.child)
		cell[row][col]
	end

	def get_path_with_cell(to_cell, from_cell, closed_hash, board_obj)
		row, col = board_obj.find_cell(to_cell)
		path = []
		while !path.include?(from_cell)
			cell_pair = closed_hash[row][col]
			path.insert(0, cell_pair.child)
			row, col = board_obj.find_cell(cell_pair.parent)
		end
		path
	end

	def sort_paths(paths)
		sorted_paths = paths.sort { |a, b| a <=> b }
	end

	def evaluate_next_paths(cell_pair, closed, board_obj)
		last_cell = cell_pair.child
		row, col = board_obj.find_cell(last_cell)
		right_cell = board_obj.get_cell(row, col+1)
		left_cell = board_obj.get_cell(row, col-1)
		up_cell = board_obj.get_cell(row+1, col)
		down_cell = board_obj.get_cell(row-1, col)

		new_open_pairs = []
		new_open_pairs.insert(-1, evaluate_next_cell(right_cell, last_cell, cell_pair.distance_from_start, closed, board_obj))
		new_open_pairs.insert(-1, evaluate_next_cell(left_cell, last_cell, cell_pair.distance_from_start, closed, board_obj))
		new_open_pairs.insert(-1, evaluate_next_cell(up_cell, last_cell, cell_pair.distance_from_start, closed, board_obj))
		new_open_pairs.insert(-1, evaluate_next_cell(down_cell, last_cell, cell_pair.distance_from_start, closed, board_obj))

		move_to_closed(row, col, cell_pair, closed, board_obj)

		new_open_pairs.compact
	end

	def evaluate_next_cell(cell, parent, distance_from_start, closed, board_obj)
		if cell && !cell.blocked
			row, col = board_obj.find_cell(cell)
			cell_pair_in_closed = closed[row][col]
			if !cell_pair_in_closed || (cell_pair_in_closed && cell_pair_in_closed.score > distance_from_start + 1)
				CellPair.new(child: cell, parent: parent, distance_from_start: distance_from_start + 1)
			end
		end
	end

	def move_to_closed(row, col, cell_pair, closed, board_obj)
		cell_pair_in_closed = find_cell_pair(cell_pair, closed, board_obj)
		if !cell_pair_in_closed || (cell_pair_in_closed && cell_pair_in_closed.score > cell_pair.score)
			closed[row][col] = cell_pair
		end
	end
end
