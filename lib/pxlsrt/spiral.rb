module Pxlsrt
	##
	# Spiral iteration.
	class Spiral
		def initialize(x, y)
			@x = x
			@y = y
			@direction = "up"
			@step = 1
			@at = 0
			@count = 0
			@cycles = -1
		end
		##
		# Return current x value.
		def x
			return @x
		end
		##
		# Return current y value.
		def y
			return @y
		end
		##
		# Return current direction.
		def direction
			return @direction
		end
		##
		# Return amount iterated.
		def count
			return @count
		end
		##
		# Return cycles gone through completely.
		def cycles
			return @cycles
		end
		##
		# Return current position.
		def pos
			return {:x => @x, :y => @y}
		end
		##
		# Goes to next position. Returns position.
		def next
			case @direction
			when "left"
				@x -= 1
				@at += 1
				if @at == @step
					@direction = "down"
					@at = 0
					@step += 1
				end
			when "down"
				@y += 1
				@at += 1
				if @at == @step
					@direction = "right"
					@at = 0
				end
			when "right"
				@x += 1
				@at += 1
				if @at == @step
					@direction = "up"
					@at = 0
					@step += 1
				end
			when "up"
				@cycles += 1 if @at == 0
				@y -= 1
				@at += 1
				if @at == @step
					@direction = "left"
					@at = 0
				end
			end
			@count += 1
			return pos
		end
	end
end