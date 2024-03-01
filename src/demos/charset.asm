;-------------------------------------------------------------------------------
; Display a characters on a video display connected
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
            db    'Copyright 2023 by Gaston Williams',0


            ; Main code starts here, check provided argument

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given

            smi   '-'                   ; was it a dash to indicate option?
            lbnz  usage                 ; if not a dash, show error  
            inc   ra                    ; move to next character
            lda   ra                    ; check for fill option 
            smi   'r'
            lbnz  usage                 ; bad option, show usage message
       
sp_1:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   sp_1

            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get rotation value
            smi   '0'                   ; should be 0, 1, 2 or 3
            lbnf  usage                 ; if less than zero, show usage message
            ldn   ra                    ; check again
            smi   '4'                   ; should be 0, 1, 2 or 3
            lbdf  usage                 ; if greater than 3, show usage message
            load  rf, rotate            ; point rf to rotate flag
            ldn   ra                    ; get rotation paramater
            smi   '0'                   ; convert character to digit value
            str   rf                    ; save as rotate flag

good:       call  pixie_clear_buffer     ; clear out buffer
            lbdf  error

            ldi   48                    ; First half of 96 printable characters
            plo   rc                    ; save in counter
            
            ;---- draw text
            ldi   GFX_TXT_NORMAL       ; clear background
            phi   r9    
          
            load   rf, rotate           ; set rotation flag
            ldn    rf
            plo    r9
          
            ldi   0                     ; set for no scaling 
            phi   r8

            load  r7, 0                 ; Set cursor at origin (0,0)
            ldi   ' '                   ; set up first character
            plo   r8

draw_ch1:   glo   rc                    ; get counter
            lbz   show_1                ; when done, show display
                          
            call  pixie_print_char      ; draw character   

            inc   r8                    ; go to next character
            dec   rc                    ; count down
            lbr   draw_ch1              ; keep going until first set of chars drawn
            
            ;---- update display until input button is pressed
show_1:     call  pixie_begin_display
            von
wait1:      bn4   wait1  
            voff                        ; turn off video for next update

            call  pixie_clear_buffer    ; clear out buffer
            lbdf  error

            ldi   48                    ; Second half of 96 printable characters
            plo   rc                    ; save in counter
            
            ;---- leave all other parameters alone, but reset cursor
            load  r7, 0                 ;---- Set cursor at origin (0,0)

draw_ch2:   glo   rc                    ; get counter
            lbz   show_2                ; when done, show display
                          
            call  pixie_print_char       ; draw character   

            inc   r8                    ; go to next character
            dec   rc                    ; count down
            lbr   draw_ch2              ; keep going until second set drawn
            
            ;---- update display until input button is pressed
show_2:     von                         ; turn on video
wait2:      bn4   wait2  
            voff                        ; turn off video
            call  pixie_end_display     ; all done, reset interrupt register

            clc
            return                      ; return to Elf/OS

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: charset [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter-clockwise',10,13,0
            abend                       ; and return to os            
                      
error:      call o_inmsg
            db 'Error drawing character set.',10,13,0
            abend                       ; return to Elf/OS with an error code
              
          ;---- rotation flag
rotate:     db 0            
                      
            end   start
