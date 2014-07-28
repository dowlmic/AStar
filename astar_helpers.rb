class AStarHelpers

	def initialize_closed_hash(board_obj)
		hash = {}
		(1...board_obj.board_size[:length]-1).each { |i| hash[i] = {} }
		hash
	end	

	def is_in_cell_pair_list?(list, cell)
		list.each do |pair|
			if pair.child == cell
				return true
			end
		end
		false
	end

	def contains_cell?(closed, cell, board_obj)
		row, col = board_obj.find_cell(cell)
		if !(closed[row] && closed[row][col]).nil?
			closed[row][col]
		end
	end
end
