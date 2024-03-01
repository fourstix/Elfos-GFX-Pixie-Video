;-------------------------------------------------------------------------------
; Display a set of pixels on a video display connected to an RCA CDP1861
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


; ************************************************************
; This block generates the Execution header for a stand-alone
; program. It begins 6 bytes before the program start.
; ************************************************************

        org     2000h          ; Program code starts at 2000
start:      br      main

            ever                ; build and date 
            db    'Copyright 2024 by Gaston Williams',0

           ; Main code starts here, check provided argument

main:       lda     ra                  ; move past any spaces
            smi     ' '
            lbz     main
            dec     ra                  ; move back to non-space character
            ldn     ra                  ; get byte
            lbz     draw_it             ; jump if no argument given

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
            
draw_it:    call    pixie_clear_buffer  ; clear out buffer

            load    rf, rotate          ; set rotation flag
            ldn     rf
            plo     r9
            
            ldi     GFX_SET             ; set color 
            phi     r9
            
            load    r7, $0000
            call    gfx_draw_pixel
            lbdf    error
          
            load    r7, $0A01
            call    gfx_draw_pixel
            lbdf    error


            load    r7, $0A02
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $0A03
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $0A04
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $050A
            call    gfx_draw_pixel
            lbdf    error
          
            load    r7, $060A
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $070A
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $080A
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $090A
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $1010
            call    gfx_draw_pixel
            lbdf    error
          
            load    r7, $1111
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $1212
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $1313
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $1414
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $1515
            call    gfx_draw_pixel
            lbdf    error
        
            load    r7, $1416
            call    gfx_draw_pixel
            lbdf    error


            load    r7, $1317
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $1218
            call    gfx_draw_pixel
            lbdf    error

            load    r7, $1119
            call    gfx_draw_pixel
            lbdf    error

            ;---- update display until input button is pressed
show_it:    call    pixie_begin_display              
            von                 ; Turn on Video
wait:       bn4     wait        ; wait for Input pressed to exit
            voff            
            call    pixie_end_display
            
            clc
            return              ; return to Elf/OS
         
usage:      call  o_inmsg       ; otherwise display usage message
            db    'Usage: pixels [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend               ; and return to os with error
           
error:      call o_inmsg
            db 'Error setting pixel.',10,13,0
            abend
   
            ;---- rotation flag
rotate:     db 0            
           
        end   start
