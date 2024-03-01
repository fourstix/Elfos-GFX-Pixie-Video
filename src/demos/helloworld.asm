;-------------------------------------------------------------------------------
; Display greetings text in different sizes on a video display
; connected to an RCA CDP1861 Pixie Video chip or equivalent.  
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
            db    'Copyright 2024 by Gaston Williams',0


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
            
            ;---- draw text with background cleared
            
            load   rf, rotate           ; set rotation flag
            ldn    rf
            plo    r9

            ldi   GFX_TXT_NORMAL        ; background cleared
            phi   r9    
            ldi   GFX_TXT_SMALL         ; normal sized text
            phi   r8

            load  rf, small_1           ; set string buffer
            
            load  r7, $0C00             ; Set cursor to start of line 12

            call  pixie_print_string    ; draw character  

            load  rf, small_2           ; set string buffer
            
            load  r7, $1400             ; Set cursor to start of line 20

            call  pixie_print_string    ; draw character  
                                   
            ;---- update display until input button is pressed
            call  pixie_begin_display   ; set up interrupts  
            von                         ; video on
wait1:      bn4   wait1                 ; wait for input button down
            b4    $                     ; wait for input button up
            voff                        ; video off during update
            
            call  pixie_clear_buffer    ; clear out buffer
            lbdf  error
            
            ldi   GFX_TXT_NORMAL        ; background cleared
            phi   r9    
            ldi   GFX_TXT_MEDIUM        ; medium sized text
            phi   r8

            load  rf, medium         ; set string buffer
            
            load  r7, $0000             ; Set cursor to home

            call  pixie_print_string    ; draw character  

            ;---- update display until input button is pressed
            von                         ; video on
wait2:      bn4   wait2  
            b4    $                     ; wait for input button up
            voff                        ; video off during update

            call  pixie_clear_buffer    ; clear out buffer
            lbdf  error
            
            ldi   GFX_TXT_NORMAL        ; background cleared
            phi   r9    
            ldi   GFX_TXT_LARGE         ; medium sized text
            phi   r8

            load  rf, large         ; set string buffer
            
            load  r7, $0000             ; Set cursor to home

            call  pixie_print_string    ; draw character  

            ;---- update display until input button is pressed
            von                         ; turn on video
wait3:      bn4   wait3  
            b4    $                     ; wait for input button up
            voff                        ; turn off video
            
            call  pixie_clear_buffer    ; clear out buffer
            lbdf  error
            
            ldi   GFX_TXT_NORMAL        ; background cleared
            phi   r9    
            ldi   GFX_TXT_HUGE          ; medium sized text
            phi   r8

            load  rf, huge              ; set string buffer
            
            load  r7, $0000             ; Set cursor to home

            call  pixie_print_string    ; draw character  

            ;---- update display until input button is pressed
            von                         ; turn on video
wait4:      bn4   wait4  
            b4    $                     ; wait for input button up
            voff            
            call  pixie_end_display     ; reset interrupts
            
            clc
            return

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: helloworld [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter-clockwise',10,13,0
            abend                       ; and return to os            
                      
error:      call o_inmsg
            db 'Error drawing text.',10,13,0
            voff                        ; turn off video
            call  pixie_end_display     ; reset interrupts
            abend
            
small_1:    db 'Hello,',0 
small_2:    db 'World!',0
medium:     db 'Hello',0     
large:      db 'Hi',0            
huge:       db '?',0     
            
            ;---- rotation flag
rotate:     db 0            
                           
            end   start
