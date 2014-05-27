pxlsrt
======

Pixel sorter written in Ruby.

```
ruby pxlsrt.rb INPUT OUTPUT --min MIN --max MAX [--vertical] [--smooth] [--reverse [no | reverse | either]] [--method [sum-rgb | red | green | blue | sum-hsb | hue | saturation | brightness | uniqueness]]
```

## Options  and parameters ##

* `INPUT` ***(required string)*** - PNG image that is to be sorted.
* `OUTPUT` ***(required string)*** - PNG image that is to be output to. Image does not need to exist.
* `--min MIN` ***(required integer)*** - Minimum length of bandwidth, 1 to infinity. If the length is greater than the dimension of the image, the minimum length is the dimension.
* `--max MAX` ***(required integer)*** - Maximum length of bandwidth, 1 to infinity. If the length is greater than the dimension of the image, the maximum length is the dimension.
* `--vertical` or `-v` ***(optional boolean)*** - Sorts vertically instead of horizontally. Defaults to `false`.
* `--smooth` or `-s` ***(optional boolean)*** - Places identical pixels adjacent to each other within the band. Here's why this may be needed. Within a band are the following colors: rgb(0, 255, 0), rgb(0, 0, 0), rgb(0, 255, 0). If you sort by the red value, they will all be in the same area because their red values are all 0. However, they will be arranged into the area as they are ordered in the list. If the band is smoothed, the two rgb(0, 255, 0) pixels will be next to each other. Smoothing does not affect values outside of the band. Defaults to `false`.
* `--reverse REVERSETYPE` or `-r REVERSETYPE` ***(optional string)*** - Has three options for `REVERSETYPE`: `no`, `reverse`, and `either`. `no` does not reverse the bands. `reverse` does. `either` has a 50% chance of either reversing or keeping it in the same order. Defaults to `no`.
* `--method METHOD` or `-m METHOD` ***(optional string)*** - Sets the method used to sort the band. In the next section are descriptions of each method. Defaults to `sum-rgb`.

## Sorting methods ##

### sum-rgb ###

Sorts by the sum of the red, green, and blue values of the pixels.

![sum-rgb equation](http://www.sciweavers.org/tex2img.php?eq=f%28red%2C%20green%2C%20blue%29%20%3D%20red%20%2B%20green%20%2B%20blue&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

### red ###

Sorts by the red value of the pixels.

![red equation](http://www.sciweavers.org/tex2img.php?eq=f%28red%2Cgreen%2Cblue%29%20%3D%20red&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

### green ###

Sorts by the green value of the pixels.

![green equation](http://www.sciweavers.org/tex2img.php?eq=f%28red%2Cgreen%2Cblue%29%20%3D%20green&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

### blue ###

Sorts by the blue value of the pixels.

![blue equation](http://www.sciweavers.org/tex2img.php?eq=f%28red%2Cgreen%2Cblue%29%20%3D%20blue&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

### sum-hsb ###

Creates a sum of the hue, saturation, and brightness values of the pixel and sorts by that. The smoothing option is suggested for this method.

![sum-hsb equation](http://www.sciweavers.org/tex2img.php?eq=f%28hue%2Csaturation%2Cbrightness%29%3Dhue%2A100%2F360%20%2B%20saturation%20%2B%20brightness&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

### hue ###

Sorts by the hue value of the pixels, creating something like a rainbow. The smoothing option is suggested for this method.

![hue equation](http://www.sciweavers.org/tex2img.php?eq=f%28hue%2Csaturation%2Cbrightness%29%3Dhue&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

### saturation ###

Sorts by the saturation value of the pixels, creating an effect like the bands are fading to grey. The smoothing option is suggested for this method.

![saturation equation](http://www.sciweavers.org/tex2img.php?eq=f%28hue%2Csaturation%2Cbrightness%29%3Dsaturation&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

### brightness ###

Sorts by the brightness value of the pixels. Produces a similar result to sum-rgb, but not exactly the same.

![brightness equation](http://www.sciweavers.org/tex2img.php?eq=f%28hue%2Csaturation%2Cbrightness%29%3Dbrightness&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

### uniqueness ###

Sorts by the "distance" of the pixel from the average color of band (excluding the pixel being determined).

![uniqueness equation](http://www.sciweavers.org/tex2img.php?eq=f%28red%2C%20green%2C%20blue%2C%20reds%2C%20greens%2C%20blues%29%3D%20%5Csqrt%7B%28red-avg%28reds%29%29%5E%7B2%7D%2B%28green-avg%28greens%29%29%5E%7B2%7D%2B%28blue-avg%28blues%29%29%5E%7B2%7D%7D%20&bc=White&fc=Black&im=jpg&fs=12&ff=arev&edit=0)

## Examples ##

### Bare minimum ###

```
ruby pxlsrt.rb input.png output.png --min 20 --max 30
```

Pixel sorts `input.png` horizontally by the sum of its red, green, and blue values with bandwidths from 20 to 30, does not smooth, does not reverse, and outputs to `output.png`.

### Full suite example ###

```
ruby pxlsrt.rb input.png output.png --min 20 --max 30 --vertical --smooth --reverse reverse --method hue
```

Pixel sorts `input.png` vertically by hue with bandwidths from 20 to 30, smoothes it, reverses direction, and outputs to `output.png`.

### Full suite shortcut example ###

```
ruby pxlsrt.rb input.png output.png --min 20 --max 30 -v -s -r reverse -m hue
```

Same as above example.