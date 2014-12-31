require 'oily_png'

module Pxlsrt
	##
	# Plant seeds, have them spiral out and sort.
	class Seed
		##
		# Uses Pxlsrt::Seed.seed to input and output from one method.
		def self.suite(inputFileName, outputFileName, o={})
			kml = Pxlsrt::Seed.seed(inputFileName, o)
			if Pxlsrt::Helpers.contented(kml)
				kml.save(outputFileName)
			end
		end
		##
		# The main attraction of the Seed class. Returns a ChunkyPNG::Image that is sorted according to the options provided. Will raise any error that occurs.
		def self.seed(input, o = {})
			startTime = Time.now
			defOptions = {
				:reverse => false,
				:smooth => false,
				:method => "sum-rgb",
				:verbose => false,
				:trusted => false,
				:middle => false,
				:random => false,
				:distance => 100,
				:threshold => 0.1
			}
			defRules = {
				:reverse => :anything,
				:smooth => [false, true],
				:method => Pxlsrt::Colors::METHODS,
				:verbose => [false, true],
				:trusted => [false, true],
				:middle => :anything,
				:random => [false, {:class => [Fixnum]}],
				:distance => [false, {:class => [Fixnum]}],
				:threshold => [{:class => [Float, Fixnum]}]
			}
			options = defOptions.merge(o)
			if o.length == 0 or options[:trusted] == true or (options[:trusted] == false and o.length != 0 and Pxlsrt::Helpers.checkOptions(options, defRules) != false)
				if input.class == String
					Pxlsrt::Helpers.verbose("Getting image from file...") if options[:verbose]
					if File.file?(input)
						if Pxlsrt::Colors.isPNG?(input)
							input = ChunkyPNG::Image.from_file(input)
						else
							Pxlsrt::Helpers.error("File #{input} is not a valid PNG.") if options[:verbose]
							raise "Invalid PNG"
						end
					else
						Pxlsrt::Helpers.error("File #{input} doesn't exist!") if options[:verbose]
						raise "File doesn't exit"
					end
				elsif input.class != String and input.class != ChunkyPNG::Image
					Pxlsrt::Helpers.error("Input is not a filename or ChunkyPNG::Image") if options[:verbose]
					raise "Invalid input (must be filename or ChunkyPNG::Image)"
				end
				Pxlsrt::Helpers.verbose("Seed mode.") if options[:verbose]
				Pxlsrt::Helpers.verbose("Creating Pxlsrt::Image object") if options[:verbose]
				png = Pxlsrt::Image.new(input)
				traversed = [false] * (png.getWidth * png.getHeight)
				count = 0
				seeds = []
				if options[:random] != false
					Pxlsrt::Helpers.progress("Planting seeds", 0, options[:random]) if options[:verbose]
					for s in (0...options[:random])
						x = (0...png.getWidth).to_a.sample
						y = (0...png.getHeight).to_a.sample
						seeds.push({
							:spiral => Pxlsrt::Spiral.new(x, y),
							:pixels => [png[x, y]],
							:xy => [{:x => x, :y=>y}],
							:placed => true,
							:retired => false,
							:anchor => {
								:x => x,
								:y => y
							}
						})
						Pxlsrt::Helpers.progress("Planting seeds", s + 1, options[:random]) if options[:verbose]
					end
				else
					Pxlsrt::Helpers.progress("Planting seeds", 0, png.getWidth * png.getHeight) if options[:verbose]
					kernel = [[-1, -1, -1], [-1, 9, -1], [-1, -1, -1]]
					i = (png.getWidth + png.getHeight - 2) * 2
					for y in (1...(png.getHeight - 1))
						for x in (1...(png.getWidth - 1))
							sum = 0
							for ky in ((-1)..1)
								for kx in ((-1)..1)
									sum += kernel[ky + 1][kx + 1] * (ChunkyPNG::Color.r(png[x + kx, y + ky]))
								end
							end
							if sum < options[:threshold]
								seeds.push({
									:spiral => Pxlsrt::Spiral.new(x, y),
									:pixels => [png[x, y]],
									:xy => [{:x => x, :y=>y}],
									:placed => true,
									:retired => false,
									:anchor => {
										:x => x,
										:y => y
									}
								})
							end
							i += 1
							Pxlsrt::Helpers.progress("Planting seeds", i, png.getWidth * png.getHeight) if options[:verbose]
						end
					end
					if options[:distance] != false
						Pxlsrt::Helpers.progress("Removing seed clusters", 0, seeds.length) if options[:verbose]
						results = []
						i = 0
						for current in seeds
							add = true
						  	for other in results
						    	d = Math.sqrt((current[:anchor][:x] - other[:anchor][:x]) ** 2 + (current[:anchor][:y] - other[:anchor][:y]) ** 2)
						    	add = false if d > 0 and d < options[:distance]
						  	end
						  	if add
							  	results.push(current)
							end
							i += 1
							Pxlsrt::Helpers.progress("Removing seed clusters", i, seeds.length) if options[:verbose]
						end
						seeds = results
					end
				end
				for r in (0...seeds.length)
					traversed[seeds[r][:anchor][:x] + seeds[r][:anchor][:y] * png.getWidth] = r
					count += 1
				end
				Pxlsrt::Helpers.verbose("Planted #{seeds.length} seeds") if options[:verbose]
				step = 0
				Pxlsrt::Helpers.progress("Watch them grow!", count, traversed.length) if options[:verbose]
				while count < traversed.length and seeds.length != 0
					r = 0
					retired = []
					for seed in seeds
						if !seed[:retired]
							n = seed[:spiral].next
							if n[:x] >= 0 and n[:y] >= 0 and n[:x] < png.getWidth and n[:y] < png.getHeight and !traversed[n[:x] + n[:y] * png.getWidth]
								seed[:pixels].push(png[n[:x], n[:y]])
								traversed[n[:x] + n[:y] * png.getWidth] = r
								seed[:xy].push(n)
								seed[:placed] = true
								count += 1
							else
								if seed[:placed] == true
									seed[:placed] = {
										:count => 1,
										:direction => seed[:spiral].direction,
										:cycle => seed[:spiral].cycles
									}
									case seed[:placed][:direction]
									when "up", "down"
										seed[:placed][:value] = seed[:spiral].pos[:y]
										seed[:placed][:valueS] = :y
									when "left", "right"
										seed[:placed][:value] = seed[:spiral].pos[:x]
										seed[:placed][:valueS] = :x
									end
								else
									seed[:placed][:count] += 1
									if seed[:spiral].cycles != seed[:placed][:cycle] and seed[:placed][:direction] == seed[:spiral].direction and seed[:placed][:value] == seed[:spiral].pos[seed[:placed][:valueS]]
										seed[:retired] = true
									end
								end
							end
						end
						r += 1
					end
					step += 1
					Pxlsrt::Helpers.progress("Watch them grow!", count, traversed.length) if options[:verbose]
				end
				Pxlsrt::Helpers.progress("Sort seeds and place pixels", 0, seeds.length) if options[:verbose]
				r = 0
				for seed in seeds
					spiral = Pxlsrt::Spiral.new(seed[:anchor][:x], seed[:anchor][:y])
					band = Pxlsrt::Helpers.handlePixelSort(seed[:pixels], options)
					i = 0
					for k in seed[:xy]
						png[k[:x], k[:y]] = band[i]
						i += 1
					end
					r += 1
					Pxlsrt::Helpers.progress("Sort seeds and place pixels", r, seeds.length) if options[:verbose]
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
				return png.returnModified
			else
				Pxlsrt::Helpers.error("Options specified do not follow the correct format.") if options[:verbose]
				raise "Bad options"
			end
		end
	end
end