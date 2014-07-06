module Pxlsrt
	##
	# "Line" operations used on arrays f colors.
	class Lines
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
	end
end