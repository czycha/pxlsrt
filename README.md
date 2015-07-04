pxlsrt [![Gem Version](https://badge.fury.io/rb/pxlsrt.png)](http://badge.fury.io/rb/pxlsrt)
======

Pixel sorter written in JRuby. [On RubyGems.](https://rubygems.org/gems/pxlsrt) [pxlsrt-java library.](https://github.com/EVA-01/pxlsrt-java) *(Also available in [Ruby flavor](https://github.com/EVA-01/pxlsrt/tree/master)).*

## Installation

Requires the installation of [JRuby](http://www.jruby.org/).

```
jruby -S gem install pxlsrt
```

A suggested alias:

```bash
alias jpxlsrt="jruby -S pxlsrt"
```

### Dependencies ###

* [JRuby](http://www.jruby.org/)
* [Thor](https://github.com/erikhuda/thor) (`jruby -S gem install thor`)

## Brute sort ##

Brute sorting uses a user defined range for bandwidths to sort.

```
jpxlsrt brute INPUT OUTPUT [--min MIN] [--max MAX] [--vertical] [--reverse] [--method [sum-rgb | red | green | blue | sum-hsb | hue | saturation | brightness | uniqueness | luma | random | magenta | cyan | yellow | none]] [--diagonal] [--middle [integer]]
```

### Options and parameters ###

* **`INPUT`** *(required string)* - PNG image that is to be sorted.
* **`OUTPUT`** *(required string)* - PNG image that is to be output to. Image does not need to exist.
* **`--min MIN`** *(optional integer)* - Minimum length of bandwidth, 1 to infinity. If the length is greater than the dimension of the image, the minimum length is the dimension. Defaults to `Infinity`.
* **`--max MAX`** *(optiona; integer)* - Maximum length of bandwidth, 1 to infinity. If the length is greater than the dimension of the image, the maximum length is the dimension. Defaults to `Infinity`.
* **`--vertical`** or **`-v`** *(optional boolean)* - Sorts vertically instead of horizontally. Defaults to `false`.
* **`--reverse`** or **`-r`** *(optional boolean)* - Use just `--reverse` or `-r` to reverse the bands. Do not use if you don't want to reverse.
* **`--method METHOD`** or **`-m METHOD`** *(optional string)* - Sets the method used to sort the band. In a different section are descriptions of each method. Defaults to `sum-rgb`.
* **`--diagonal`** or **`-d`** *(optional boolean)* - Sorts pixels diagonally. To reverse the direction of the diagonal, use with `--vertical`. Defaults to `false`.
* **`--middle`** or **`-M`** *(optional boolean or integer)* - Has it sorted from the middle out, kind of like a sunrise gradient. Enter in a positive or negative integer n and it will "middlate" |n| times (if n is negative, it will work backwards). Leave blank to "middlate" once. Defaults to `false`.

### Examples ###

#### Bare minimum ####

```
jpxlsrt brute input.png output.png
```

Pixel sorts `input.png` horizontally by the sum of its red, green, and blue values with bandwidths across the size width of the image, does not reverse, and outputs to `output.png`.

#### Full suite example ####

```
jpxlsrt brute input.png output.png --min 20 --max 30 --vertical --reverse --method hue
```

Pixel sorts `input.png` vertically by hue with bandwidths from 20 to 30, reverses direction, and outputs to `output.png`.

#### Full suite shortcut example ####

```
jpxlsrt brute input.png output.png --min 20 --max 30 -v -r -m hue
```

Same as above example.

## Smart sort ##

Smart sorting uses edges detected within the image (determined through [Sobel operators](http://en.wikipedia.org/wiki/Sobel_operator)) along with a user-defined threshold to define bandwidths to sort.

```
jpxlsrt smart INPUT OUTPUT [--threshold THRESHOLD] [--absolute] [--vertical] [--reverse] [--method [sum-rgb | red | green | blue | sum-hsb | hue | saturation | brightness | uniqueness | luma | random | magenta | cyan | yellow | none]] [--diagonal] [--middle [integer]]
```

### Options and parameters ###

Options that are shared with the brute method are covered there.

* **`--threshold THRESHOLD`** or **`-t THRESHOLD`** *(optional integer)* - Used for edge finding. Defaults to `20`.
* **`--absolute`** or **`-a`** *(optional boolean)* - A different method for edge finding. Defaults to `false`.

## Kim sort ##

This uses [Kim Asendorf](http://kimasendorf.com/)'s [pixel sorting](http://kimasendorf.com/mountain-tour/) [algorithm](https://github.com/kimasendorf/ASDFPixelSort).

```
pxlsrt kim INPUT OUTPUT [--method METHOD] [--value VALUE]
```

* **`--method METHOD`** or **`-m METHOD`** *(optional string)* - The method to use for sorting. Kim Asendorf's algorithm only uses three methods: `black`, `brightness`, and `white`. Defaults to `brightness`.
* **`--value VALUE`** or **`-v VALUE`** *(optional integer)* - Used in the algorithm to find the next pixel to break at. Default depends on chosen method.

## Brute and Smart sorting methods ##

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

Creates a sum of the hue, saturation, and brightness values of the pixel and sorts by that.

```
sum-hsb(hue, saturation, brightness) = (hue * 100 / 360) + saturation + brightness
```

### hue ###

Sorts by the hue value of the pixels, creating something like a rainbow.

```
hue(hue, saturation, brightness) = hue
```

### saturation ###

Sorts by the saturation value of the pixels, creating an effect like the bands are fading to grey.

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
uniqueness(red, green, blue, reds, greens, blues) = sqrt((red - avg(reds))^2 + (green - avg(greens))^2 + (blue - avg(blues))^2)
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

### none ###

Doesn't do anything to the band. You may think this is useless but if you use it with reverse and/or middlation it can create some cool effects.

## To use within JRuby files

```ruby
require 'pxlsrt'
```

### PxlsrtJ::Smart, PxlsrtJ::Brute, PxlsrtJ::Kim

#### PxlsrtJ::Brute.brute, PxlsrtJ::Smart.smart, PxlsrtJ::Kim.kim

```ruby
PxlsrtJ::Brute.brute(input, options)

PxlsrtJ::Smart.smart(input, options)

PxlsrtJ::Kim.kim(input, options)
```

* **`input`** *(required string or BufferedImage)* - Either a BufferedImage or a string of a path leading to an image.
* **`options`** *(optional hash)* - A hash of options (the same as gone over above). Includes the option of `:trusted`, which bypasses the need to check if the options match the rules.

#### PxlsrtJ::Brute.suite, PxlsrtJ::Smart.suite, PxlsrtJ::Kim.suite

```ruby
PxlsrtJ::Brute.suite(inputFileName, outputFileName, options)

PxlsrtJ::Smart.suite(inputFileName, outputFileName, options)

PxlsrtJ::Kim.suite(inputFileName, outputFileName, options)
```

* **`inputFileName`** *(required string)* - Path to input image.
* **`outputFileName`** *(required string)* - Path to output image.
* **`options`** *(optional hash)* - A hash of options (the same as gone over above). Includes the option of `:trusted`, which bypasses the need to check if the options match the rules.