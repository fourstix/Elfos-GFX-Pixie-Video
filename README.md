# Elfos-GFX-Pixie-Video
Graphics device library and programs written for a 1861 Pixie Video Display using the GFX-1802-Library graphics library on a microcomputer running Elf/OS operating system.

Introduction
------------
This repository contains 1802 Assembler code for a Pixie Video graphics device library that implements the GFX Display Interface from the [GFX-1802-Library](https://github.com/fourstix/GFX-1802-Library) based on Adafruit's [Adafruit_GFX-Library](https://github.com/adafruit/Adafruit-GFX-Library) written by Ladyada Limor Fried. 

Platform  
--------
These programs were assembled and linked with updated versions of the Asm-02 assembler and Link-02 linker by Mike Riley. The updated versions required to assemble and link this code are available at [arhefner/Asm-02](https://github.com/arhefner/Asm-02) and [arhefner/Link-02](https://github.com/arhefner/Link-02).

The graphics demo programs use the common [GFX 1802 library](https://github.com/fourstix/GFX-1802-Library) with the Elfos-GFX-Pixie-Video device library to draw to the display.

The graphics demo programs should run on any compatible Pixie Video system, such as 
an Elf system with an [RCA CDP1861 Video]() chip, a Pico/Elf v2 with the [Pixie Video GLCD](https://github.com/fourstix/PicoElfPixieVideoGLCDV2) card or an [1802-Mini](https://github.com/dmadole/1802-Mini) with the [1802-Mini Pixie Video](https://github.com/dmadole/1802-Mini-Pixie-Video) card.

Pixie Video Libraries
---------------------
<table>
<tr><th>Library</th><th>Resolution</th><th>Size</th></tr>
<tr><td>pixie_lo.lib</td><td>Low</td><td>64x32</td></tr>
<tr><td>pixie.lib</td><td>Medium</td><td>64x64</td></tr>
<tr><td>pixie_hi.lib</td><td>High</td><td>64x128</td></tr>
</table>


Pixie Video Library API
-----------------------

## Public API List

* pixie_begin_display - set up the pixie video interrupt and DMA registers.
* pixie_end_display   - reset the pixie video interrupt and DMA registers.
* pixie_clear_buffer  - clear all bits in the display buffer.
* pixie_fill_buffer   - set all bits in the display buffer. 
* pixie_print_char    - draw a character at cursor x0,y0
* pixie_print_string  - draw a null-terminated string at x0,y0


## API Notes:
* rf = pointer to null-terminated string to draw
* r7.1 = origin y (row value, 0 to 63)
* r7.0 = origin x (column value, 0 to 127)
* r9.1 = text style, color
* r9.0 = rotation
* r8.1 = text size
* r8.0 = ASCII character to draw

## API Program Notes:
* pixie_begin_display should be called once before video is turned on.
* The INP 1 (1802 opcode 69) instruction turns video on.
* When the video is on, the video interrupt is called to set up DMA transfers to the display.
* The OUT 1 (1802 opcode 61) instruction turns video off.
* Video should be turned off when updates are made to the display buffer.
* At the end of the display program, video should be turned off.
* pixie_end_display must be called to reset the interrupt and DMA registers before the program returns to the Elf/OS. 

<table>
<tr><th>API Name</th><th colspan="3">Inputs</th><th colspan="5">Notes</th></tr>
<tr><td>pixie_begin_display</td><td colspan="3"> (None) </td><td colspan="5">Set up the Pixie Video interrupt and DMA registers.</td></tr>
<tr><td>pixie_end_display</td><td colspan="3"> (None) </td><td colspan="5">Reset the Pixie Video interrupt and DMA registers.</td></tr>
<tr><td>pixie clear_buffer</td><td colspan="3"> (None) </td><td colspan="5">Clears all bits in the buffer memory</td></tr>
<tr><td>pixe_fill_buffer</td><td colspan="3"> (None) </td><td colspan="5">Sets all bits in the buffer memory</td></tr>
<tr><th rowspan="2">API Name</th><th>R7.1</th><th>R7.0</th><th>R8.1</th><th>R8.0</th><th>R9.1</th><th>R9.0</th><th>RF</th></tr>
<tr><th colspan="8">Notes</th></tr>
<tr><td rowspan="2">pixie_print_char</td><td>origin y</td><td>origin x</td><td>text size</td><td>character</td><td>text style</td><td>rotation</td><td>-</td></tr>
<tr><td colspan="8">Checks origin x,y values, returns error (DF = 1) if out of bounds. Checks ASCII character value, draws DEL (127) if non-printable. On return r7 points to next character cursor position (text wraps).</td></tr>
<tr><td rowspan="2">pixie_print_string</td><td>origin y</td><td> origin x</td><td>text size</td><td>character</td><td>text style</td><td>-</td><td>Pointer to null terminated ASCII string.</td></tr>
<tr><td colspan="8">Checks origin x,y values, returns error (DF = 1) if out of bounds. Checks ASCII character value, draws DEL (127) if non-printable. On return r7 points to next character cursor position (text wraps).</td></tr>
</table>

## Color Constants
<table>
<tr><th>Name</th><th>Description</th><tr>
<tr><td>GFX_SET</td><td>Set Pixel (On)</td><tr>
<tr><td>GFX_CLEAR</td><td>Clear Pixel (Off)</td><tr>
<tr><td>GFX_INVERT</td><td>Flip Pixel State</td><tr>
</table>

## Text Style Constants
<table>
<tr><th>Name</th><th>Description</th><tr>
<tr><td>GFX_TXT_NORMAL</td><td>Background pixels are cleared and character pixels are set</td><tr>
<tr><td>GFX_TXT_INVERSE</td><td>Background pixels are set and character pixels are cleared</td><tr>
<tr><td>GFX_TXT_OVERLAY</td><td>Background pixels unchanged and character pixels are inverted</td><tr>
</table>

## Text Size Constants
<table>
<tr><th>Name</th><th>Scale Value</th><th>Description</th><tr>
<tr><td>GFX_TXT_DEFAULT</td><td>0</td><td>Default text size (small)</td><tr>
<tr><td>GFX_TXT_SMALL</td><td>1</td><td>Small text size</td><tr>
<tr><td>GFX_TXT_MEDIUM</td><td>2</td><td>Medium text size</td><tr>
<tr><td>GFX_TXT_LARGE</td><td>4</td><td>Large text size</td><tr>
<tr><td>GFX_TXT_HUGE</td><td>8</td><td>Huge text size</td><tr>
</table>


## Rotation Constants
<table>
<tr><th>Name</th><th>value</th><th>Description</th></tr>
<tr><td>ROTATE_0</td><td rowspan="3">0</td><td rowspan="3">No Rotation (upright)</td></tr>
<tr><td>ROTATE_NONE</td></tr>
<tr><td>ROTATE_360</td></tr>
<tr><td>ROTATE_90</td><td>1</td><td>Rotate display 90 degrees counter-clockwise</td></tr>
<tr><td>ROTATE_180</td><td>2</td><td>Rotate display 180 degrees counter-clockwise (upside-down)</td></tr>
<tr><td>ROTATE_270</td><td>3</td><td>Rotate display 270 degrees counter-clockwise (90 degrees clockwise)</td></tr>
</table>

## Private Methods
* pixie_display_buffer - memory buffer for the Pixie Video display
* pixie_display_ptr    - returns a pointer to a particular x,y pixel location in the display buffer
* pixie_fill_bg        - fill in the background color for a character printed to the display 

GFX Display Interface
---------------------
The following methods are implemented in each library, pixie_lo.lib, pixie.lib and pixie_hi.lib, and are called by methods in the gfx library gfx.lib.  These methods encapsulate the Pixie Video device specific details for a given resolution.  The source file gfx_display.asm contains the logic so that when a GFX display interface method is called it delegates to the appropriate Pixie Video private method.

## GFX Interface Methods

* gfx_disp_size   - return the height and width of the display.
* gfx_disp_clear  - set the memory buffer data to clear all pixels.
* gfx_disp_pixel  - set the data in the memory buffer corresponding to a particular x,y co-ordinates in the display.
* gfx_disp_h_line - set the data in the memory buffer for a horizontal line.
* gfx_disp_v_line - set the data in the memory buffer for a vertical line

## GFX Display Interface to SPI OLED Methods

<table>
<tr><th>Interface Method</th><th>SPI OLED Method</th></tr>
<tr><td>gfx_disp_size</td><td>(code in gfx_display)</td></tr>
<tr><td>gfx_disp_clear</td><td>pixie_clear_buffer</td></tr>
<tr><td>gfx_disp_pixel</td><td>pixie_write_pixel</td></tr>
<tr><td>gfx_disp_h_line</td><td>pixie_fast_h_line</td></tr>
<tr><td>gfx_disp_v_line</td><td>pixie_fast_v_line</td></tr>
</table>

## Interface Registers:
* ra.1 = display height 
* ra.0 = display width
* r9.1 = color
* r8.0 = line length
* r7.1 = origin y (row value, 0 to display height-1)
* r7.0 = origin x (column value, 0 to display width-1)

<table>
<tr><th>Name</th><th>R7.1</th><th>R7.0</th><th>R8.0</th><th>R9.1</th><th>Returns</th></tr>
<tr><td rowspan="2">gfx_disp_size</th><td rowspan="2" colspan="4">(No Inputs)</td><td>RA.1 = device height</td></tr>
<tr><td>RA.0 = display width</td></tr>
<tr><td>pixie_clear_buffer</th><td colspan="4">(No Inputs)</td><td>DF = 1, if error</td></tr>
<tr><td>pixie_write_pixel</td><td>y</td><td>x</td><td> - </td><td>color</td><td>DF = 1, if error</td></tr>
<tr><td>pixie_fast_h_line</td><td>origin y</td><td>origin x</td><td>length</td><td>color</td><td>DF = 1, if error</td></tr>
<tr><td>pixie_fast_v_line</td><td>origin y</td><td>origin x</td><td>length</td><td>color</td><td>DF = 1, if error</td></tr>
</table>


Pixie Video Graphics Demos
--------------------------

<table class="table table-hover table-striped table-bordered">
  <tr align="center">
   <td><img width=300 src="https://github.com/fourstix/Elfos-GFX-Pixie-Video/blob/main/pics/bitmaps.jpg"></td>
   <td><img width=300 src="https://github.com/fourstix/Elfos-GFX-Pixie-Video/blob/main/pics/lines.jpg"></td> 
  </tr>
  <tr align="center">
   <td >Bitmaps Demo</td>
   <td >Lines Demo</td>
  </tr> 
  <tr align="center">
   <td><img width=300 src="https://github.com/fourstix/Elfos-GFX-Pixie-Video/blob/main/pics/tao.jpg"></td>
   <td><img width=300 src="https://github.com/fourstix/Elfos-GFX-Pixie-Video/blob/main/pics/triangles.jpg"></td> 
  </tr>
  <tr align="center">
   <td >Circles and Arcs Demo</td>
   <td >Triangles Demo</td>
  </tr>
  <tr align="center">
   <td><img width=300 src="https://github.com/fourstix/Elfos-GFX-Pixie-Video/blob/main/pics/charset.jpg"></td>
   <td><img width=300 src="https://github.com/fourstix/Elfos-GFX-Pixie-Video/blob/main/pics/charset2.jpg"></td> 
  </tr>
  <tr align="center">
   <td colspan="2">Charset Demo<</td>
  </tr> 
  <tr align="center">
   <td><img width=300 src="https://github.com/fourstix/Elfos-GFX-Pixie-Video/blob/main/pics/spaceship2.jpg"></td>
   <td><img width=300 src="https://github.com/fourstix/Elfos-GFX-Pixie-Video/blob/main/pics/textbg.jpg"></td> 
  </tr>
  <tr align="center">
   <td >Spaceship Demo</td>
   <td >Text Background Demo</td>
  </tr>  
</table>

These programs use the [Common GFX 1802 library.](https://github.com/fourstix/GFX-1802-Library) and the Pixie Video graphics device library to write to the display.  They all support rotation of the display through the -r option.  Press the input button to end the program.  

All the graphics programs use the Medium Resolution (64x64) pixie graphics device library, except the spaceship2 and tao graphics program that use the Low Resolution (64x32) pixie_lo graphics device library.

## pixels
**Usage:** pixels [-r 0|1|2|3]   
Draws a simple pixel pattern on the display. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

## linetest  
**Usage:** linetest [-r 0|1|2|3] 
Draws various lines on the display. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.
 
## lines
**Usage:** lines [-r 0|1|2|3]   
Draws a simple line pattern on the display. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.
  
## reversed
**Usage:** reversed [-r 0|1|2|3]  
Draws a line pattern reversed (black on white) on the display. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.
     
## boxes
**Usage:** boxes [-r 0|1|2|3]  
Draws rectangles in a pattern on the display. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

## blocks
**Usage:** blocks [-r 0|1|2|3]    
Draws filled rectangles in a pattern on the display. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

## spaceship2
**Usage:** spaceship2   
Show the classic Elf spaceship program graphic on the display in Low Resolution. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

## bitmaps
**Usage:** bitmaps [-r 0|1|2|3]    
Draws Adafruit bitmaps on the display. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

## charset
**Usage:** charset [-r 0|1|2|3]
Draws the printable ASCII character set on the display. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to step through the character displays and end the program.

## helloworld
**Usage:** helloworld [-r 0|1|2|3]
Draws the classic text greeting on the display in small text.  Followed by a response in large text. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

## textbg
**Usage:** textbg [-r 0|1|2|3]
Draws text strings on the display, using the normal, inverse and overlay text options. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

## align
**Usage:** align [-r 0|1|2|3]
Draws a set of lines and rectangles with an inverse text string on the display to show the pixel alignment. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

## tao
**Usage:** tao [-r 0|1|2|3]
Draws a yin yang symbol on the display in Low Resolution to show the circle and arc functions. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

## triangles
**Usage:** triangles [-r 0|1|2|3]
Draws a set of triangles on the display. The option -r n, where n = 0,1,2 or 3, will rotate the display n*90 degrees counter-clockwise. Press the input button to end the program.

Repository Contents
-------------------
* **/src/pixie/**  -- Source files for the Pixie Video graphics device libraries.
  * *.asm - Assembly source files for library functions.
  * build.bat - Windows batch file to assemble and create the pixie_lo low resolution (64x32) graphics device library, the pixie medium resolution (64x64) graphics library and the pixie_hi high (64x128) resolution graphics library. Replace [Your_Path] with the correct path information for your system. 
  * clean.bat - Windows batch file to delete the pixie graphics device libraries and their associated files.   
* **/src/include/**  -- Include files for the graphics display programs and their libraries.  
  * sysconfig.inc - System configuration definitions for programs.
  * gfx_lib.inc - External definitions for the common GFX 1802 Library.
  * pixie_lib.inc - External definitions for the Pixie Video graphics device libraries.
  * pixie_def.inc - Definitions for Pixie Video private library methods.
  * gfx_display.inc - Definitions required for the GFX Display Interface.
  * ops.inc - Opcode definitions for Asm/02.
  * bios.inc - Bios definitions from Elf/OS
  * kernel.inc - Kernel definitions from Elf/OS
* **/src/lib/**  -- Library files for the Pixie graphics demos.
  * gfx.lib -  [Common GFX 1802 library.](https://github.com/fourstix/GFX-1802-Library)
  * pixie_lo.lib - Pixie Video Low Resolution (64x32) device library
  * pixie.lib - Pixie Video Medium Resolution (64x64) device library
  * pixie_hi.lib - Pixie Video High Resolution (64x128) device library
* **/src/demos/**  -- Source files for demo programs for OLED display drivers
  * pixels.asm - Demo program to draw a simple pattern with pixels on the display screen.
  * lines.asm - Demo program to draw lines in a pattern on the display screen.
  * linetest.asm - Demo program to draw various lines on the display screen. 
  * reversed.asm - Demo program to draw lines in a reversed pattern (black on white) on the display screen.
  * blocks.asm - Demo program to draw filled rectangles on the display screen. 
  * boxes.asm - Demo program to draw rectangles on the display screen.
  * spaceship2.asm - Demo program to draw the classic Elf spaceship program graphic  in Low Resolution (64x32) on the display.
  * bitmaps.asm - Demo program to draw Adafruit flower bitmaps on the display screen.
  * charset.asm - Demo program to draw the printable ASCII character set on the display screen.
  * helloworld.asm - Demo program to draw the classic greeting and a response on the display screen.
  * textbg.asm - Demo program to draw text with normal, inverse and overlay options on the display screen.
  * align.asm - Demo program to draw lines, rectangles and inverse text to show pixel alignment.
  * tao - Demo program to draw a yin yang symbol in low resolution (64x32) on the display.
  * triangles - Demo program to draw a set of triangles on the display.
  * build.bat - Windows batch file to assemble and link the sh1106 programs. Replace [Your_Path] with the correct path information for your system.
  * clean.bat - Windows batch file to delete assembled binaries and their associated files.
* **/bin/**  -- Binary files for Pixie Video graphics demo programs.
* **/lib/**  -- Pixie Video graphics device library files.
  * pixie_lo.lib - Pixie Video Low Resolution (64x32) device library
  * pixie.lib - Pixie Video Medium Resolution (64x64) device library
  * pixie_hi.lib - Pixie Video High Resolution (64x128) device library
* **/lbr/**  -- Elf/OS library file with Pixie Video graphics demo programs.
  * pixie_demo.lbr - Extract the program files with the Elf/OS command *lbr e pixie_demo*
* **/docs/**  - Documentation files for the Pixie Video display.
  * cdp1861.pdf - RCA CDP1861 Pixie Video Chip Datasheet

License Information
-------------------

This code is public domain under the MIT License, but please buy me a beverage
if you use this and we meet someday (Beerware).

References to any products, programs or services do not imply
that they will be available in all countries in which their respective owner operates.

Adafruit, the Adafruit logo, and other Adafruit products and services are
trademarks of the Adafruit Industries, in the United States, other countries or both. 

Any company, product, or services names may be trademarks or services marks of others.

All libraries used in this code are copyright their respective authors.

This code is based on code written by Tony Hefner and assembled with the Asm/02 assembler and Link/02 linker written by Mike Riley.

Elf/OS  
Copyright (c) 2004-2023 by Mike Riley

Asm/02 1802 Assembler  
Copyright (c) 2004-2023 by Mike Riley

Link/02 1802 Linker  
Copyright (c) 2004-2023 by Mike Riley

The Adafruit_GFX Library  
Copyright (c) 2012-2023 by Adafruit Industries   
Written by Limor Fried/Ladyada for Adafruit Industries. 

The 1802-Mini Microcomputer Hardware   
Copyright (c) 2020-2023 by David Madole

Many thanks to the original authors for making their designs and code available as open source.
 
This code, firmware, and software is released under the [MIT License](http://opensource.org/licenses/MIT).

The MIT License (MIT)

Copyright (c) 2023 by Gaston Williams

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

**THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.**
