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

;-------------------------------------------------------
; Public routine - This routine files the buffer with
;   the byte $FF so that all pixels are set.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: pixie_fill_buffer
;
; Fill the entire display buffer so all pixels are set.
;
; Parameters:
; Registers Used: 
;   rf - pointer to display buffer.
;   rc - counter
;
; Return: (None)
;-------------------------------------------------------
            proc    pixie_fill_buffer
            push    rf                ; save buffer ptr            
            push    rc                ; save counter

            load    rf, pixie_display_buffer
            load    rc, BUFFER_SIZE   ; set counter
             
fb_loop:    ldi     $FF
            str     rf
            inc     rf
            dec     rc
            lbrnz   rc, fb_loop

            pop     rc
            pop     rf
            
            clc                       ; make sure DF = 0            
            return

            endp
