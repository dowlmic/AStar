require_relative "basic_astar"
require_relative "jump_astar"

class AStar
	attr_reader :path, :board_obj, :start_cell, :end_cell

	def initialize(board_obj, astar_helpers, type: :basic)
		@astar_helpers = astar_helpers
		@board_obj = board_obj
		board = @board_obj.board
		@start_cell = @board_obj.start
		@end_cell = @board_obj.end

		@open = [CellPair.new(child: @start_cell, parent: @start_cell, distance_from_start: 0)]
		@closed = astar_helpers.initialize_closed_hash(@board_obj)

		if type == :basic
			@path = BasicAStar.new(@board_obj, @open, @closed, @start_cell, @end_cell, @astar_helpers).path
		elsif type == :jump
			puts @closed
			@path = JumpAStar.new(@board_obj, @open, @closed, @start_cell, @end_cell, @astar_helpers).path
		end
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
			elsif @astar_helpers.contains_cell?(@closed, cell, board_obj)
				print "C"
			elsif @astar_helpers.is_in_cell_pair_list?(@open, cell)
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
end
