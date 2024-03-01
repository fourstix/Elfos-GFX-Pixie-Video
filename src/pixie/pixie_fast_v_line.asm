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
#include    ../include/bios.inc
#include    ../include/kernel.inc
#include    ../include/ops.inc
#include    ../include/gfx_display.inc
#include    ../include/pixie_def.inc

;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: pixie_fast_v_line
;
; Draw a vertical line starting at position x,y.
; Uses logic instead of calling write pixel.
;
; Parameters: 
;   r7.1 - origin y 
;   r7.0 - origin x 
;   r9.1 - color 
;   r8.0 - length  (h)   
;                  
; Return: (None) r8.0 - consumed
;-------------------------------------------------------
            proc    pixie_fast_v_line
            
            push    rd                ; save position register 
            push    rc                ; save bit mask register     
            
            ; increase length to always draw at least one pixel
            ; inc    r8           
            
            call    pixie_display_ptr ; point rd to byte in buffer

            ldi     $80               ; bit mask for vertical pixie byte
            phi     rc                ; store bit mask in rc.1
            glo     r7                ; horizontal pixel bytes, so get x position for bitmask
            ani     $07               ; mask off 3 lower bits to get pixel position
            plo     rc                ; store in bit counter rc.0
            
shft_xbit:  lbz     chk_color
            ghi     rc
            shr                       ; shift mask one bit     
            phi     rc                ; save mask in rc.1
            dec     rc                ; count down
            glo     rc                ; check counter
            lbr     shft_xbit         ; repeat until count down to zero

chk_color:  ghi     r9                ; get color from temp register
            lbnz    wfh_loop          ; check for GFX_SET or SET_INVERSE
            ghi     rc                ; get mask from rc (MSB bit order)
            str     r2                ; store GFX_CLEAR mask at M(x)
            ldi     $FF               ; invert bit mask so selected bit is zero
            xor                       ; Filp all mask bits ~(Bit Mask)             
            phi     rc                ; put inverted mask back for later

wfh_loop:   ghi     rc                ; get mask from rc (MSB bit order)
            str     r2                ; store mask at M(x) 
            ghi     r9                ; always do at least one pixel, so get color
            lbz     clr_xbit          ; check for GFX_CLEAR value
            shl                       ; check for GFX_INVERT value
            lbdf    flip_xbit                
                          
set_xbit:   ldn     rd                ; get byte from buffer
            or                        ; OR mask to set bit
            str     rd                ; put updated byte back in buffer
            lbr     wfh_chk           
clr_xbit:   ldn     rd                ; get byte from buffer
            and                       ; AND inverse mask to clear bit
            str     rd                ; put updated byte back in buffer
            lbr     wfh_chk           
flip_xbit:  ldn     rd                ; get byte from buffer
            xor                       ; XOR mask to invert bit
            str     rd                ; put updated byte back in buffer
  
wfh_chk:    glo     r8                ; check length count
            lbz     wh_done           ; if zero we are done
            ADD16   rd, 8             ; move ptr to next line (8 bytes per line)
            dec     r8                ; draw length of h pixels
            lbr     wfh_loop            

wh_done:    pop     rc
            pop     rd
            clc                       ; clear DF after shifting
            return

            endp
