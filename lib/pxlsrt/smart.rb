require 'rubygems'
require 'oily_png'

module Pxlsrt
	##
	# Smart sorting uses sorted-finding algorithms to create bands to sort,
	# as opposed to brute sorting which doesn't care for the content or 
	# sorteds, just a specified range to create bands.
	class Smart
		##
		# Uses Pxlsrt::Smart.smart to input and output from pne method.
		def self.suite(inputFileName, outputFileName, o={})
			kml=Pxlsrt::Smart.smart(inputFileName, o)
			if Pxlsrt::Helpers.contented(kml)
				kml.save(outputFileName)
			end
		end
		##
		# The main attraction of the Smart class. Returns a ChunkyPNG::Image that is sorted according to the options provided. Will return nil if it encounters an errors.
		def self.smart(input, o={})
			startTime=Time.now
			defOptions={
				:reverse => false,
				:vertical => false,
				:diagonal => false,
				:smooth => false,
				:method => "sum-rgb",
				:verbose => false,
				:absolute => false,
				:threshold => 20,
				:trusted => false,
				:middle => false
			}
			defRules={
				:reverse => :anything,
				:vertical => [false, true],
				:diagonal => [false, true],
				:smooth => [false, true],
				:method => ["sum-rgb", "red", "green", "blue", "sum-hsb", "hue", "saturation", "brightness", "uniqueness", "luma", "random", "cyan", "magenta", "yellow", "alpha", "sum-rgba", "sum-hsba"],
				:verbose => [false, true],
				:absolute => [false, true],
				:threshold => [{:class => [Float, Fixnum]}],
				:trusted => [false, true],
				:middle => :anything
			}
			options=defOptions.merge(o)
			if o.length==0 or options[:trusted]==true or (options[:trusted]==false and o.length!=0 and Pxlsrt::Helpers.checkOptions(options, defRules)!=false)
				Pxlsrt::Helpers.verbose("Options are all good.") if options[:verbose]
				if input.class==String
					Pxlsrt::Helpers.verbose("Getting image from file...") if options[:verbose]
					if File.file?(input)
						if Pxlsrt::Colors.isPNG?(input)
							input=ChunkyPNG::Image.from_file(input)
						else
							Pxlsrt::Helpers.error("File #{input} is not a valid PNG.") if options[:verbose]
							raise "Invalid PNG"
							return
						end
					else
						Pxlsrt::Helpers.error("File #{input} doesn't exist!") if options[:verbose]
						raise "File doesn't exist"
						return
					end
				elsif input.class!=String and input.class!=ChunkyPNG::Image
					Pxlsrt::Helpers.error("Input is not a filename or ChunkyPNG::Image") if options[:verbose]
					raise "Invalid input (must be filename or ChunkyPNG::Image)"
					return
				end
				Pxlsrt::Helpers.verbose("Smart mode.") if options[:verbose]
				png=Pxlsrt::Image.new(input)
				if !options[:vertical] and !options[:diagonal]
					Pxlsrt::Helpers.verbose("Retrieving rows") if options[:verbose]
					lines = png.horizontalLines
				elsif options[:vertical] and !options[:diagonal]
					Pxlsrt::Helpers.verbose("Retrieving columns") if options[:verbose]
					lines = png.verticalLines
				elsif !options[:vertical] and options[:diagonal]
					Pxlsrt::Helpers.verbose("Retrieving diagonals") if options[:verbose]
					lines = png.diagonalLines
				elsif options[:vertical] and options[:diagonal]
					Pxlsrt::Helpers.verbose("Retrieving diagonals") if options[:verbose]
					lines = png.rDiagonalLines
				end
				Pxlsrt::Helpers.verbose("Retrieving edges") if options[:verbose]
				png.getSobels
				if !options[:diagonal]
					iterator = 0...(lines.length)
				else
					iterator = lines.keys
				end
				prr = 0
				len = iterator.to_a.length
				Pxlsrt::Helpers.progress("Dividing and pixel sorting lines", prr, len) if options[:verbose]
				for k in iterator
					line = lines[k]
					divisions = []
					division = []
					if line.length > 1
						for pixel in 0...(line.length)
							if !options[:vertical] and !options[:diagonal]
								xy = png.horizontalXY(k, pixel)
							elsif options[:vertical] and !options[:diagonal]
								xy = png.verticalXY(k, pixel)
							elsif !options[:vertical] and options[:diagonal]
								xy = png.diagonalXY(k, pixel)
							elsif options[:vertical] and options[:diagonal]
								xy = png.rDiagonalXY(k, pixel)
							end
							pxlSobel = png.getSobelAndColor(xy["x"], xy["y"])
							if division.length == 0 or (options[:absolute] ? pxlSobel["sobel"] : pxlSobel["sobel"] - division.last["sobel"]) <= options[:threshold]
								division.push(pxlSobel)
							else
								divisions.push(division)
								division = [pxlSobel]
							end
							if pixel == line.length - 1
								divisions.push(division)
								division = []
							end
						end
					end
					newLine = []
					for band in divisions
						newLine.concat(
							Pxlsrt::Helpers.handlePixelSort(
								band.map { |sobelAndColor| sobelAndColor["color"] },
								options
							)
						)
					end
					if !options[:diagonal]
						png.replaceHorizontal(k, newLine) if !options[:vertical]
						png.replaceVertical(k, newLine) if options[:vertical]
					else
						png.replaceDiagonal(k, newLine) if !options[:vertical]
						png.replaceRDiagonal(k, newLine) if options[:vertical]
					end
					prr += 1
					Pxlsrt::Helpers.progress("Dividing and pixel sorting lines", prr, len) if options[:verbose]
				end
				endTime=Time.now
				timeElapsed=endTime-startTime
				if timeElapsed < 60
					Pxlsrt::Helpers.verbose("Took #{timeElapsed.round(4)} second#{ timeElapsed.round(4)!=1.0 ? "s" : "" }.") if options[:verbose]
				else
					minutes=(timeElapsed/60).floor
					seconds=(timeElapsed % 60).round(4)
					Pxlsrt::Helpers.verbose("Took #{minutes} minute#{ minutes!=1 ? "s" : "" } and #{seconds} second#{ seconds!=1.0 ? "s" : "" }.") if options[:verbose]
				end
				Pxlsrt::Helpers.verbose("Returning ChunkyPNG::Image...") if options[:verbose]
				return png.returnModified
			else
				Pxlsrt::Helpers.error("Options specified do not follow the correct format.") if options[:verbose]
				raise "Bad options"
				return
			end
		end
	end
end