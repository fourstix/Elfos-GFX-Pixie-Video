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
; Name: pixie_fill_bg
;
; Set or clear the background for a character to be   
; drawn at cursor position x,y.
;
; Parameters: 
;   r9.1 - color (text style: GFX_TXT_NORMAL, GFX_TXT_INVERSE or GFX_TXT_OVERLAY)
;   r9.0 - rotation
;   r8.1 - character scale factor (0,1 = no scaling, or 2-8)
;   r7.1 - cursor y 
;   r7.0 - cursor x 
;
; Return: (None)
;-------------------------------------------------------
            proc    pixie_fill_bg
            ghi     r9                ; get color from temp register
            shl                       ; check for GFX_TXT_OVERLAY value
            lbdf    bg_exit           ; no bg for overlay, so exit immediately

            push    ra                ; save temp register
            push    r9                ; save color register
            push    r8                ; save dimension register
            push    r7                ; save origin register
            
            ; set up character width and height in temp register
            ldi     C_WIDTH
            plo     ra
            ldi     C_HEIGHT
            phi     ra
            
            ghi     r8                ; get scaling factor
            lbz     bg_write          ; if no scaling, just write the back ground  
            smi     01                ; check for s=1, also means no scaling
            lbz     bg_write
            plo     r8                ; save counter in r8.0   
            
bg_loop:    glo     ra                ; adjust width for scaling factor
            str     r2                ; save current width in M(X)
            ldi     C_WIDTH           ; adjust for scaling
            add  
            plo     ra                ; put updated width in temp register
            ghi     ra                ; adjust height for scaling factor
            str     r2                ; save current height in M(X)
            ldi     C_HEIGHT          ; adjust for scaling
            add 
            phi     ra                ; put updated height in temp register
            dec     r8                ; decrement counter
            lbnz    bg_loop           ; repeat until exausted    

bg_write:   copy    ra, r8            ; set up width and height         
            ghi     r9                ; get color from temp register
            lbz     bg_set            ; check for GFX_TXT_INVERSE value

bg_clear:   ldi     GFX_CLEAR         ; GFX_TXT_NORMAL, clear background        
            phi     r9      
            lbr     bg_fill           ; clear character background

bg_set:     ldi     GFX_SET           ; GFX_TXT_INVERSE, set background
            phi     r9
            
bg_fill:    call    gfx_fill_rect     ; fill the character background        
            
bg_done:    pop     r7      
            pop     r8
            pop     r9
            pop     ra

bg_exit:    clc
            return
            endp
