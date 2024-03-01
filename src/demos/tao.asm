;-------------------------------------------------------------------------------
; Display a set of circles and arcs on a video display connected
; to an RCA CDP1861 Pixie Video chip or equivalent.  
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


      extrn  gfx_debug
            
            org   2000h
start:      br    main


            ; Version and Build information
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
            

draw_it:    call  pixie_clear_buffer     ; clear out buffer
            lbdf  error
              

            ldi    GFX_SET              ; set color 
            phi    r9
            
            load    rf, rotate          ; set rotation flag
            ldn     rf
            plo     r9
                                                

            ;------ fill circle in middle of display             
            call   gfx_dimensions       ; put Ymax and Xmax in ra
            
            ghi     ra                  ; get Ymax
            shr                         ; divide by 2
            phi     r7                  ; set origin y = Ymax/2
            glo     ra                  ; get Xmax
            shr                         ; divide by 2
            plo     r7                  ; set origin x = Xmax/2
            ldi     15                  
            plo     r8                  ; set radius = 15 pixels
                      
            call  gfx_fill_circle       ; draw white circle for yang
            lbdf  error

            ;------ clear bottom half of circle for yin
            ghi     ra                  ; get Ymax
            shr                         ; divide by 2
            phi     r8                  ; h = Ymax/2
            adi      1                  ; add one
            phi     r7                  ; set origin one below origin
            ldi      0
            plo     r7                  ; set origin at 0
            glo     ra
            plo     r8                  ; w = Xmax

            ldi     GFX_CLEAR           ; set color to clear 
            phi     r9

            call    gfx_fill_rect       ; erase bottom half of circle for yin
            
            ghi     ra                  ; get Ymax
            shr                         ; divide by 2
            phi     r7                  ; set origin to Ymax/2
            glo     ra                  ; get Xmax
            shr                         ; divide by 2
            smi     7                   ; subtract minor circle radius  
            plo     r7                  ; Xmax/2 - r' for yang
            ldi     7
            plo     r8                  ; set minor radius r' = 7
            
            call    gfx_fill_circle     ; draw yin 
            
            ldi     GFX_SET             ; set color to white 
            phi     r9
            ldi     2
            plo     r8                  ; set radius r'' = 2
            
            call    gfx_draw_circle     ; draw small white circle in yin 

            ghi     ra                  ; get Ymax
            shr                         ; divide by 2
            phi     r7                  ; set origin at Ymax/2
            glo     ra                  ; get Xmax
            shr                         ; divide by 2
            adi     7                   ; add minor circle radius  
            plo     r7                  ; Xmax/2 + r' for yang               
            ldi     7
            plo     r8                  ; with minor radius r' = 7
            
            ldi     GFX_SET             ; set color to white 
            phi     r9

            call    gfx_fill_circle     ; draw yang

            ldi     GFX_CLEAR           ; set color to black
            phi     r9
            ldi     2
            plo     r8                  ; set radius r'' = 2
            
            call    gfx_draw_circle     ; draw small dark circle in yang 

            ldi     GFX_SET             ; set color to white 
            phi     r9

            ghi     ra                  ; get Ymax
            shr                         ; divide by 2
            phi     r7                  ; set origin y = Ymax/2
            glo     ra                  ; get Xmax
            shr                         ; divide by 2
            plo     r7                  ; set origin x = Xmax/2
            ldi     15                  
            plo     r8                  ; set radius = 15 pixels

            ldi     SE_QUAD | SW_QUAD   ; draw an upwards semicircle
            phi     r8                  

            call    gfx_draw_arc        ; at bottom of circle for yin
            lbdf  error

            ;---- update display until input button is pressed
show_it:    call  pixie_begin_display
            von
wait:       bn4   wait  
            voff
            call  pixie_end_display
            
done:       clc   
            return

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: tao [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
            
error:      call o_inmsg
            db  'Error drawing symbol.',10,13,0
            abend                       ; return to Elf/OS with error code
                        
            ;---- rotation flag
rotate:     db 0            
            
            end   start
