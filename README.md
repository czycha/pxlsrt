pxlsrt
======

Pixel sorter written in Ruby.

## Installation

Requires the installation of [Ruby](https://www.ruby-lang.org/en/) (I use 2.0.0). All commands should be run through the Ruby command line.

```
git clone https://github.com/EVA-01/pxlsrt.git
cd pxlsrt
bundle install
```

### Dependencies ###

* [Ruby](https://www.ruby-lang.org/en/)
* [oily_png](https://github.com/wvanbergen/oily_png) (`gem install oily_png` if you don't use [bundler](http://bundler.io/))
* [Thor](https://github.com/erikhuda/thor) (`gem install thor` if you don't use [bundler](http://bundler.io/))

## Brute sort ##

Brute sorting uses a user defined range for bandwidths to sort.

```
ruby pxlsrt.rb brute INPUT OUTPUT --min MIN --max MAX [--vertical] [--smooth] [--reverse [no | reverse | either]] [--method [sum-rgb | red | green | blue | sum-hsb | hue | saturation | brightness | uniqueness | luma | random]] [--diagonal] [--verbose]
```

### Options and parameters ###

* **`INPUT`** *(required string)* - PNG image that is to be sorted.
* **`OUTPUT`** *(required string)* - PNG image that is to be output to. Image does not need to exist.
* **`--min MIN`** *(required integer)* - Minimum length of bandwidth, 1 to infinity. If the length is greater than the dimension of the image, the minimum length is the dimension.
* **`--max MAX`** *(required integer)* - Maximum length of bandwidth, 1 to infinity. If the length is greater than the dimension of the image, the maximum length is the dimension.
* **`--vertical`** or **`-v`** *(optional boolean)* - Sorts vertically instead of horizontally. Defaults to `false`.
* **`--smooth`** or **`-s`** *(optional boolean)* - Places identical pixels adjacent to each other within the band. Here's why this may be needed. Within a band are the following colors: rgb(0, 255, 0), rgb(0, 0, 0), rgb(0, 255, 0). If you sort by the red value, they will all be in the same area because their red values are all 0. However, they will be arranged into the area as they are ordered in the list. If the band is smoothed, the two rgb(0, 255, 0) pixels will be next to each other. Smoothing does not affect values outside of the band. Defaults to `false`.
* **`--reverse REVERSETYPE`** or **`-r REVERSETYPE`** *(optional string)* - Has three options for `REVERSETYPE`: `no`, `reverse`, and `either`. `no` does not reverse the bands. `reverse` does. `either` has a 50% chance of either reversing or keeping it in the same order. Defaults to `no`.
* **`--method METHOD`** or **`-m METHOD`** *(optional string)* - Sets the method used to sort the band. In a different section are descriptions of each method. Defaults to `sum-rgb`.
* **`--diagonal`** or **`-d`** *(optional boolean)* - Sorts pixels diagonally. To reverse the direction of the diagonal, use with `--vertical`. Defaults to `false`.
* **`--verbose`** *(optional boolean)* - Prints to the terminal what the program is currently doing. Defaults to `false`.

### Examples ###

#### Bare minimum ####

```
ruby pxlsrt.rb brute input.png output.png --min 20 --max 30
```

Pixel sorts `input.png` horizontally by the sum of its red, green, and blue values with bandwidths from 20 to 30, does not smooth, does not reverse, and outputs to `output.png`.

#### Full suite example ####

```
ruby pxlsrt.rb brute input.png output.png --min 20 --max 30 --vertical --smooth --reverse reverse --method hue
```

Pixel sorts `input.png` vertically by hue with bandwidths from 20 to 30, smoothes it, reverses direction, and outputs to `output.png`.

#### Full suite shortcut example ####

```
ruby pxlsrt.rb brute input.png output.png --min 20 --max 30 -v -s -r reverse -m hue
```

Same as above example.

## Smart sort ##

Smart sorting uses edges detected within the image (determined through [Sobel operators](http://en.wikipedia.org/wiki/Sobel_operator)) along with a user-defined threshold to define bandwidths to sort.

```
ruby pxlsrt.rb smart INPUT OUTPUT --threshold THRESHOLD [--absolute] [--edge EDGE] [--vertical] [--smooth] [--reverse [no | reverse | either]] [--method [sum-rgb | red | green | blue | sum-hsb | hue | saturation | brightness | uniqueness | luma | random]] [--diagonal]
```

### Options and parameters ###

Options that are shared with the brute method are covered there.

* **`--threshold THRESHOLD`** or **`-t THRESHOLD`** *(required integer)* - Used for edge finding.
* **`--absolute`** or **`-a`** *(optional boolean)* - A different method for edge finding. Defaults to `false`.
* **`--edge EDGE`** or **`-e EDGE`** *(optional integer)* - "Softens" edges. Defaults to `2`.

## Sorting methods ##

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
uniqueness(red, green, blue, reds, greens, blues) = sqrt((red - avg(reds))^2 + (green - avg(greens))^2 + (blue - avg(blues))^2)
```

### luma ###

Sorts by human color perception (similar to brightness and sum-rgb).

```
luma(red, green, blue) = red * 0.2126 + green * 0.7152 + blue * 0.0722
```

### random ###

Randomizes the pixels.
