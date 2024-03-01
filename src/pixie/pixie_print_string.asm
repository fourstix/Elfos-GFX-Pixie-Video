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
#include    ../include/gfx_lib.inc

;-------------------------------------------------------
; Public routine - This routine validates the origin
;   and the character string will wrap around the 
;   display boundaries.
;-------------------------------------------------------

;---------------------------------------------------------------------
; Name: pixie_print_string
;
; Set pixels in the display buffer to define a string of 
; ASCII characters at position x,y.  The string will wrap 
; around the display if needed.  
;
; Parameters: 
;   r7.1 - y (row)
;   r7.0 - x (column)
;   r9.1 - color (text style: GFX_TXT_NORMAL, GFX_TXT_INVERSE or GFX_TXT_OVERLAY)
;   r9.0 - rotation
;   r8.1 - character scale factor (0,1 = no scaling, or 2-8)
;   rf   - pointer to null-terminated ASCII string
;
; Note: Checks x,y values, error if out of bounds. 
;       Checks ASCII character value, draws DEL (127) if out of bounds
;                  
; Returns: 
;    DF = 1 if error, 0 if no error
;    r7 points to next character position after string
;---------------------------------------------------------------------
            proc    pixie_print_string
            push    r9                ; save color register
            push    r8                ; save character register
                        
ds_loop:    lda     rf                ; r8 points to string of characters  
            lbz     ds_done           ; null ends the string
            plo     r8                ; put character to draw
            
            CALL    pixie_print_char  ; r7 advances to next position  
            
            lbdf    ds_done           ; exit immediately if error
            lbr     ds_loop           ; continue if no error  
            
ds_done:    pop     r8                ; restore registers
            pop     r9
            return                    ; return after string drawn
                        
            endp
