;-------------------------------------------------------------------------------
; Draw a set of triangles on a video display connected to an RCA CDP1861
; Pixie Video chip or equivalent.  
;
; Copyright 2024 by Gaston Williams
;
; Based on code from Adafruit_GFX library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright 2012 by Adafruit Industries
; Please see https://learn.adafruit.com/adafruit-gfx-graphics-library for more info
;-------------------------------------------------------------------------------
#include ../include/ops.inc
#include ../include/bios.inc
#include ../include/kernel.inc
#include ../include/pixie_lib.inc
#include ../include/gfx_lib.inc


            org   2000h
start:      br    main


            ; Build information
            ever
            db      'Copyright 2024 by Gaston Williams',0


            ; Main code starts here, check provided argument
main:       lda     ra                  ; move past any spaces
            smi     ' '
            lbz     main
            dec     ra                  ; move back to non-space character
            ldn     ra                  ; get byte
            lbz     draw_it             ; jump if no argument given

            smi     '-'                 ; was it a dash to indicate option?
            lbnz    usage               ; if not a dash, show error  
            inc     ra                  ; move to next character
            lda     ra                  ; check for fill option 
            smi     'r'
            lbnz    usage               ; bad option, show usage message
       
sp_1:       lda     ra                  ; move past any spaces
            smi     ' '
            lbz     sp_1

            dec     ra                  ; move back to non-space character
            ldn     ra                  ; get rotation value
            smi     '0'                 ; should be 0, 1, 2 or 3
            lbnf    usage               ; if less than zero, show usage message
            ldn     ra                  ; check again
            smi     '4'                 ; should be 0, 1, 2 or 3
            lbdf    usage               ; if greater than 3, show usage message
            load    rf, rotate          ; point rf to rotate flag
            ldn     ra                  ; get rotation paramater
            smi     '0'                 ; convert character to digit value
            str     rf                  ; save as rotate flag
            

draw_it:    call    pixie_clear_buffer  ; clear out buffer
            lbdf    error

            ldi     GFX_INVERT          ; set color to invert bits 
            phi     r9
            
            load    rf, rotate          ; set rotation flag
            ldn     rf
            plo     r9
            
            ;------ get the display Ymax, Xmax in ra
            call    gfx_dimensions
            
            ghi     ra                  ; get Ymax
            shr                         ; divide by 2
            phi     rb                  ; save y' = Ymax/2
            glo     ra                  ; get Xmax
            shr                         ; divide by 2
            plo     rb                  ; save x' = Xmax/2
            
            ;------ rb now has half-size dimension values
                      
            ldi     30                  ; start value for i
            plo     rc                  ; save i as counter
                      
loop:       str     r2                  ; save i in M(X)
                      
            ghi     rb                  ; get y' value
            sm                          ; y0 = y' - i
            phi     r7                  ; set y0
            glo     rb                  ; get x' value
            plo     r7                  ; set x0 = x'
            
            ghi     rb                  ; get y' value
            add                         ; y1 = y' + i
            phi     r8                  ; set y1
            glo     rb                  ; get x' value
            sm                          ; x1 = x' - i
            plo     r8                  ; set x1  
                      
            ghi     rb                  ; get y' value
            add                         ; y2 = y' + i
            phi     ra                  ; set y2
            glo     rb                  ; get x' value
            add                         ; x2 = x' + i
            plo     ra                  ; set x2  
            
            ;-----------------------------------
            ; Filled triangle dimensions
            ; x0,y0 = (x', y'-i)
            ; x1,y1 = (x'-i, y'+i)
            ; x2,y2 = (x'+i, y'+i)
            ;-----------------------------------
            
            ;------ draw nested filled triangles
            call    gfx_fill_triangle
            lbdf    error
            
            glo     rc                  ; count i down by 5
            smi     05
            plo     rc                  ; save i for next iteration
            lbnz    loop                ; if i = 0, we are done 
            
            ;------ get the display Ymax, Xmax in ra
            call    gfx_dimensions
            copy    ra, rb              ; save dimensions in rb


            ldi    GFX_SET              ; set color to set bits 
            phi    r9
            
            ;-----------------------------------
            ; Left triangle dimensions
            ; x0,y0 = (0, 0)
            ; x1,y1 = (0, Ymax/2)
            ; x2,y2 = (24, 0)
            ;-----------------------------------
            
            ldi     0                   
            plo     r7                  ; x0 = 0
            phi     r7                  ; y0 = 0
            plo     r8                  ; x1 = 0
            phi     ra                  ; y2 = 0
            ghi     rb                  ; get Ymax
            shr                         ; divide by 2
            phi     r8                  ; y1 = Ymax/2
            ldi     24                  ; x2 = 24 
            plo     ra

            ;------ draw left triangle
            call    gfx_draw_triangle
            lbdf    error

            ;-----------------------------------
            ; Right triangle dimensions
            ; x0,y0 = (Xmax, 0)
            ; x1,y1 = (Xmax - 24, 0)
            ; x2,y2 = (Xmax, Ymax/2)
            ;-----------------------------------
            
            ldi     0
            phi     r7                  ; y0 = 0
            phi     r8                  ; y1 = 0
            glo     rb                  ; get Xmax
            plo     r7                  ; x0 = Xmax
            plo     ra                  ; x2 = Xmax
            smi     24                  
            plo     r8                  ; x1 = Xmax - 24
            ghi     rb                  ; get Ymax
            shr                         ; divide by 2
            phi     ra                  ; y2 = Ymax/2

            ;------ draw right triangle
            call    gfx_draw_triangle
            lbdf    error
            
            ;---- update display until input button is pressed
show_it:    call  pixie_begin_display
            von
wait:       bn4   wait  
            voff
            call  pixie_end_display

done:       clc   
            return

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: triangles [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
            
error:      call o_inmsg
            db  'Error drawing triangles.',10,13,0
            abend                       ; return to Elf/OS with error code
                        
            ;---- rotation flag
rotate:     db 0            
            
            end   start
