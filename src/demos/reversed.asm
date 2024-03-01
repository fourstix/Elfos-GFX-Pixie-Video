;-------------------------------------------------------------------------------
; Display a set of reversed (black on white) lines on a video display connected
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

            org   2000h
start:      br    main


            ; Build information
            ever
            db      'Copyright 2024 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   draw_it               ; jump if no argument given

good:       smi     '-'                 ; was it a dash to indicate option?
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

draw_it:    call  pixie_fill_buffer     ; fill buffer for all white background
            
            ldi   GFX_CLEAR             ; set color to clear line
            phi   r9    
            
            load  rf, rotate            ; set rotation flag
            ldn   rf
            plo   r9
                        
            call  gfx_dimensions        ; get Ymax and Xmax values in ra         

            ldi   0                     ; draw top border
            plo   r7
            phi   r7                    ; origin = (0,0)
            phi   r8                    
            glo   ra                    ; get Xmax    
            plo   r8                    ; endpoint = (Xmax,0)
            
            call  gfx_draw_line
            lbdf  error
                    
                        
            ldi   0                     ; draw left border
            plo   r7
            phi   r7                    ; origin = (0,0)
            plo   r8
            ghi   ra                    ; get Ymax
            phi   r8                    ; endpoint = (0,Ymax)
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw right border
            phi   r7
            glo   ra
            plo   r7                    ; origin = (Xmax, 0)
            plo   r8
            ghi   ra
            phi   r8                    ; endpint = (Xmax, Ymax)          
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw bottom border
            plo   r7
            ghi   ra
            phi   r7                    ; origin = (0, Ymax)
            phi   r8
            glo   ra
            plo   r8                    ; endpoint = (Xmax, Ymax)            
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw diagonal
            plo   r7
            phi   r7                    ; origin at (0,0)
            glo   ra
            plo   r8
            ghi   ra
            phi   r8                    ; endpoint at (Xmax, Ymax)
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw second diagonal
            phi   r7
            plo   r8
            glo   ra
            plo   r7                    ; origin at (Xmax, 0)
            ghi   ra
            phi   r8                    ; endpoint at (0, Ymax)
            call  gfx_draw_line
            lbdf  error

            ldi   0                     ; draw vertical line at midpoint of display
            phi   r7
            glo   ra                    ; get Xmax
            shr                         ; divide by 2 for midpoint
            plo   r7                    ; origin at (Xmax/2, 0)
            plo   r8
            ghi   ra
            phi   r8                    ; endpoint at (Xmax/2, Ymax)
            call  gfx_draw_line
            lbdf  error

            
            ldi   0                     ; draw horizontal line at midpoint of display
            plo   r7
            ghi   ra                    ; get Ymax
            shr                         ; divide by 2 for midpoint
            phi   r7                    ; origin at (0, Ymax/2)
            phi   r8
            glo   ra                    ; get Xmax
            plo   r8                    ; endpoint at (Xmax, Ymax/2)
            call  gfx_draw_line
            lbdf  error

            glo   ra                    ; draw horizontal line in upper part of display
            shr                         ; divide Xmax by 4
            shr            
            plo   r7     
            str   r2                    ; save in M(X)   
            ghi   ra                    ; get Ymax
            shr                         ; divide Ymax by 4 for upper fourth
            shr                         ; 
            phi   r7                    ; origin at (Xmax/4, Ymax/4)
            phi   r8
            glo   ra                    ; get Xmax
            sm                          ; subtract Xmax/4
            plo   r8                    ; endpoint at (3*Xmax/4, Ymax/4)
            call  gfx_draw_line
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
            db    'Usage: lines [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
            
error:      call o_inmsg
            db 'Error drawing line.',10,13,0
            abend

            ;---- rotation flag
rotate:     db 0            
            
            end   start
