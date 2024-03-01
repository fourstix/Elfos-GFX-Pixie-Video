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
#include    ../include/bios.inc
#include    ../include/kernel.inc
#include    ../include/gfx_display.inc
#include    ../include/pixie_def.inc
            
;---------------------------------------------------------
; Public routine - This routine updates the display 
;---------------------------------------------------------

;-------------------------------------------------------
; Name: pixie_end_display
;
; End the Pixie Video display. Set the interrupt handler
; and DMA registers to zero and disable interrupts.
;
; Parameters: (None)
;
; Returns: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    pixie_end_display

            cli                 ; disable interrupts
            ldi     $00                  
            phi     r1          ; clear out interrupt register 
            plo     r1
            phi     r0          ; clear out dma register 
            phi     r0    

            return

            endp
