require 'java'
require_relative 'pxlsrt.jar'
import 'pxlsrt.Pxlsrt'
# import 'java.io.File'
import 'javax.imageio.ImageIO'

module PxlsrtJ
	class Colors
		METHODS = ["sum-rgb", "red", "green", "blue", "sum-hsb", "hue", "saturation", "brightness", "uniqueness", "luma", "random", "cyan", "magenta", "yellow", "none"]
	end
	class Helpers
		def self.isNumeric?(s)
			true if Float(s) rescue false
		end
		def self.checkOptions(options, rules)
			match=true
			for o in options.keys
				o_match=false
				if rules[o].class==Array
					if rules[o].include?(options[o])
						o_match=true
					else
						for r in 0...rules[o].length
							if rules[o][r].class==Hash
								for n in rules[o][r][:class]
									if n==options[o].class
										o_match=match
										break
									end
								end
							end
							if o_match==true
								break
							end
						end
					end
				elsif rules[o] == :anything
					o_match = true
				end
				match=(match and o_match)
				if match==false
					break
				end
			end
			return match
		end
		def self.prepareOptions(options, image, type)
			if type == :brute or type == :smart
				if PxlsrtJ::Helpers.isNumeric?(options[:middle])
					options[:middle] = options[:middle].to_i
				elsif options[:middle] == "" or options[:middle] == "middle"
					options[:middle] = 1
				else
					options[:middle] = 0
				end
				if not options[:vertical] and not options[:diagonal]
					options[:direction] = "horizontal"
				elsif not options[:vertical] and options[:diagonal]
					options[:direction] = "diagonal"
				elsif options[:vertical] and not options[:diagonal]
					options[:direction] = "vertical"
				elsif options[:vertical] and options[:diagonal]
					options[:direction] = "r-diagonal"
				end
			end
			case type
				when :brute
					if options[:min] == Float::INFINITY
						options[:min] = ((image.width ** 2 + image.height ** 2) ** 0.5).ceil.to_i
					else
						options[:min] = options[:min].to_i
					end
					if options[:max] == Float::INFINITY
						options[:max] = ((image.width ** 2 + image.height ** 2) ** 0.5).ceil.to_i
					else
						options[:max] = options[:max].to_i
					end
				when :smart
					options[:threshold] = options[:threshold].to_i
				when :kim
					unless options[:value] == false
						options[:value] = options[:value].to_i
					end
			end
		end
	end
	class Brute
		def self.suite(inputFileName, outputFileName, o = {})
			kml = PxlsrtJ::Brute.brute(inputFileName, o)
			if kml != nil
				f = Java::JavaIo::File.new outputFileName
				Java::JavaxImageio::ImageIO.write kml.modified, outputFileName.split('.').last, f
			end
		end
		def self.brute(input, o = {})
			defOptions = {
				:reverse => false,
				:vertical => false,
				:diagonal => false,
				:method => "sum-rgb",
				:min => Float::INFINITY,
				:max => Float::INFINITY,
				:trusted => false,
				:middle => false
			}
			defRules = {
				:reverse => [false, true],
				:vertical => [false, true],
				:diagonal => [false, true],
				:method => PxlsrtJ::Colors::METHODS,
				:min => [Float::INFINITY, {:class => [Fixnum]}],
				:max => [Float::INFINITY, {:class => [Fixnum]}],
				:trusted => [false, true],
				:middle => :anything
			}
			options = defOptions.merge(o)
			image = nil
			if o.length==0 or options[:trusted]==true or (options[:trusted]==false and o.length!=0 and PxlsrtJ::Helpers.checkOptions(options, defRules)!=false) and input.class == String
				image = Java::Pxlsrt::Pxlsrt.new input
				PxlsrtJ::Helpers.prepareOptions options, image, :brute
				image.brute(
					options[:min], 
					options[:max], 
					options[:direction], 
					options[:method], 
					options[:reverse], 
					options[:middle]
				)
			end
			return image
		end
	end
	class Smart
		def self.suite(inputFileName, outputFileName, o = {})
			kml = PxlsrtJ::Smart.smart(inputFileName, o)
			if kml != nil
				f = Java::JavaIo::File.new outputFileName
				Java::JavaxImageio::ImageIO.write kml.modified, outputFileName.split('.').last, f
			end
		end
		def self.smart(input, o = {})
			defOptions = {
				:reverse => false,
				:vertical => false,
				:diagonal => false,
				:method => "sum-rgb",
				:absolute => false,
				:threshold => 20,
				:trusted => false,
				:middle => false
			}
			defRules = {
				:reverse => [false, true],
				:vertical => [false, true],
				:diagonal => [false, true],
				:method => PxlsrtJ::Colors::METHODS,
				:absolute => [false, true],
				:threshold => [{:class => [Float, Fixnum]}],
				:trusted => [false, true],
				:middle => :anything
			}
			options = defOptions.merge(o)
			image = nil
			if o.length==0 or options[:trusted]==true or (options[:trusted]==false and o.length!=0 and PxlsrtJ::Helpers.checkOptions(options, defRules)!=false) and input.class == String
				image = Java::Pxlsrt::Pxlsrt.new input
				PxlsrtJ::Helpers.prepareOptions options, image, :smart
				image.smart(
					options[:threshold], 
					options[:absolute], 
					options[:direction], 
					options[:method], 
					options[:reverse], 
					options[:middle]
				)
			end
			return image
		end
	end
	class Kim
		def self.suite(inputFileName, outputFileName, o = {})
			kml = PxlsrtJ::Kim.kim(inputFileName, o)
			if kml != nil
				f = Java::JavaIo::File.new outputFileName
				Java::JavaxImageio::ImageIO.write kml.modified, outputFileName.split('.').last, f
			end
		end
		def self.kim(input, o = {})
			defOptions = {
				:method => "brightness",
				:value => false,
				:trusted => false
			}
			defRules = {
				:method => ["brightness", "black", "white"],
				:value => [false, {:class => [Fixnum]}],
				:trusted => [false, true]
			}
			options=defOptions.merge(o)
			image = nil
			if o.length==0 or options[:trusted]==true or (options[:trusted]==false and o.length!=0 and PxlsrtJ::Helpers.checkOptions(options, defRules)!=false) and input.class == String
				image = Java::Pxlsrt::Pxlsrt.new input
				PxlsrtJ::Helpers.prepareOptions options, image, :kim
				if options[:value] == false
					image.kim(options[:method])
				else
					image.kim(
						options[:method],
						options[:value]
					)
				end
			end
			return image
		end
	end
end