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
            
;-------------------------------------------------------
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: pixie_write_pixel
;
; Set a pixel in the display buffer at position x,y.
;
; Parameters: 
;  r7.1 - y (line, 0 to 63)
;  r7.0 - x (pixel offset, 0 to 127)
;  r9.1 - color (GFX_SET, GFX_CLEAR, GFX_INVERT)
; Registers Used: 
;  rd - pointer to byte in buffer
;  rc.1 - bit mask            
;  rc.0 - bit counter                  
; 
; Returns: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    pixie_write_pixel
            push    rd                ; save position register 
            push    rc                ; save bit mask register

            call    pixie_display_ptr  ; point rd to byte in buffer

            ldi     $80               ; bit mask for horizontal pixel byte
            phi     rc                ; store bit mask in rc.1
            glo     r7                ; horizontal pixel bytes, so get x position for bitmask
            ani     $07               ; mask off 3 lower bits to get pixel position
            plo     rc                ; store in bit counter rc.0
            
shft_bit1:  lbz     set_bit
            ghi     rc
            shr                       ; shift mask one bit     
            phi     rc                ; save mask in rc.1
            dec     rc                ; count down
            glo     rc                ; check counter
            lbr     shft_bit1         ; repeat until count down to zero

set_bit:    ghi     rc                ; get mask from rc (LSB bit order)
            str     r2                ; store mask at M(x)
            ghi     r9                ; get color from temp register
            lbz     clr_bit           ; check for GFX_CLEAR value
            shl                       ; check for GFX_INVERT value
            lbdf    flip_bit    
            ldn     rd                ; get byte from buffer
            or                        ; OR mask to set bit
            str     rd                ; put updated byte back in buffer
            lbr     wp_done           
clr_bit:    ldi     $FF               ; invert bit mask so selected bit is zero
            xor                       ; Filp all mask bits ~(Bit Mask) 
            str     r2                ; put inverse mask in M(X)
            ldn     rd                ; get byte from buffer
            and                       ; AND inverse mask to clear bit
            str     rd                ; put updated byte back in buffer
            lbr     wp_done           
flip_bit:   ldn     rd                ; get byte from buffer
            xor                       ; XOR mask to invert bit
            str     rd                ; put updated byte back in buffer

wp_done:    pop     rc                ; restore bit register 
            pop     rd                ; restore position register

            clc                       ; Set no error
            return

            endp 
