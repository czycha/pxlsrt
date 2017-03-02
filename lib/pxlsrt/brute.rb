require 'oily_png'

module Pxlsrt
  ##
  # Brute sorting creates bands for sorting using a range to determine the bandwidths,
  # as opposed to smart sorting which uses edge-finding to create bands.
  class Brute
    ##
    # Uses Pxlsrt::Brute.brute to input and output from one method.
    def self.suite(inputFileName, outputFileName, o = {})
      kml = Pxlsrt::Brute.brute(inputFileName, o)
      kml.save(outputFileName) if Pxlsrt::Helpers.contented(kml)
    end

    ##
    # The main attraction of the Brute class. Returns a ChunkyPNG::Image that is sorted according to the options provided. Will raise any error that occurs.
    def self.brute(input, o = {})
      startTime = Time.now
      defOptions = {
        reverse: false,
        vertical: false,
        diagonal: false,
        smooth: false,
        method: 'sum-rgb',
        verbose: false,
        min: Float::INFINITY,
        max: Float::INFINITY,
        trusted: false,
        middle: false
      }
      defRules = {
        reverse: :anything,
        vertical: [false, true],
        diagonal: [false, true],
        smooth: [false, true],
        method: Pxlsrt::Colors::METHODS,
        verbose: [false, true],
        min: [Float::INFINITY, { class: [Integer] }],
        max: [Float::INFINITY, { class: [Integer] }],
        trusted: [false, true],
        middle: :anything
      }
      options = defOptions.merge(o)
      if o.empty? || (options[:trusted] == true) || ((options[:trusted] == false) && !o.empty? && (Pxlsrt::Helpers.checkOptions(options, defRules) != false))
        Pxlsrt::Helpers.verbose('Options are all good.') if options[:verbose]
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
        Pxlsrt::Helpers.verbose('Brute mode.') if options[:verbose]
        Pxlsrt::Helpers.verbose('Creating Pxlsrt::Image object') if options[:verbose]
        png = Pxlsrt::Image.new(input)
        if !options[:vertical] && !options[:diagonal]
          Pxlsrt::Helpers.verbose('Retrieving rows') if options[:verbose]
          lines = png.horizontalLines
        elsif options[:vertical] && !options[:diagonal]
          Pxlsrt::Helpers.verbose('Retrieving columns') if options[:verbose]
          lines = png.verticalLines
        elsif !options[:vertical] && options[:diagonal]
          Pxlsrt::Helpers.verbose('Retrieving diagonals') if options[:verbose]
          lines = png.diagonalLines
        elsif options[:vertical] && options[:diagonal]
          Pxlsrt::Helpers.verbose('Retrieving diagonals') if options[:verbose]
          lines = png.rDiagonalLines
        end
        iterator = if !options[:diagonal]
                     0...(lines.length)
                   else
                     lines.keys
                   end
        prr = 0
        len = iterator.to_a.length
        Pxlsrt::Helpers.progress('Dividing and pixel sorting lines', prr, len) if options[:verbose]
        iterator.each do |k|
          line = lines[k]
          divisions = Pxlsrt::Lines.randomSlices(line.length, options[:min], options[:max])
          newLine = []
          divisions.each do |division|
            band = line[division[0]..division[1]]
            newLine.concat(Pxlsrt::Helpers.handlePixelSort(band, options))
          end
          if !options[:diagonal]
            png.replaceHorizontal(k, newLine) unless options[:vertical]
            png.replaceVertical(k, newLine) if options[:vertical]
          else
            png.replaceDiagonal(k, newLine) unless options[:vertical]
            png.replaceRDiagonal(k, newLine) if options[:vertical]
          end
          prr += 1
          Pxlsrt::Helpers.progress('Dividing and pixel sorting lines', prr, len) if options[:verbose]
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
  end
end
