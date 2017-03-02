module Pxlsrt
  ##
  # Image class for handling ChunkyPNG images.
  class Image
    def initialize(png)
      @original = png
      @modified = ChunkyPNG::Image.from_canvas(png)
      @width = png.width
      @height = png.height
    end

    ##
    # Retrieve a multidimensional array consisting of the horizontal lines (row) of the image.
    def horizontalLines
      (0...@height).inject([]) { |arr, row| arr << @modified.row(row) }
    end

    ##
    # Replace a horizontal line (row) of the image.
    def replaceHorizontal(y, arr)
      @modified.replace_row!(y, arr)
      @modified
    end

    ##
    # Retrieve the x and y coordinates of a pixel based on the multidimensional array created using the horizontalLines method.
    def horizontalXY(horizontal, index)
      {
        'x' => index.to_i,
        'y' => horizontal.to_i
      }
    end

    ##
    # Retrieve a multidimensional array consisting of the vertical lines of the image.
    def verticalLines
      (0...@width).inject([]) { |arr, column| arr << @modified.column(column) }
    end

    ##
    # Replace a vertical line (column) of the image.
    def replaceVertical(y, arr)
      @modified.replace_column!(y, arr)
      @modified
    end

    ##
    # Retrieve the x and y coordinates of a pixel based on the multidimensional array created using the verticalLines method.
    def verticalXY(vertical, index)
      {
        'x' => vertical.to_i,
        'y' => index.to_i
      }
    end

    ##
    # Retrieve a hash consisting of the diagonal lines (top left to bottom right) of the image.
    def diagonalLines
      Pxlsrt::Lines.getDiagonals(horizontalLines.flatten(1), @width, @height)
    end

    ##
    # Retrieve a hash consisting of the diagonal lines (bottom left to top right) of the image.
    def rDiagonalLines
      Pxlsrt::Lines.getDiagonals(horizontalLines.reverse.flatten(1).reverse, @width, @height)
    end

    ##
    # Get the column and row based on the diagonal hash created using diagonalLines.
    def diagonalColumnRow(d, i)
      {
        'column' => (d.to_i < 0 ? i : d.to_i + i).to_i,
        'row' => (d.to_i < 0 ? d.to_i.abs + i : i).to_i
      }
    end

    ##
    # Replace a diagonal line (top left to bottom right) of the image.
    def replaceDiagonal(d, arr)
      d = d.to_i
      (0...arr.length).each do |i|
        xy = diagonalXY(d, i)
        self[xy['x'], xy['y']] = arr[i]
      end
    end

    ##
    # Replace a diagonal line (bottom left to top right) of the image.
    def replaceRDiagonal(d, arr)
      d = d.to_i
      (0...arr.length).each do |i|
        xy = rDiagonalXY(d, i)
        self[xy['x'], xy['y']] = arr[i]
      end
    end

    ##
    # Retrieve the x and y coordinates of a pixel based on the hash created using the diagonalLines method and the column and row of the diagonalColumnRow method.
    def diagonalXY(d, i)
      cr = diagonalColumnRow(d, i)
      {
        'x' => cr['column'],
        'y' => cr['row']
      }
    end

    ##
    # Retrieve the x and y coordinates of a pixel based on the hash created using the rDiagonalLines method and the column and row of the diagonalColumnRow method.
    def rDiagonalXY(d, i)
      cr = diagonalColumnRow(d, i)
      {
        'x' => @width - 1 - cr['column'],
        'y' => cr['row']
      }
    end

    ##
    # Retrieve Sobel value for a given pixel.
    def getSobel(x, y)
      if !defined?(@sobels)
        @grey ||= @original.grayscale
        @sobel_x ||= [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
        @sobel_y ||= [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]
        return 0 if x.zero? || (x == (@width - 1)) || y.zero? || (y == (@height - 1))
        t1 = ChunkyPNG::Color.r(@grey[x - 1, y - 1])
        t2 = ChunkyPNG::Color.r(@grey[x, y - 1])
        t3 = ChunkyPNG::Color.r(@grey[x + 1, y - 1])
        t4 = ChunkyPNG::Color.r(@grey[x - 1, y])
        t5 = ChunkyPNG::Color.r(@grey[x, y])
        t6 = ChunkyPNG::Color.r(@grey[x + 1, y])
        t7 = ChunkyPNG::Color.r(@grey[x - 1, y + 1])
        t8 = ChunkyPNG::Color.r(@grey[x, y + 1])
        t9 = ChunkyPNG::Color.r(@grey[x + 1, y + 1])
        pixel_x = (@sobel_x[0][0] * t1) + (@sobel_x[0][1] * t2) + (@sobel_x[0][2] * t3) + (@sobel_x[1][0] * t4) + (@sobel_x[1][1] * t5) + (@sobel_x[1][2] * t6) + (@sobel_x[2][0] * t7) + (@sobel_x[2][1] * t8) + (@sobel_x[2][2] * t9)
        pixel_y = (@sobel_y[0][0] * t1) + (@sobel_y[0][1] * t2) + (@sobel_y[0][2] * t3) + (@sobel_y[1][0] * t4) + (@sobel_y[1][1] * t5) + (@sobel_y[1][2] * t6) + (@sobel_y[2][0] * t7) + (@sobel_y[2][1] * t8) + (@sobel_y[2][2] * t9)
        Math.sqrt(pixel_x * pixel_x + pixel_y * pixel_y).ceil
      else
        @sobels[y * @width + x]
      end
    end

    ##
    # Retrieve the Sobel values for every pixel and set it as @sobel.
    def getSobels
      unless defined?(@sobels)
        l = []
        (0...(@width * @height)).each do |xy|
          s = getSobel(xy % @width, (xy / @width).floor)
          l.push(s)
        end
        @sobels = l
      end
      @sobels
    end

    ##
    # Retrieve the Sobel value and color of a pixel.
    def getSobelAndColor(x, y)
      {
        'sobel' => getSobel(x, y),
        'color' => self[x, y]
      }
    end

    ##
    # Retrieve the color of a pixel.
    def [](x, y)
      @modified[x, y]
    end

    ##
    # Set the color of a pixel.
    def []=(x, y, color)
      @modified[x, y] = color
    end

    def i(i)
      x = i % @width
      y = (i / @width).floor
      self[x, y]
    end

    def i=(i, color)
      x = i % @width
      y = (i / @width).floor
      self[x, y] = color
    end

    ##
    # Return the original, unmodified image.
    def returnOriginal
      @original
    end

    ##
    # Return the modified image.
    def returnModified
      @modified
    end

    def getWidth
      @width
    end

    def getHeight
      @height
    end
  end
end
