;-------------------------------------------------------------------------------
; pixie - a library for basic graphics functions useful 
; for a video display connected to an RCA CDP1861 Pixie Video 
; chip or equivalent.  These routines operate on pixels
; in a buffer used by the display.
;
; Copyright 2024 by Gaston Williams
;
; Based on code from Adafruit_GFX library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright 2012 by Adafruit Industries
; Please see https://learn.adafruit.com/adafruit-gfx-graphics-library for more info
;-------------------------------------------------------------------------------

#include    ../include/ops.inc
#include    ../include/gfx_display.inc
#include    ../include/pixie_def.inc

;--------------------------------------------------------------
; Public routine - This routine defines the OLED display buffer
;--------------------------------------------------------------


;-------------------------------------------------------
; Name: pixie_display_buffer
;
; Buffer for the Pixie Video display.
;
; Parameters: (None)
;
; Return: (None)
;-------------------------------------------------------

; guarantee dma lines of 8 bytes always stay within the same page
.link       .align  qword
            proc    pixie_display_buffer
pixie_buf:    ds    BUFFER_SIZE
            endp
