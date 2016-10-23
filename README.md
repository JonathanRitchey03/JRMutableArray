# JRMutableArray
Bare-bones 1D Array for Swift w/ awesome Visualization!

[![Build Status](https://www.bitrise.io/app/285e3efb30c07e22.svg?token=yMh7S2W8To48ugOVAV8h0A&branch=master)](https://www.bitrise.io/app/285e3efb30c07e22)
![Platforms](https://img.shields.io/badge/platforms-ios-green.svg)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
[![codebeat badge](https://codebeat.co/badges/d5bc952d-890a-4efb-bcc0-fd960734df1d)](https://codebeat.co/projects/github-com-jonathanritchey03-jrmutablearray)

## Demo
![Alt text](/JRMutableArrayDemo.gif?raw=true "Visualize an Array!")

## Setup
1. Drop JRMutableArray.swift and JRDrawKit.swift into your project.
1. Example code snippet:

```
let numbers = JRMutableArray()
for i in 0...50 {
	numbers[i] = i
}
```

## How to use QuickLook
1. Set a breakpoint
1. Press on the little eye icon when referencing the array.
1. The array should render out into a display view supplying an overview for the array's contents.
1. Note: For object other than numbers, the description selector is used to print out each object's value.
1. If the object is a number, a blue bar is rendered, otherwise only the text description is used.

## Rendering history

![Alt text](/JRMutableArrayQuickSortDemo.gif?raw=true "Animated Quicksort!")

Currently the array supports rendering a time series of images for the entire history of the array, allowing for historical debugging.

1. Create a /tmp if you don't have a /tmp directory on your root drive.
1. Set a breakpoint.
1. In LLDB issue the following command(substitute myArray w/ the name of your array):
```
p myArray.writeToTmp()
```
1. Wait for a while, it can take a minute to render out the images depending on the history length and array size.
1. Open up the terminal and type:
```
open /tmp
```
1. Use finder to browse through the frames.
1. You can also make a movie by installing ffmpeg.
1. To install ffmpeg use:
```
brew install ffmpeg
```
1. In the terminal go to the /tmp directory and type:
```
ffmpeg -r 2 -i myarray%d.png -vcodec qtrle myarray.mov
```

## Todo
1. Add read/write color to historical renderings.
1. Add which thread is accessing array.
1. Add automatic movie playing if ffmpeg is installed.
1. Add marking for individual index.
1. Add ability to mark ranges with a color for debugging purposes, i.e. pivot in sort, or range in binary search.
1. Add support for only keeping track of the last N steps in history to avoid large memory usage.

## Credits
- Based on: https://www.guiguan.net/ggmutabledictionary-thread-safe-nsmutabledictionary/
- and Ray Wenderlich's GCD tutorial: http://www.raywenderlich.com/60749/grand-central-dispatch-in-depth-part-1
