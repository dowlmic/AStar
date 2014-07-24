require_relative "cell"

class Board
	attr_reader :board, :board_size, :start, :end

	def initialize(length: 0, width: 0, with_random_barriers: true, percent_barriers: 30)
		@board_size = { length: length+2, width: width+2,
			num_cells: (length+2) * (width+2) }
		initialize_board

		@random_num_generator = Random.new
		if with_random_barriers
			randomize_barriers(percent_barriers)
		end
		
		@start = get_random_cell
		@end = get_random_cell
	end

	def to_s
		@board.each_index do |i|
			if @board[i] == @start
				print "S"
			elsif @board[i] == @end
				print "E"
			elsif !@board[i].blocked
				print " "
			else
				print "X"
			end

			if (i % (@board_size[:width]) == @board_size[:width] - 1)
				print "\n"
			end
		end
	end

	def get_cell(row, col)
		if row >= @board_size[:length] || row < 0 ||
			col >= @board_size[:width] || col < 0
			nil
		else
			@board[row*@board_size[:width] + col]
		end
	end

	def get_random_row
		@random_num_generator.rand(1...@board_size[:length] - 1)
	end

	def get_random_col
		@random_num_generator.rand(1...@board_size[:width] - 1)
	end

	def get_random_cell
		cell = nil
		while !cell || cell.blocked || cell == @start || cell == @end
			start_row = get_random_row
			start_col = get_random_col
			cell = get_cell(start_row, start_col)
		end
		cell
	end

	private
	def initialize_board
		length = @board_size[:length]
		width = @board_size[:width]
		@board = Array.new(length*width);
		@board.each_index do |i|
			if (i % width == 0 || i % width == (width - 1) || (0..width).include?(i) ||
			    ((@board.length - width - 1)...@board.length).include?(i))
				@board[i] = Cell.new(blocked: true)
			else
				@board[i] = Cell.new(blocked: false)
			end
		end
	end


	def block_cell(row, col)
		if row != 0 && row != (@board_size[:length] - 1) &&
		  col != 0 && col != (@board_size[:width] - 1) &&
		  blocking_cell_valid?(row, col)
			get_cell(row, col).blocked = true
		end
	end

	def blocking_cell_valid?(row, col)
		blocked_neighbors = 0
		if get_cell(row+1, col).blocked
			blocked_neighbors += 1
		end
		if get_cell(row, col+1).blocked
			blocked_neighbors += 1
		end
		if get_cell(row+1, col+1).blocked
			blocked_neighbors += 1
		end
		if get_cell(row-1, col).blocked
			blocked_neighbors += 1
		end
		if get_cell(row, col-1).blocked
			blocked_neighbors += 1
		end
		if get_cell(row-1, col-1).blocked
			blocked_neighbors += 1
		end

		if blocked_neighbors > 1
			false
		else
			true
		end
	end

	def randomize_barriers(percent_barriers)
		num_cells = (@board_size[:width] - 2) * (@board_size[:length] - 2)
		num_cells_to_block = (num_cells * percent_barriers / 100).ceil

		length = @board_size[:length] - 2
		width = @board_size[:width] - 2

		max_cells_to_block = 0
		if length < width
			max_cells_to_block = length - 1
		else
			max_cells_to_block = width - 1
		end

		num_blocked_cells = 0
		while num_blocked_cells < num_cells_to_block
			if (num_cells_to_block - num_blocked_cells < max_cells_to_block)
				max_cells_to_block = num_cells_to_block - num_blocked_cells
			end
			if (max_cells_to_block < 2)
				num_cells = max_cells_to_block
			else
				num_cells = @random_num_generator.rand(1..max_cells_to_block)
			end

			which_blockage = @random_num_generator.rand(2)
			row = 0
			col = 0
			while get_cell(row, col).blocked
				row = get_random_row
				col = get_random_col
			end

			if which_blockage == 0
				blocked_cells = horizontal_bar_block(num_cells, row, col)
			else
				blocked_cells = vertical_bar_block(num_cells, row, col)
			end

			num_blocked_cells += blocked_cells
		end
	end

	def horizontal_bar_block(num_cells, row, col)
		num_blocked_cells = 0
		can_continue_in_direction = true
		count = 0
		while num_blocked_cells < num_cells
			if can_continue_in_direction
				if get_cell(row, col+count).blocked || !block_cell(row, col+count)
					count = 1
					can_continue_in_direction = false
				else
					count += 1
					num_blocked_cells += 1
				end
			else
				if get_cell(row, col-count).blocked || !block_cell(row, col-count)
					break
				else
					count += 1
					num_blocked_cells += 1
				end
			end
		end
		num_blocked_cells
	end

	def vertical_bar_block(num_cells, row, col)
		num_blocked_cells = 0
		can_continue_in_direction = true
		count = 0
		while num_blocked_cells < num_cells
			if can_continue_in_direction
				if get_cell(row+count, col).blocked || !block_cell(row+count, col)
					count = 1
					can_continue_in_direction = false
				else
					count += 1
					num_blocked_cells += 1
				end
			else
				if get_cell(row-count, col).blocked || !block_cell(row-count, col)
					break
				else
					count += 1
					num_blocked_cells += 1
				end
			end
		end
		num_blocked_cells
	end
end	
