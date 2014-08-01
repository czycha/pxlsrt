require "oily_png"

module Pxlsrt
	##
	# Includes color operations.
	class Colors
		##
		# Converts a ChunkyPNG pixel into an array of the red, green, blue, and alpha values
		def self.getRGBA(pxl)
			return [ChunkyPNG::Color.r(pxl), ChunkyPNG::Color.g(pxl), ChunkyPNG::Color.b(pxl), ChunkyPNG::Color.a(pxl)]
		end
		##
		# Check if file is a PNG image. ChunkyPNG only works with PNG images. Eventually, I might use conversion tools to add support, but not right now.
		def self.isPNG?(path)
			return File.read(path).bytes==[137, 80, 78, 71, 10]
		end
		##
		# Converts an RGB-like array ([red, green, blue]) into an HSB-like array ([hue, saturation, brightness]).
		def self.rgb2hsb(rgb)
			r = rgb[0] / 255.0
			g = rgb[1] / 255.0
			b = rgb[2] / 255.0
			max = [r, g, b].max
			min = [r, g, b].min
			delta = max - min
			v = max * 100
			if (max != 0.0)
				s = delta / max *100
			else
				s = 0.0
			end
			if (s == 0.0) 
				h = 0.0
			else
				if (r == max)
					h = (g - b) / delta
				elsif (g == max)
					h = 2 + (b - r) / delta
				elsif (b == max)
					h = 4 + (r - g) / delta
				end
				h *= 60.0
				if (h < 0)
					h += 360.0
				end
			end
			return [h,s,v]
		end
		##
		# Averages an array of RGB-like arrays.
		def self.colorAverage(ca)
			if ca.length==1
				return ca.first
			end
			r=((ca.collect { |c| c[0] }).inject{ |sum, el| sum+el }).to_f / ca.size
			g=((ca.collect { |c| c[1] }).inject{ |sum, el| sum+el }).to_f / ca.size
			b=((ca.collect { |c| c[2] }).inject{ |sum, el| sum+el }).to_f / ca.size
			a=((ca.collect { |c| c[3] }).inject{ |sum, el| sum+el }).to_f / ca.size
			return [r,g,b,a]
		end
		##
		# Determines color distance from each other using the Pythagorean theorem.
		def self.colorDistance(c1,c2)
			return Math.sqrt((c1[0]-c2[0])**2+(c1[1]-c2[1])**2+(c1[2]-c2[2])**2+(c1[3]-c2[3])**2)
		end
		##
		# Uses a combination of color averaging and color distance to find how "unique" a color is.
		def self.colorUniqueness(c, ca)
			return Pxlsrt::Colors.colorDistance(c, Pxlsrt::Colors.colorAverage(ca))
		end
		##
		# Sorts an array of colors based on a method.
		# Available methods:
		# * sum-rgb (default)
		# * sum-rgba
		# * red
		# * yellow
		# * green
		# * cyan
		# * blue
		# * magenta
		# * hue
		# * saturation
		# * brightness
		# * sum-hsb
		# * sum-hsba
		# * uniqueness
		# * luma
		# * random
		# * alpha
		def self.pixelSort(list, how, reverse)
			mhm=[]
			case how.downcase
				when "sum-rgb"
					mhm= list.sort_by { |c| c[0]+c[1]+c[2] }
				when "sum-rgba"
					mhm=list.sort_by { |c| c[0]+c[1]+c[2]+c[3] }
				when "red"
					mhm= list.sort_by { |c| c[0] }
				when "yellow"
					mhm=list.sort_by { |c| c[0]+c[1] }
				when "green"
					mhm= list.sort_by { |c| c[1] }
				when "cyan"
					mhm=list.sort_by { |c| c[1]+c[2] }
				when "blue"
					mhm= list.sort_by { |c| c[2] }
				when "magenta"
					mhm=list.sort_by { |c| c[0]+c[2] }
				when "hue"
					mhm= list.sort_by { |c| Pxlsrt::Colors.rgb2hsb(c)[0] }
				when "saturation"
					mhm= list.sort_by { |c| Pxlsrt::Colors.rgb2hsb(c)[1] }
				when "brightness"
					mhm= list.sort_by { |c| Pxlsrt::Colors.rgb2hsb(c)[2] }
				when "sum-hsb"
					mhm= list.sort_by { |c| k=Pxlsrt::Colors.rgb2hsb(c); k[0]*100.0/360+k[1]+k[2] }
				when "sum-hsba"
					mhm= list.sort_by { |c| k=Pxlsrt::Colors.rgb2hsb(c); k[0]*100.0/360+k[1]+k[2]+c[3]*100.0/255 }
				when "uniqueness"
					avg=Pxlsrt::Colors.colorAverage(list)
					mhm=list.sort_by { |c| Pxlsrt::Colors.colorUniqueness(c, [avg]) }
				when "luma"
					mhm=list.sort_by { |c| c[0]*0.2126+c[1]*0.7152+c[2]*0.0722 }
				when "random"
					mhm=list.shuffle
				when "alpha"
					mhm=list.sort_by{ |c| c[3] }
				else
					mhm= list.sort_by { |c| c[0]+c[1]+c[2] }
			end
			if reverse == 0
				return mhm
			elsif reverse == 1
				return mhm.reverse
			else
				return rand(0..1)==0 ? mhm : mhm.reverse
			end
		end
		##
		# Turns an RGB-like array into ChunkyPNG's color
		def self.arrayToRGBA(a)
			return ChunkyPNG::Color.rgba(a[0], a[1], a[2], a[3])
		end
	end
end