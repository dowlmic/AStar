require_relative "cell_pair"

class JumpAStar

	attr_accessor :path

	def initialize(board_obj, open, closed, start_cell, end_cell, astar_helpers)
		while !@path && !open.empty?
			open.concat(evaluate_next_paths(open.delete(open.first), end_cell, open, closed, board_obj, astar_helpers))
			open = sort_paths(open)
			puts "OPEN: #{open}"
			if astar_helpers.contains_cell?(closed, end_cell, board_obj)
				@path = get_path_with_cell(end_cell, start_cell, closed, board_obj)
			end
		end
	end

	def get_direction_to_parent(child_cell, parent_cell, board_obj)
		puts "CHILD: #{child_cell}, PARENT: #{parent_cell}"
		child_row, child_col = board_obj.find_cell(child_cell)
		parent_row, parent_col = board_obj.find_cell(parent_cell)
		puts "C: #{child_row}, #{child_col}"
		puts "P: #{parent_row}, #{parent_col}"

		direction = ""
		if child_col > parent_col
			direction = :left
		elsif child_col < parent_col
			direction = :right
		elsif child_row > parent_row
			direction = :down
		elsif child_row < parent_row
			direction = :up
		end

		direction
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
		puts "row: #{row}, col: #{col}"
		direction = get_direction_to_parent(last_cell, cell_pair.parent, board_obj)
		puts "DIRECTION: #{direction}"

		forced_neighbors = find_forced_neighbors(row, col, direction, closed, end_cell, board_obj, astar_helpers)

		new_open_pairs = []
		forced_neighbors.each do |cell|
			puts "CELL: #{cell}"
			cell_row, cell_col = board_obj.find_cell(cell)
			new_pair = CellPair.new(parent: cell_pair.child, child: cell, distance_from_start: (cell_pair.distance_from_start + (row - cell_row).abs + (col - cell_col).abs))
			pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
			puts "PAIR IN CLOSED: #{pair_in_closed}"
			puts "IS SHORTER PATH?: #{pair_in_closed && pair_in_closed.distance_from_start > new_pair.distance_from_start}"
			puts "IN OPEN LIST?: #{contains_cell_pair?(open, new_pair)}"
			if (!pair_in_closed || (pair_in_closed.distance_from_start > new_pair.distance_from_start)) && !contains_cell_pair?(open, new_pair)
				new_open_pairs.insert(0, new_pair)
				puts "NEW PAIR: #{new_pair.parent}, #{new_pair.child}"
			end
		end

		move_to_closed(row, col, cell_pair, closed, board_obj)

		new_open_pairs
	end

	def find_forced_neighbors(row, col, direction_to_parent, closed, end_cell, board_obj, astar_helpers)
		end_row, end_col = board_obj.find_cell(end_cell)
		forced_neighbors = []

		if direction_to_parent != :left || direction_to_parent.empty?
			i = col
			while i < board_obj.board_size[:width] - 1
				i += 1
				puts "RIGHT: #{row}, #{i}"
				cell = board_obj.get_cell(row, i)
				pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
				if !pair_in_closed
					if cell.blocked
						forced_neighbors.insert(0, board_obj.get_cell(row, i-1))
						break
					elsif has_blocked_diagonal_neighbors?(row, i, board_obj) || row == end_row || i == end_col
						forced_neighbors.insert(0, board_obj.get_cell(row, i))
					end
				end
			end
		end
		if direction_to_parent != :right || direction_to_parent.empty?
			i = col
			while i > 0
				i -= 1
				puts "LEFT: #{row}, #{i}"
				cell = board_obj.get_cell(row, i)
				pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
				if !pair_in_closed
					if cell.blocked
						forced_neighbors.insert(0, board_obj.get_cell(row, i+1))
						break
					elsif has_blocked_diagonal_neighbors?(row, i, board_obj) || row == end_row || i == end_col
						forced_neighbors.insert(0, board_obj.get_cell(row, i))
					end
				end
			end
		end
		if direction_to_parent != :up || direction_to_parent.empty?
			i = row
			while i < board_obj.board_size[:length] - 1
				i += 1
				puts "DOWN: #{i}, #{col}"
				cell = board_obj.get_cell(i, col)
				pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
				if !pair_in_closed
					if cell.blocked
						forced_neighbors.insert(0, board_obj.get_cell(i-1, col))
						break
					elsif has_blocked_diagonal_neighbors?(i, col, board_obj) || i == end_row || col == end_col
						forced_neighbors.insert(0, board_obj.get_cell(i, col))
					end
				end
			end
		end
		if direction_to_parent != :down || direction_to_parent.empty?
			i = row
			while i > 0
				i -= 1
				puts "UP: #{i}, #{col}"
				cell = board_obj.get_cell(i, col)
				pair_in_closed = astar_helpers.find_cell_pair_in_closed_hash(closed, cell, board_obj)
				if !pair_in_closed
					if cell.blocked
						forced_neighbors.insert(0, board_obj.get_cell(i+1, col))
						break
					elsif has_blocked_diagonal_neighbors?(i, col, board_obj) || i == end_row || col == end_col
						forced_neighbors.insert(0, board_obj.get_cell(i, col))
					end
				end
			end
		end

		forced_neighbors
	end

	def has_blocked_diagonal_neighbors?(row, col, board_obj)
		length = board_obj.board_size[:length]
		width = board_obj.board_size[:width]
		if (row > 1 && col < width - 1 && board_obj.get_cell(row+1, col+1).blocked) ||
			(row > 1 && col > 1 && board_obj.get_cell(row+1, col-1).blocked) ||
			(row < length && col < width - 1 && board_obj.get_cell(row-1, col+1).blocked) ||
			(row < length && col > 1 && board_obj.get_cell(row-1, col-1).blocked)
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
		puts "CLOSED: #{closed}"
	end
end
