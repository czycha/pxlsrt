require 'rubygems'
require 'chunky_png'

def contented(c)
	return (((defined? c)!="nil") && ((/(\S)/.match("#{c}"))!=nil))
end

def arrayToRGB(a)
	return ChunkyPNG::Color.rgb(a[0], a[1], a[2])
end

def getRGB(pxl)
	return [ChunkyPNG::Color.r(pxl), ChunkyPNG::Color.g(pxl), ChunkyPNG::Color.b(pxl)]
end

def pxldex(pxl)
	return pxl[0]+pxl[1]+pxl[2]
end

def rgb2hsb(rgb)
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

def pixelSort(list, how, reverse)
	mhm=[]
	case how.downcase
		when "sum-rgb"
			mhm= list.sort_by { |c| pxldex(c) }
		when "red"
			mhm= list.sort_by { |c| c[0] }
		when "green"
			mhm= list.sort_by { |c| c[1] }
		when "blue"
			mhm= list.sort_by { |c| c[2] }
		when "hue"
			mhm= list.sort_by { |c| rgb2hsb(c)[0] }
		when "saturation"
			mhm= list.sort_by { |c| rgb2hsb(c)[1] }
		when "brightness"
			mhm= list.sort_by { |c| rgb2hsb(c)[2] }
		when "sum-hsb"
			mhm= list.sort_by { |c| k=rgb2hsb(c); k[0]*100/360+k[1]+k[2] }
		when "uniqueness"
			avg=colorAverage(list)
			mhm=list.sort_by { |c| colorUniqueness(c, [avg]) }
		else
			mhm= list.sort_by { |c| pxldex(c) }
	end
	if reverse == 0
		return mhm
	elsif reverse == 1
		return mhm.reverse
	else
		return rand(0..1)==0 ? mhm : mhm.reverse
	end
end

def imageRGBLines(image, width)
	return image.each_slice(width).to_a
end

def randomSlices(arr, minLength, maxLength)
	len=arr.length-1
	if minLength > arr.length
		minLength=len
	end
	if maxLength > arr.length
		maxLength=len
	end
	nu=[[0, rand(minLength..maxLength)]]
	last=nu.first[1]
	sorting=true
	while sorting do
		if (len-last) <= maxLength
			nu.push([last+1, len])
			sorting=false
		else
			nu.push([last+1, last+1+rand(minLength..maxLength)])
			last=nu.last[1]
		end
	end
	return nu
end

def colorDistance(c1,c2)
	return Math.sqrt((c1[0]-c2[0])**2+(c1[1]-c2[1])**2+(c1[2]-c2[2])**2)
end

def colorAverage(ca)
	if ca.length==1
		return ca.first
	end
	r=((ca.collect { |c| c[0] }).inject{ |sum, el| sum+el }).to_f / ca.size
	g=((ca.collect { |c| c[1] }).inject{ |sum, el| sum+el }).to_f / ca.size
	b=((ca.collect { |c| c[2] }).inject{ |sum, el| sum+el }).to_f / ca.size
	return [r,g,b]
end

def colorUniqueness(c, ca)
	return colorDistance(c, colorAverage(ca))
end

png=ChunkyPNG::Image.from_file(ARGV[0])

if contented(ARGV[6])
	case ARGV[6].downcase
		when "90", "1"
			png=png.rotate_left
	end
end
w=png.dimension.width
h=png.dimension.height

sorted=ChunkyPNG::Image.new(w, h, ChunkyPNG::Color::TRANSPARENT)

kml=[]

for xy in 0..(w*h-1)
	kml.push(getRGB(png[xy % w,(xy/w).floor]))
end

if contented(ARGV[5])
	case ARGV[5].downcase
		when "reverse"
			nre=1
		when "either"
			nre=-1
		else
			nre=0
	end
else
	nre=0
end

toImage=[]
for m in imageRGBLines(kml, w)
	sliceRanges=randomSlices(m, ARGV[1].to_i, ARGV[2].to_i)
	#puts sliceRanges.last.last
	newInTown=[]
	for ranger in sliceRanges
		newInTown.concat(pixelSort(m[ranger[0]..ranger[1]], contented(ARGV[4])!=false ? ARGV[4] : "sum-rgb", nre))
	end
	toImage.concat(newInTown)
end

for xy in 0..(w*h-1)
	sorted[xy % w, (xy/w).floor]=arrayToRGB(toImage[xy])
end

if contented(ARGV[6])
	case ARGV[6].downcase
		when "90", "1"
			sorted=sorted.rotate_right
	end
end

sorted.save(ARGV[3], :interlace => false)