;-------------------------------------------------------------------------------
; Display a text background styles on a video display 
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

            load    rf, rotate          ; set rotation flag
            ldn     rf
            plo     r9

            
            ;---- set up background pattern
            load  r7, $0000             ; draw first block 
            load  r8, $4040
            
            ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            load  r7, $0808             ; clear a block inside
            load  r8, $3030             
            ldi   GFX_CLEAR
            phi   r9
            call  gfx_fill_rect
            lbdf  error


            load  r7, $1010             ; draw another block
            load  r8, $2020
            ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            load  r7, $1818             ; clear another block inside
            load  r8, $1010             
            ldi   GFX_CLEAR
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            
            ;---- draw overlay text
            load  r7, $0800             ;---- Set R7 to overlap block
            ldi   GFX_TXT_OVERLAY       ; background shows through, text inverts bits
            phi   r9              
            ldi   0                     ; set for no character scaling 
            phi   r8
            load  rf, overlay
            call  pixie_print_string

            ;---- draw text with background cleared, text wraps
            load  r7, $180C             ;---- Set R7 near middle of line 44
            ldi   GFX_TXT_NORMAL        ; background cleared, text set
            phi   r9    
            ldi   0                     ; set for no character scaling 
            phi   r8
            load  rf, normal            ;---- set string buffer
            
            call  pixie_print_string


            ;---- draw text with background set
            load  r7, $2000             ;---- Set R7 at beginning of line 26
            ldi   GFX_TXT_INVERSE       ; background set, text cleared
            phi   r9    
            ldi   0                     ; set for no character scaling 
            phi   r8
            load  rf, inverse           ;---- set string buffer
            
            call  pixie_print_string
            
            ;---- update display until input button is pressed
show_it:    call  pixie_begin_display
            von
wait:       bn4   wait  
            voff
            call  pixie_end_display

            clc
            return                      ; return to Elf/OS

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: textbg [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
                      
error:      call o_inmsg
            db 'Error drawing string.',10,13,0
            abend                       ; return to Elf/OS with an error code

            ;---- rotation flag
rotate:     db 0            
            
overlay:    db 'Overlay',0
normal:     db 'Normal',0            
inverse:    db 'Inverse',0                            
            end   start
