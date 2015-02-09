pxlsrt [![Gem Version](https://badge.fury.io/rb/pxlsrt.png)](http://badge.fury.io/rb/pxlsrt)
======

Pixel sorter written in Ruby. [On RubyGems.](https://rubygems.org/gems/pxlsrt)

## Installation

Requires the installation of [Ruby](https://www.ruby-lang.org/en/) (I use 2.0.0). All commands should be run through the Ruby command line.

```
gem install pxlsrt
```

### Dependencies ###

* [Ruby](https://www.ruby-lang.org/en/)
* [oily_png](https://github.com/wvanbergen/oily_png) (`gem install oily_png` if you don't use [bundler](http://bundler.io/))
* [Thor](https://github.com/erikhuda/thor) (`gem install thor` if you don't use [bundler](http://bundler.io/))

## Brute sort ##

Brute sorting uses a user defined range for bandwidths to sort.

```
pxlsrt brute INPUT OUTPUT [--min MIN] [--max MAX] [--vertical] [--smooth] [--reverse [either]] [--method [sum-rgb | red | green | blue | sum-hsb | hue | saturation | brightness | uniqueness | luma | random | magenta | cyan | yellow | alpha]] [--diagonal] [--verbose] [--middle [integer]]
```

### Options and parameters ###

* **`INPUT`** *(required string)* - PNG image that is to be sorted.
* **`OUTPUT`** *(required string)* - PNG image that is to be output to. Image does not need to exist.
* **`--min MIN`** *(optional integer)* - Minimum length of bandwidth, 1 to infinity. If the length is greater than the dimension of the image, the minimum length is the dimension. Defaults to `Infinity`.
* **`--max MAX`** *(optiona; integer)* - Maximum length of bandwidth, 1 to infinity. If the length is greater than the dimension of the image, the maximum length is the dimension. Defaults to `Infinity`.
* **`--vertical`** or **`-v`** *(optional boolean)* - Sorts vertically instead of horizontally. Defaults to `false`.
* **`--smooth`** or **`-s`** *(optional boolean)* - Places identical pixels adjacent to each other within the band. Here's why this may be needed. Within a band are the following colors: rgb(0, 255, 0), rgb(0, 0, 0), rgb(0, 255, 0). If you sort by the red value, they will all be in the same area because their red values are all 0. However, they will be arranged into the area as they are ordered in the list. If the band is smoothed, the two rgb(0, 255, 0) pixels will be next to each other. Smoothing does not affect values outside of the band. Defaults to `false`.
* **`--reverse`** or **`-r`** *(optional string)* - Use just `--reverse` or `-r` to reverse the bands. Use `--reverse either` to randomly reverse bands. Do not use if you don't want to reverse.
* **`--method METHOD`** or **`-m METHOD`** *(optional string)* - Sets the method used to sort the band. In a different section are descriptions of each method. Defaults to `sum-rgb`.
* **`--diagonal`** or **`-d`** *(optional boolean)* - Sorts pixels diagonally. To reverse the direction of the diagonal, use with `--vertical`. Defaults to `false`.
* **`--verbose`** or **`-V`** *(optional boolean)* - Prints to the terminal what the program is currently doing. Defaults to `false`.
* **`--middle`** or **`-M`** *(optional boolean or integer)* - Has it sorted from the middle out, kind of like a sunrise gradient. Enter in a positive or negative integer n and it will "middlate" |n| times (if n is negative, it will work backwards). Leave blank to "middlate" once. Defaults to `false`.

### Examples ###

#### Bare minimum ####

```
pxlsrt brute input.png output.png
```

Pixel sorts `input.png` horizontally by the sum of its red, green, and blue values with bandwidths across the size width of the image, does not smooth, does not reverse, and outputs to `output.png`.

#### Full suite example ####

```
pxlsrt brute input.png output.png --min 20 --max 30 --vertical --smooth --reverse --method hue
```

Pixel sorts `input.png` vertically by hue with bandwidths from 20 to 30, smoothes it, reverses direction, and outputs to `output.png`.

#### Full suite shortcut example ####

```
pxlsrt brute input.png output.png -v -s -r -m hue
```

Same as above example.

## Smart sort ##

Smart sorting uses edges detected within the image (determined through [Sobel operators](http://en.wikipedia.org/wiki/Sobel_operator)) along with a user-defined threshold to define bandwidths to sort.

```
pxlsrt smart INPUT OUTPUT [--threshold THRESHOLD] [--absolute] [--vertical] [--smooth] [--reverse [either]] [--method [sum-rgb | red | green | blue | sum-hsb | hue | saturation | brightness | uniqueness | luma | random | magenta | cyan | yellow | alpha | none]] [--diagonal] [--verbose] [--middle [integer]]
```

### Options and parameters ###

Options that are shared with the brute method are covered there.

* **`--threshold THRESHOLD`** or **`-t THRESHOLD`** *(optional integer)* - Used for edge finding. Defaults to `20`.
* **`--absolute`** or **`-a`** *(optional boolean)* - A different method for edge finding. Defaults to `false`.

## Kim sort ##

This uses [Kim Asendorf](http://kimasendorf.com/)'s [pixel sorting](http://kimasendorf.com/mountain-tour/) [algorithm](https://github.com/kimasendorf/ASDFPixelSort).

```
pxlsrt kim INPUT OUTPUT [--method METHOD] [--value VALUE] [--verbose]
```

* **`--method METHOD`** or **`-m METHOD`** *(optional string)* - The method to use for sorting. Kim Asendorf's algorithm only uses three methods: `black`, `brightness`, and `white`. Defaults to `brightness`.
* **`--value VALUE`** or **`-v VALUE`** *(optional integer)* - Used in the algorithm to find the next pixel to break at. Default depends on chosen method.
* **`--verbose`** or **`-V`**

## Seed sort ##

Inspired by [Jeff Thompson](https://github.com/jeffThompson)'s [seed sorter](https://github.com/jeffThompson/PixelSorting/tree/master/SeedSorting), but only employs portions of their algorithm.

```
pxlsrt seed INPUT OUTPUT [--threshold THRESHOLD] [--smooth] [--reverse [either]] [--method [sum-rgb | red | green | blue | sum-hsb | hue | saturation | brightness | uniqueness | luma | random | magenta | cyan | yellow | alpha]] [--verbose] [--middle [integer]] [--random SEEDCOUNT] [--distance DISTANCE]
```

* **`--random SEEDCOUNT`** or **`-R SEEDCOUNT`** *(optional)* - Opt to use random seed placement instead of placing seeds based on edge finding. The `SEEDCOUNT` should either be `false`, for the edge finding method, or an integer corresponding to how many seeds to place. Defaults to `false`, (edge finding method).
* **`--threshold THRESHOLD`** or **`-t THRESHOLD`** *(optional number)* - *Used only with edge finding method.* The threshold to determine edges to use as seeds. The smaller the number, the less seeds. Defaults to `0.1`.
* **`--distance DISTANCE`** or **`-d DISTANCE`** *(optional)* - *Used only with edge finding method.* The minimum number of pixels away that seeds have to be away from each other. Will weed out infringing seeds. Inputting `false` is equivalent to not removing any seeds that are close to each other. Defaults to `100`.
* The rest are the same as what is used in Brute and Smart.


## Brute, Smart, and Seed sorting methods ##

### sum-rgb ###

Sorts by the sum of the red, green, and blue values of the pixels.

```
sum-rgb(red, green, blue) = red + green + blue
```

### red ###

Sorts by the red value of the pixels.

```
red(red, green, blue) = red
```

### green ###

Sorts by the green value of the pixels.

```
green(red, green, blue) = green
```

### blue ###

Sorts by the blue value of the pixels.

```
blue(red, green, blue) = blue
```

### sum-hsb ###

Creates a sum of the hue, saturation, and brightness values of the pixel and sorts by that. The smoothing option is suggested for this method.

```
sum-hsb(hue, saturation, brightness) = (hue * 100 / 360) + saturation + brightness
```

### hue ###

Sorts by the hue value of the pixels, creating something like a rainbow. The smoothing option is suggested for this method.

```
hue(hue, saturation, brightness) = hue
```

### saturation ###

Sorts by the saturation value of the pixels, creating an effect like the bands are fading to grey. The smoothing option is suggested for this method.

```
saturation(hue, saturation, brightness) = saturation
```

### brightness ###

Sorts by the brightness value of the pixels. Produces a similar result to sum-rgb, but not exactly the same.

```
brightness(hue, saturation, brightness) = brightness
```

### uniqueness ###

Sorts by the "distance" of the pixel from the average color of band (excluding the pixel being determined).

```
avg(colors) = sum(colors) / (length of colors)
uniqueness(red, green, blue, alpha, reds, greens, blues, alphas) = sqrt((red - avg(reds))^2 + (green - avg(greens))^2 + (blue - avg(blues))^2 + (alpha - avg(alphas))^2)
```

### luma ###

Sorts by human color perception (similar to brightness and sum-rgb).

```
luma(red, green, blue) = red * 0.2126 + green * 0.7152 + blue * 0.0722
```

### random ###

Randomizes the pixels.

### magenta ###

Sorts by a magenta value.

```
magenta(red, green, blue) = red + blue
```

### cyan ###

Sorts by a cyan value.

```
cyan(red, green, blue) = green + blue
```

### yellow ###

Sorts by a yellow value.

```
yellow(red, green, blue) = red + green
```

### alpha ###

Sorts by the opacity (the opposite of transparency) of a pixel. The "A" in RGBA.

```
alpha(red, green, blue, alpha) = alpha
```

### sum-rgba ###

Sorts by the sum of the red, green, blue, and alpha values.

```
sum-rgba(red, green, blue, alpha) = red + green + blue + alpha
```

### sum-hsba ###

Sorts by the sum of the hue, saturation, brightness, and alpha values.

```
sum-hsba(hue, saturation, brightness, alpha) = (hue * 100 / 360) + saturation + brightness + alpha * 100 / 255
```

### none ###

Doesn't do anything to the band. You may think this is useless but if you use it with reverse and/or middlation it can create some cool effects.

## To use within Ruby files

```ruby
require 'pxlsrt'
```

### Pxlsrt::Smart, Pxlsrt::Brute, Pxlsrt::Kim, Pxlsrt::Seed

#### Pxlsrt::Brute.brute, Pxlsrt::Smart.smart, Pxlsrt::Kim.kim, or Pxlsrt::Seed.seed

```ruby
Pxlsrt::Brute.brute(input, options)

Pxlsrt::Smart.smart(input, options)

Pxlsrt::Kim.kim(input, options)

Pxlsrt::Seed.seed(input, options)
```

* **`input`** *(required string or ChunkyPNG::Image)* - Either a ChunkyPNG image or a string of a path leading to an image.
* **`options`** *(optional hash)* - A hash of options (the same as gone over above). Includes the option of `:trusted`, which bypasses the need to check if the options match the rules.

Example:

```ruby
img=ChunkyPNG::Image.from_file("path/to/image")
sorted_img=Pxlsrt::Brute.brute(img, :verbose=>true, :min=>20, :diagonal=>true)
sorted_img.save("path/to/output")

img=ChunkyPNG::Image.from_file("path/to/image")
sorted_img=Pxlsrt::Smart.smart(img, :verbose=>true, :diagonal=>true)
sorted_img.save("path/to/output")

img=ChunkyPNG::Image.from_file("path/to/image")
sorted_img=Pxlsrt::Kim.kim(img, :verbose=>true, :method=>"black")
sorted_img.save("path/to/output")

img=ChunkyPNG::Image.from_file("path/to/image")
sorted_img=Pxlsrt::Seed.seed(img, :verbose=>true, :middlate => 10)
sorted_img.save("path/to/output")
```

Alternatively:

```ruby
Pxlsrt::Brute.brute("path/to/image", :verbose=>true, :min=>20, :diagonal=>true).save("path/to/output")

Pxlsrt::Smart.smart("path/to/image", :verbose=>true, :diagonal=>true).save("path/to/output")

Pxlsrt::Kim.kim("path/to/image", :verbose=>true, :method=>"black").save("path/to/output")

Pxlsrt::Seed.seed(img, :verbose=>true, :middlate => 10).save("path/to/output")
```

#### Pxlsrt::Brute.suite, Pxlsrt::Smart.suite, Pxlsrt::Kim.suite, or Pxlsrt::Seed.suite

```ruby
Pxlsrt::Brute.suite(inputFileName, outputFileName, options)

Pxlsrt::Smart.suite(inputFileName, outputFileName, options)

Pxlsrt::Kim.suite(inputFileName, outputFileName, options)

Pxlsrt::Seed.suite(inputFileName, outputFileName, options)
```

* **`inputFileName`** *(required string)* - Path to input image.
* **`outputFileName`** *(required string)* - Path to output image.
* **`options`** *(optional hash)* - A hash of options (the same as gone over above). Includes the option of `:trusted`, which bypasses the need to check if the options match the rules.

Example:

```ruby
Pxlsrt::Brute.suite("path/to/image", "path/to/output", :verbose=>true, :min=>20, :diagonal=>true)

Pxlsrt::Smart.suite("path/to/image", "path/to/output", :verbose=>true, :diagonal=>true)

Pxlsrt::Kim.suite("path/to/image", "path/to/output", :verbose=>true, :method=>"black")

Pxlsrt::Seed.suite("path/to/image", "path/to/output", :verbose=>true, :middlate => 10)
```