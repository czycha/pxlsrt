require 'oily_png'

module Pxlsrt
  ##
  # Uses Kim Asendorf's pixel sorting algorithm, orginally written in Processing. https://github.com/kimasendorf/ASDFPixelSort
  class Kim
    ##
    # Uses Pxlsrt::Kim.kim to input and output from one method.
    def self.suite(inputFileName, outputFileName, o = {})
      kml = Pxlsrt::Kim.kim(inputFileName, o)
      kml.save(outputFileName) if Pxlsrt::Helpers.contented(kml)
    end

    ##
    # The main attraction of the Kim class. Returns a ChunkyPNG::Image that is sorted according to the options provided. Will raise any error that occurs.
    def self.kim(input, o = {})
      startTime = Time.now
      defOptions = {
        method: 'brightness',
        verbose: false,
        value: false,
        trusted: false
      }
      defRules = {
        method: %w(brightness black white),
        verbose: [false, true],
        value: [false, { class: [Integer] }],
        trusted: [false, true]
      }
      options = defOptions.merge(o)
      if o.empty? || (options[:trusted] == true) || ((options[:trusted] == false) && !o.empty? && (Pxlsrt::Helpers.checkOptions(options, defRules) != false))
        if input.class == String
          Pxlsrt::Helpers.verbose('Getting image from file...') if options[:verbose]
          if File.file?(input)
            if Pxlsrt::Colors.isPNG?(input)
              input = ChunkyPNG::Image.from_file(input)
            else
              Pxlsrt::Helpers.error("File #{input} is not a valid PNG.") if options[:verbose]
              raise 'Invalid PNG'
            end
          else
            Pxlsrt::Helpers.error("File #{input} doesn't exist!") if options[:verbose]
            raise "File doesn't exit"
          end
        elsif (input.class != String) && (input.class != ChunkyPNG::Image)
          Pxlsrt::Helpers.error('Input is not a filename or ChunkyPNG::Image') if options[:verbose]
          raise 'Invalid input (must be filename or ChunkyPNG::Image)'
        end
        Pxlsrt::Helpers.verbose('Kim Asendorf mode.') if options[:verbose]
        Pxlsrt::Helpers.verbose('Creating Pxlsrt::Image object') if options[:verbose]
        png = Pxlsrt::Image.new(input)
        column = 0
        row = 0
        options[:value] ||= ChunkyPNG::Color.rgba(11, 220, 0, 1) if options[:method] == 'black'
        options[:value] ||= 60 if options[:method] == 'brightness'
        options[:value] ||= ChunkyPNG::Color.rgba(57, 167, 192, 1) if options[:method] == 'white'
        Pxlsrt::Helpers.progress('Sorting columns', column, png.getWidth) if options[:verbose]
        while column < png.getWidth
          x = column
          y = 0
          yend = 0
          while yend < png.getHeight
            case options[:method]
            when 'black'
              y = getFirstNotBlackY(png, x, y, options[:value])
              yend = getNextBlackY(png, x, y, options[:value])
            when 'brightness'
              y = getFirstBrightY(png, x, y, options[:value])
              yend = getNextDarkY(png, x, y, options[:value])
            when 'white'
              y = getFirstNotWhiteY(png, x, y, options[:value])
              yend = getNextWhiteY(png, x, y, options[:value])
            end
            break if y < 0
            sortLength = yend - y
            unsorted = []
            sorted = []
            (0...sortLength).each do |i|
              unsorted[i] = png[x, y + i]
            end
            sorted = unsorted.sort
            (0...sortLength).each do |i|
              png[x, y + i] = sorted[i]
            end
            y = yend + 1
          end
          column += 1
          Pxlsrt::Helpers.progress('Sorting columns', column, png.getWidth) if options[:verbose]
        end
        Pxlsrt::Helpers.progress('Sorting rows', row, png.getHeight) if options[:verbose]
        while row < png.getHeight
          x = 0
          y = row
          xend = 0
          while xend < png.getWidth
            case options[:method]
            when 'black'
              x = getFirstNotBlackX(png, x, y, options[:value])
              xend = getNextBlackX(png, x, y, options[:value])
            when 'brightness'
              x = getFirstBrightX(png, x, y, options[:value])
              xend = getNextDarkX(png, x, y, options[:value])
            when 'white'
              x = getFirstNotWhiteX(png, x, y, options[:value])
              xend = getNextWhiteX(png, x, y, options[:value])
            end
            break if x < 0
            sortLength = xend - x
            unsorted = []
            sorted = []
            (0...sortLength).each do |i|
              unsorted[i] = png[x + i, y]
            end
            sorted = unsorted.sort
            (0...sortLength).each do |i|
              png[x + i, y] = sorted[i]
            end
            x = xend + 1
          end
          row += 1
          Pxlsrt::Helpers.progress('Sorting rows', row, png.getHeight) if options[:verbose]
        end
        endTime = Time.now
        timeElapsed = endTime - startTime
        if timeElapsed < 60
          Pxlsrt::Helpers.verbose("Took #{timeElapsed.round(4)} second#{timeElapsed != 1.0 ? 's' : ''}.") if options[:verbose]
        else
          minutes = (timeElapsed / 60).floor
          seconds = (timeElapsed % 60).round(4)
          Pxlsrt::Helpers.verbose("Took #{minutes} minute#{minutes != 1 ? 's' : ''} and #{seconds} second#{seconds != 1.0 ? 's' : ''}.") if options[:verbose]
        end
        Pxlsrt::Helpers.verbose('Returning ChunkyPNG::Image...') if options[:verbose]
        return png.returnModified
      else
        Pxlsrt::Helpers.error('Options specified do not follow the correct format.') if options[:verbose]
        raise 'Bad options'
      end
    end

    # Helper methods
    # Black
    def self.getFirstNotBlackX(img, x, y, blackValue)
      if x < img.getWidth
        while img[x, y] < blackValue
          x += 1
          return -1 if x >= img.getWidth
        end
      end
      x
    end

    def self.getFirstNotBlackY(img, x, y, blackValue)
      if y < img.getHeight
        while img[x, y] < blackValue
          y += 1
          return -1 if y >= img.getHeight
        end
      end
      y
    end

    def self.getNextBlackX(img, x, y, blackValue)
      x += 1
      if x < img.getWidth
        while img[x, y] > blackValue
          x += 1
          return (img.getWidth - 1) if x >= img.getWidth
        end
      end
      x - 1
    end

    def self.getNextBlackY(img, x, y, blackValue)
      y += 1
      if y < img.getHeight
        while img[x, y] > blackValue
          y += 1
          return (img.getHeight - 1) if y >= img.getHeight
        end
      end
      y - 1
    end

    # Brightness
    def self.getFirstBrightX(img, x, y, brightnessValue)
      if x < img.getWidth
        while ChunkyPNG::Color.to_hsb(img[x, y])[2] * 255 < brightnessValue
          x += 1
          return -1 if x >= img.getWidth
        end
      end
      x
    end

    def self.getFirstBrightY(img, x, y, brightnessValue)
      if y < img.getHeight
        while ChunkyPNG::Color.to_hsb(img[x, y])[2] * 255 < brightnessValue
          y += 1
          return -1 if y >= img.getHeight
        end
      end
      y
    end

    def self.getNextDarkX(img, x, y, brightnessValue)
      x += 1
      if x < img.getWidth
        while ChunkyPNG::Color.to_hsb(img[x, y])[2] * 255 > brightnessValue
          x += 1
          return (img.getWidth - 1) if x >= img.getWidth
        end
      end
      x - 1
    end

    def self.getNextDarkY(img, x, y, brightnessValue)
      y += 1
      if y < img.getHeight
        while ChunkyPNG::Color.to_hsb(img[x, y])[2] * 255 > brightnessValue
          y += 1
          return (img.getHeight - 1) if y >= img.getHeight
        end
      end
      y - 1
    end

    # White
    def self.getFirstNotWhiteX(img, x, y, whiteValue)
      if x < img.getWidth
        while img[x, y] > whiteValue
          x += 1
          return -1 if x >= img.getWidth
        end
      end
      x
    end

    def self.getFirstNotWhiteY(img, x, y, whiteValue)
      if y < img.getHeight
        while img[x, y] > whiteValue
          y += 1
          return -1 if y >= img.getHeight
        end
      end
      y
    end

    def self.getNextWhiteX(img, x, y, whiteValue)
      x += 1
      if x < img.getWidth
        while img[x, y] < whiteValue
          x += 1
          return (img.getWidth - 1) if x >= img.getWidth
        end
      end
      x - 1
    end

    def self.getNextWhiteY(img, x, y, whiteValue)
      y += 1
      if y < img.getHeight
        while img[x, y] < whiteValue
          y += 1
          return (img.getHeight - 1) if y >= img.getHeight
        end
      end
      y - 1
    end
  end
end
