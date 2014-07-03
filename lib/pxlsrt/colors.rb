require "oily_png"

module Pxlsrt
	##
	# Includes color and image operations.
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
		# ChunkyPNG's rotation was a little slow and doubled runtime.
		# This "rotates" an array, based on the width and height.
		# It uses math and it's really cool, trust me.
		def self.rotateImage(what, width, height, a)
			nu=[]
			case a
				when 0, 360, 4
					nu=what
				when 1, 90
					for xy in 0..(what.length-1)
						nu[((height-1)-(xy/width).floor)+(xy % width)*height]=what[xy]
					end
				when 2, 180
					nu=what.reverse
				when 3, 270
					for xy in 0..(what.length-1)
						nu[(xy/width).floor+((width-1)-(xy % width))*height]=what[xy]
					end
			end
			return nu
		end
		##
		# Gets "rows" of an array based on a width
		def self.imageRGBLines(image, width)
			return image.each_slice(width).to_a
		end
		##
		# Outputs random slices of an array.
		# Because of the requirements of pxlsrt, it doesn't actually slice the array, bute returns a range-like array. Example:
		# [[0, 5], [6, 7], [8, 10]]
		def self.randomSlices(arr, minLength, maxLength)
			len=arr.length-1
			if len!=0
				min=[minLength, maxLength].min
				max=[maxLength, minLength].max
				if min > len
					min=len
				end
				if max > len
					max=len
				end
				nu=[[0, rand(min..max)]]
				last=nu.first[1]
				sorting=true
				while sorting do
					if (len-last) <= max
						nu.push([last+1, len])
						sorting=false
					else
						nu.push([last+1, last+1+rand(min..max)])
						last=nu.last[1]
					end
				end
			else
				nu=[[0,0]]
			end
			return nu
		end
		##
		# This is really lame. Adds first three values of an array together.
		def self.pxldex(pxl)
			return pxl[0]+pxl[1]+pxl[2]
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
					mhm= list.sort_by { |c| Pxlsrt::Colors.pxldex(c) }
				when "sum-rgba"
					mhm=list.sort_by { |c| Pxlsrt::Colors.pxldex(c)+c[3] }
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
					mhm=list.sort_by { |c| Pxlsrt::Colors.pxldex([c[0]*0.2126, c[1]*0.7152, c[2]*0.0722]) }
				when "random"
					mhm=list.shuffle
				when "alpha"
					mhm=list.sort_by{ |c| c[3] }
				else
					mhm= list.sort_by { |c| Pxlsrt::Colors.pxldex(c) }
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
		# Uses math to turn an array into an array of diagonals.
		def self.getDiagonals(array, width, height)
			dias={}
			for x in (1-height)..(width-1)
				z=[]
				for y in 0..(height-1)
					if (x+(width+1)*y).between?(width*y, (width*(y+1)-1))
						z.push(array[(x+(width+1)*y)])
					end
				end
				dias[x.to_s]=z
			end
			return dias
		end
		##
		# Uses math to turn an array of diagonals into a linear array.
		def self.fromDiagonals(obj, width)
			ell=[]
			for k in obj.keys
				r=k.to_i
				n=r < 0
				if n
					x=0
					y=r.abs
				else
					x=r
					y=0
				end
				ell[x+y*width]=obj[k].first
				for v in 1..(obj[k].length-1)
					x+=1
					y+=1
					ell[x+y*width]=obj[k][v]
				end
			end
			return ell
		end
		##
		# Turns an RGB-like array into ChunkyPNG's color
		def self.arrayToRGBA(a)
			return ChunkyPNG::Color.rgba(a[0], a[1], a[2], a[3])
		end
		##
		# Used in determining Sobel values.
		def self.sobelate(i, x,y)
			return ChunkyPNG::Color.to_grayscale_bytes(i[x,y]).first
		end
	end
end