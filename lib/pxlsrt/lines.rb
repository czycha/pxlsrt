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
		# Some fancy rearranging.
		# [a, b, c, d, e] -> [d, b, a, c, e]
		# [a, b, c, d] -> [c, a, b, d]
		def self.middlate(arr)
			a=[]
			for e in 0...arr.length
				if (arr.length+e) % 2 == 1
					a[0.5*(arr.length+e-1)]=arr[e]
				elsif (arr.length+e) % 2 == 0
					a[0.5*(arr.length-e)-1]=arr[e]
				end
			end
			return a
		end
		##
		# Some fancy unrearranging.
		# [d, b, a, c, e] -> [a, b, c, d, e]
		# [c, a, b, d] -> [a, b, c, d]
		def self.reverseMiddlate(arr)
			a=[]
			for e in 0...arr.length
				if e == ((arr.length/2.0).ceil - 1)
					a[0] = arr[e]
				elsif e < ((arr.length/2.0).ceil - 1)
					a[arr.length - 2*e - 2] = arr[e]
				elsif e > ((arr.length/2.0).ceil - 1)
					a[2*e - arr.length + 1] = arr[e]
				end
			end
			return a
		end
		##
		# Handle middlate requests
		def self.handleMiddlate(arr, d)
			n = Pxlsrt::Helpers.isNumeric?(d)
			if n and d.to_i > 0
				k = arr
				for l in 0...(d.to_i)
					k = Pxlsrt::Lines.middlate(k)
				end
				return k
			elsif n and d.to_i < 0
				k = arr
				for l in 0...(d.to_i.abs)
					k = Pxlsrt::Lines.reverseMiddlate(k)
				end
				return k
			elsif d == "" or d == "middle"
				return Pxlsrt::Lines.middlate(arr)
			else
				return arr
			end
		end
		##
		# Gets "rows" of an array based on a width
		def self.imageRGBLines(image, width)
			return image.each_slice(width).to_a
		end
		##
		# Outputs random slices of an array.
		# Because of the requirements of pxlsrt, it doesn't actually slice the array, but returns a range-like array. Example:
		# [[0, 5], [6, 7], [8, 10]]
		def self.randomSlices(mainLength, minLength, maxLength)
			if mainLength <= 1
				return [[0, 0]]
			else
				min = [minLength, maxLength].min
				max = [minLength, maxLength].max
				min = mainLength if min > mainLength
				max = mainLength if max > mainLength
				min = 1 if min < 1
				max = 1 if max < 1
				nu = [[0, rand(min..max) - 1]]
				last = nu.last.last
				sorting = true
				i = 0
				while sorting do
					if (mainLength - last) <= max
						if last + 1 <= mainLength - 1
							nu.push([last + 1, mainLength - 1])
						end
						sorting = false
					else
						nu.push([last+1, last + rand(min..max)])
					end
					last = nu.last.last
				end
				return nu
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
	end
end