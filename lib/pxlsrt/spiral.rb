module Pxlsrt
  ##
  # Spiral iteration.
  class Spiral
    def initialize(x, y)
      @x = x
      @y = y
      @direction = 'up'
      @step = 1
      @at = 0
      @count = 0
      @cycles = -1
    end

    ##
    # Return current x value.
    attr_reader :x

    ##
    # Return current y value.
    attr_reader :y

    ##
    # Return current direction.
    attr_reader :direction

    ##
    # Return amount iterated.
    attr_reader :count

    ##
    # Return cycles gone through completely.
    attr_reader :cycles

    ##
    # Return current position.
    def pos
      { x: @x, y: @y }
    end

    ##
    # Goes to next position. Returns position.
    def next
      case @direction
      when 'left'
        @x -= 1
        @at += 1
        if @at == @step
          @direction = 'down'
          @at = 0
          @step += 1
        end
      when 'down'
        @y += 1
        @at += 1
        if @at == @step
          @direction = 'right'
          @at = 0
        end
      when 'right'
        @x += 1
        @at += 1
        if @at == @step
          @direction = 'up'
          @at = 0
          @step += 1
        end
      when 'up'
        @cycles += 1 if @at.zero?
        @y -= 1
        @at += 1
        if @at == @step
          @direction = 'left'
          @at = 0
        end
      end
      @count += 1
      pos
    end
  end
end
