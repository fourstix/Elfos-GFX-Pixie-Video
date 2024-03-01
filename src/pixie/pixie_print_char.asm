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
;   and the next character position will wrap around
;   the display boundaries.
;-------------------------------------------------------


;---------------------------------------------------------------------
; Name: pixie_print_char
;
; Set pixels in the display buffer to define a 6x8 
; ASCII character at position x,y.  
;
; Parameters: 
;   r7.1 - y row
;   r7.0 - x column
;   r9.1 - color (text style: GFX_TXT_NORMAL, GFX_TXT_INVERSE or GFX_TXT_OVERLAY)
;   r9.0 - rotation
;   r8.1 - character scale factor (0,1 = no scaling, or 2-8)
;   r8.0 - ASCII character to print
;
; Note: Checks origin x,y adjusts to next valid cursor position
;       Checks ASCII character value, draws DEL (127) if out of bounds
;                  
; Return: 
;   r7 will point to next cursor position (text wraps)
;---------------------------------------------------------------------
            proc    pixie_print_char      
            push    r9                ; save color register
            push    r8                ; save character register
                              
            call    gfx_adj_cursor    ; adjust position to valid cursor position                                    
                                           
            ;---- draw text background if needed
            call    pixie_fill_bg
            
            call    gfx_draw_char     ; write the character to display
            ;---- space characters one column apart
            ghi     r8                ; get the scaling value
            lbnz    adjust            ; non-zero is okay
            ldi     $01               ; zero means one space
adjust:     str     r2                ; save spacing in M(X)
            glo     r7                ; get x value
            add                       ; adjust x by spacing    
            plo     r7                

            pop     r8                ; restore registers
            pop     r9
            clc                       ; indicate no error
pc_exit:    return    
     
            endp
