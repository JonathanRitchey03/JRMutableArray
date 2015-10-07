# JRMutableArray
Thread-safe mutable array for Swift with QuickLook support

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
1. The array should render out into the a display view supplying an overview for the array's contents.
1. Note: The description selector is used to print out each object's value.
1. If the object is a number a blue bar is rendered, otherwise only the text description is used.

## Rendering history
Currently the array is supports rendering a time series of images for the entire history of the array, allowing for historical debugging.

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
ffmpeg -i myarray%d.png -vcodec qtrle myarray.mov
```

## Credits
- Based on Guan Gui's post on thread-safe mutable dictionaries. https://www.guiguan.net/ggmutabledictionary-thread-safe-nsmutabledictionary/

- Based on Ray Wenderlich's GCD tutorial: http://www.raywenderlich.com/60749/grand-central-dispatch-in-depth-part-1
