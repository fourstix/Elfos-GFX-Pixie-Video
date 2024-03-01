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
; Private routine - called only by the public routines
; These routines may *not* validate or clip. They may 
; also consume register values passed to them.
;-------------------------------------------------------

;-------------------------------------------------------
; Name: pixie_display_ptr
;
; Get a pointer to the byte in the pixie video display   
; buffer at position x,y.
;
; Parameters: 
;   r7.1 - y (line, 0 to 63)
;   r7.0 - x (byte offset, 0 to 63)
; Registers Used:
;   rf   - pointer to display buffer.                   
; Returns: 
;   rd - pointer to byte (x,y) in display buffer
;-------------------------------------------------------
            proc    pixie_display_ptr 
            push    rf                ; save buffer ptr

            load    rf, pixie_display_buffer
            load    rd, 0             ; clear position
            ghi     r7                ; get line value (0 to $3f) 
            plo     rd                ; put line value in rd
            shl16   rd                ; multiply by 8
            shl16   rd                ; by shifting left
            shl16   rd                ; three times
            
            glo     r7                ; get x (byte offset)
            shr                       ; divide x by 8  
            shr                       ; by shifting right
            shr                       ; three times
            str     r2                ; save in M(X)
            glo     rd                ; add x to line offset  
            add                       ; D = rd + x  
            plo     rd                ; DF has carry
            ghi     rd                ; add carry into rd.1
            adci    0
            phi     rd                ; rd now has the cursor position

            glo     rd                ; add rf to rd
            str     r2                ; put in M(X)
            glo     rf          
            add                       ; add rd.0 to rf.0 
            plo     rd                ; put back into rf.0, DF = carry
            ghi     rd
            str     r2                ; put in M(X)
            ghi     rf
            adc                       ; add rd.1 to rf.1 with carry
            phi     rd                ; rd now points to byte in buffer
            
            pop     rf                ; restore buffer ptr
            return
            
            endp
