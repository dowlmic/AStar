require_relative "cell_pair"

class JumpAStar

	attr_accessor :path

	def initialize(board_obj, open, closed, start_cell, end_cell, astar_helpers)
		start_row, start_col = board_obj.find_cell(start_cell)
		end_row, end_col = board_obj.find_cell(end_cell)

		while !@path && !open.empty?
			open.concat(evaluate_next_paths(open.delete(open.first), end_cell, open, closed, board_obj, astar_helpers))
			open = sort_paths(open)
			if astar_helpers.contains_cell?(closed, end_cell, board_obj)
				@path = get_path_with_cell(end_cell, start_cell, closed, board_obj)
			end
		end
	end

	def get_directions_to_and_from_parent(child_cell, parent_cell, board_obj)
		child_row, child_col = board_obj.find_cell(child_cell)
		parent_row, parent_col = board_obj.find_cell(parent_cell)

		directions = []
		if child_col > parent_col || child_col < parent_col
			directions.insert(0, :right)
			directions.insert(0, :left)
		elsif child_row > parent_row || child_row < parent_row
			directions.insert(0, :up)
			directions.insert(0, :down)
		end

		directions
	end

	def find_cell_pair(cell_pair, closed_hash, board_obj)
		row, col = board_obj.find_cell(cell_pair.child)
		closed_hash[row][col]
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

	def evaluate_next_paths(cell_pair, end_cell, open, closed, board_obj, astar_helpers)
		last_cell = cell_pair.child
		row, col = board_obj.find_cell(last_cell)
		directions = get_directions_to_and_from_parent(last_cell, cell_pair.parent, board_obj)

		forced_neighbors = find_forced_neighbors(cell_pair, directions, open, closed, end_cell, board_obj, astar_helpers)

		move_to_closed(row, col, cell_pair, closed, board_obj)

		forced_neighbors
	end

	def find_forced_neighbors(cell_pair, directions_to_and_from_parent, open, closed, end_cell, board_obj, astar_helpers)
		end_row, end_col = board_obj.find_cell(end_cell)
		parent_distance_from_start = cell_pair.distance_from_start
		current_cell = cell_pair.child
		row, col = board_obj.find_cell(current_cell)
		forced_neighbors = []

		if !directions_to_and_from_parent.include?(:left)
			i = col
			while i < board_obj.board_size[:width] - 1
				i += 1
				cell = board_obj.get_cell(row, i)
				if cell.blocked
					cell = board_obj.get_cell(row, i-1)
					if cell != current_cell
						pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
						add_new_pair(forced_neighbors, cell_pair, cell, current_cell, i-1, col, pair_in_closed, open, board_obj)
					end
					break
				elsif has_blocked_diagonal_neighbors?(row, i, board_obj) || row == end_row || i == end_col
					pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
					add_new_pair(forced_neighbors, cell_pair, cell, current_cell, i, col, pair_in_closed, open, board_obj)
				end
			end
		end
		if !directions_to_and_from_parent.include?(:right)
			i = col
			while i > 0
				i -= 1
				cell = board_obj.get_cell(row, i)
				if cell.blocked
					cell = board_obj.get_cell(row, i+1)
					if cell != current_cell
						pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
						add_new_pair(forced_neighbors, cell_pair, cell, current_cell, i+1, col, pair_in_closed, open, board_obj)
					end
					break
				elsif has_blocked_diagonal_neighbors?(row, i, board_obj) || row == end_row || i == end_col
					pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
					add_new_pair(forced_neighbors, cell_pair, cell, current_cell, i, col, pair_in_closed, open, board_obj)
				end
			end
		end
		if !directions_to_and_from_parent.include?(:up)
			i = row
			while i < board_obj.board_size[:length] - 1
				i += 1
				cell = board_obj.get_cell(i, col)
				if cell.blocked
					cell = board_obj.get_cell(i-1, col)
					if cell != current_cell
						pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
						add_new_pair(forced_neighbors, cell_pair, cell, current_cell, i-1, row, pair_in_closed, open, board_obj)
					end
					break
				elsif has_blocked_diagonal_neighbors?(i, col, board_obj) || i == end_row || col == end_col
					pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
					add_new_pair(forced_neighbors, cell_pair, cell, current_cell, i, row, pair_in_closed, open, board_obj)
				end
			end
		end
		if !directions_to_and_from_parent.include?(:down)
			i = row
			while i > 0
				i -= 1
				cell = board_obj.get_cell(i, col)
				if cell.blocked
					cell = board_obj.get_cell(i+1, col)
					if cell != current_cell
						pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
						add_new_pair(forced_neighbors, cell_pair, cell, current_cell, i+1, row, pair_in_closed, open, board_obj)
					end
					break
				elsif has_blocked_diagonal_neighbors?(i, col, board_obj) || i == end_row || col == end_col
					pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
					add_new_pair(forced_neighbors, cell_pair, cell, current_cell, i, row, pair_in_closed, open, board_obj)
				end
			end
		end

		forced_neighbors
	end

	def add_new_pair(forced_neighbors, cell_pair, cell, parent_cell, cell_row_or_col, parent_cell_row_or_col, pair_in_closed, open, board_obj)
		new_distance = cell_pair.distance_from_start + (cell_row_or_col - parent_cell_row_or_col).abs
		new_pair = CellPair.new(child: cell, parent: parent_cell, distance_from_start: new_distance)
		if (!pair_in_closed || (pair_in_closed.score > new_pair.score)) && !contains_cell_pair?(open, new_pair)
			forced_neighbors.insert(0, new_pair)
		end
	end

	def has_blocked_diagonal_neighbors?(row, col, board_obj)
		length = board_obj.board_size[:length]
		width = board_obj.board_size[:width]

		right = board_obj.get_cell(row, col+1)
		up_right = board_obj.get_cell(row-1, col+1)
		up = board_obj.get_cell(row-1, col)
		up_left = board_obj.get_cell(row-1, col-1)
		left = board_obj.get_cell(row, col-1)
		down_left = board_obj.get_cell(row+1, col-1)
		down = board_obj.get_cell(row+1, col)
		down_right = board_obj.get_cell(row+1, col+1)
		
		if ((row > 1 && col < width - 2 && up_right.blocked && !(right.blocked || up.blocked)) ||
			(row > 1 && col > 1 && up_left.blocked && !(left.blocked || up.blocked)) ||
			(row < length - 2 && col < width - 2 && down_right.blocked && !(right.blocked || down.blocked)) ||
			(row < length - 2 && col > 1 && down_left.blocked && !(left.blocked || down.blocked)))	
			true
		else
			false
		end
	end

	def contains_cell_pair?(open_list, cell_pair)
		open_list.each do |pair|
			if pair.parent == cell_pair.parent && pair.child == cell_pair.child && pair.distance_from_start == cell_pair.distance_from_start
				return true
			end
		end
		false
	end

	def move_to_closed(row, col, cell_pair, closed, board_obj)
		cell_pair_in_closed = find_cell_pair(cell_pair, closed, board_obj)
		if !cell_pair_in_closed || (cell_pair_in_closed && cell_pair_in_closed.score > cell_pair.score)
			closed[row][col] = cell_pair
		end
	end
end
