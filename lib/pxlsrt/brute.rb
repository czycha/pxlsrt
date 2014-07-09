require 'rubygems'
require 'oily_png'

module Pxlsrt
	##
	# Brute sorting creates bands for sorting using a range to determine the bandwidths,
	# as opposed to smart sorting which uses edge-finding to create bands.
	class Brute
		##
		# Uses Pxlsrt::Brute.brute to input and output from one method.
		def self.suite(inputFileName, outputFileName, o={})
			kml=Pxlsrt::Brute.brute(inputFileName, o)
			if Pxlsrt::Helpers.contented(kml)
				kml.save(outputFileName)
			end
		end
		##
		# The main attraction of the Brute class. Returns a ChunkyPNG::Image that is sorted according to the options provided. Will return nil if it encounters an errors.
		def self.brute(input, o={})
			startTime=Time.now
			defOptions={
				:reverse => "no",
				:vertical => false,
				:diagonal => false,
				:smooth => false,
				:method => "sum-rgb",
				:verbose => false,
				:min => Float::INFINITY,
				:max => Float::INFINITY,
				:trusted => false,
				:middle => false
			}
			defRules={
				:reverse => ["no", "reverse", "either"],
				:vertical => [false, true],
				:diagonal => [false, true],
				:smooth => [false, true],
				:method => ["sum-rgb", "red", "green", "blue", "sum-hsb", "hue", "saturation", "brightness", "uniqueness", "luma", "random", "cyan", "magenta", "yellow", "alpha", "sum-rgba", "sum-hsba"],
				:verbose => [false, true],
				:min => [Float::INFINITY, {:class => [Fixnum]}],
				:max => [Float::INFINITY, {:class => [Fixnum]}],
				:trusted => [false, true],
				:middle => [false, true]
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
							return
						end
					else
						Pxlsrt::Helpers.error("File #{input} doesn't exist!") if options[:verbose]
						return
					end
				elsif input.class!=String and input.class!=ChunkyPNG::Image
					Pxlsrt::Helpers.error("Input is not a filename or ChunkyPNG::Image") if options[:verbose]
					return
				end
				Pxlsrt::Helpers.verbose("Brute mode.") if options[:verbose]
				case options[:reverse].downcase
					when "reverse"
						nre=1
					when "either"
						nre=-1
					else
						nre=0
				end
				png=input
				w=png.dimension.width
				h=png.dimension.height
				sorted=ChunkyPNG::Image.new(w, h, ChunkyPNG::Color::TRANSPARENT)
				Pxlsrt::Helpers.verbose("Retrieving RGB values of pixels...") if options[:verbose]
				kml=[]
				for xy in 0..(w*h-1)
					kml.push(Pxlsrt::Colors.getRGBA(png[xy % w,(xy/w).floor]))
				end
				if options[:vertical]==true
					Pxlsrt::Helpers.verbose("Rotating image for vertical mode...") if options[:verbose]
					kml=Pxlsrt::Lines.rotateImage(kml, w, h, 3)
					w,h=h,w
				end
				toImage=[]
				if !options[:diagonal]
					Pxlsrt::Helpers.verbose("Pixel sorting using method '#{options[:method]}'...") if options[:verbose]
					for m in Pxlsrt::Lines.imageRGBLines(kml, w)
						sliceRanges=Pxlsrt::Lines.randomSlices(m, options[:min], options[:max])
						newInTown=[]
						if options[:smooth]!=true
							for ranger in sliceRanges
								newInTown.concat(Pxlsrt::Lines.middlate(Pxlsrt::Colors.pixelSort(m[ranger[0]..ranger[1]], options[:method].downcase, nre))) if options[:middle]
								newInTown.concat(Pxlsrt::Colors.pixelSort(m[ranger[0]..ranger[1]], options[:method].downcase, nre)) if !options[:middle]
							end
						else
							for ranger in sliceRanges
								k=(m[ranger[0]..ranger[1]]).group_by { |x| x }
								g=Pxlsrt::Colors.pixelSort(k.keys, options[:method].downcase, nre)
								g=Pxlsrt::Lines.middlate(g) if options[:middle]
								j=g.map { |x| k[x] }.flatten(1)
								newInTown.concat(j)
							end
						end
						toImage.concat(newInTown)
					end
				else
					Pxlsrt::Helpers.verbose("Determining diagonals...") if options[:verbose]
					dia=Pxlsrt::Lines.getDiagonals(kml,w,h)
					Pxlsrt::Helpers.verbose("Pixel sorting using method '#{options[:method]}'...") if options[:verbose]
					for m in dia.keys
						sliceRanges=Pxlsrt::Lines.randomSlices(dia[m], options[:min], options[:max])
						newInTown=[]
						if options[:smooth]!=true
							for ranger in sliceRanges
								newInTown.concat(Pxlsrt::Lines.middlate(Pxlsrt::Colors.pixelSort(dia[m][ranger[0]..ranger[1]], options[:method].downcase, nre))) if options[:middle]
								newInTown.concat(Pxlsrt::Colors.pixelSort(dia[m][ranger[0]..ranger[1]], options[:method].downcase, nre)) if !options[:middle]
							end
						else
							for ranger in sliceRanges
								k=(dia[m][ranger[0]..ranger[1]]).group_by { |x| x }
								g=Pxlsrt::Colors.pixelSort(k.keys, options[:method].downcase, nre)
								g=Pxlsrt::Lines.middlate(g) if options[:middle]
								j=g.map { |x| k[x] }.flatten(1)
								newInTown.concat(j)
							end
						end
						dia[m]=newInTown
					end
					Pxlsrt::Helpers.verbose("Setting diagonals back to standard lines...") if options[:verbose]
					toImage=Pxlsrt::Lines.fromDiagonals(dia,w)
				end
				if options[:vertical]==true
					Pxlsrt::Helpers.verbose("Rotating back (because of vertical mode).") if options[:verbose]
					toImage=Pxlsrt::Lines.rotateImage(toImage, w,h,1)
					w,h=h,w
				end
				Pxlsrt::Helpers.verbose("Giving pixels new RGB values...") if options[:verbose]
				for xy in 0..(w*h-1)
					sorted[xy % w, (xy/w).floor]=Pxlsrt::Colors.arrayToRGBA(toImage[xy])
				end
				endTime=Time.now
				timeElapsed=endTime-startTime
				if timeElapsed < 60
					Pxlsrt::Helpers.verbose("Took #{timeElapsed.round(4)} second#{ timeElapsed!=1.0 ? "s" : "" }.") if options[:verbose]
				else
					minutes=(timeElapsed/60).floor
					seconds=(timeElapsed % 60).round(4)
					Pxlsrt::Helpers.verbose("Took #{minutes} minute#{ minutes!=1 ? "s" : "" } and #{seconds} second#{ seconds!=1.0 ? "s" : "" }.") if options[:verbose]
				end
				Pxlsrt::Helpers.verbose("Returning ChunkyPNG::Image...") if options[:verbose]
				return sorted
			else
				Pxlsrt::Helpers.error("Options specified do not follow the correct format.") if options[:verbose]
				return
			end
		end
	end
end