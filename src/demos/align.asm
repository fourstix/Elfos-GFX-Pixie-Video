;-------------------------------------------------------------------------------
; Display a set of rectangles and lines aligned on a video display 
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

            ;-------------------------------------------------------------------
            ; Draw vertical and horizontal lines aligned with block
            ;-------------------------------------------------------------------

            ;---- set up top line
            load  r7, $0A04             ; draw first line (length 6)
            load  r8, $0A09             
            ldi   GFX_SET
            phi   r9
            call  gfx_draw_line
            lbdf  error


            ;---- set up left line
            load  r7, $0C02             ; draw second line (length 8)
            load  r8, $1302             
            ldi   GFX_SET
            phi   r9
            call  gfx_draw_line
            lbdf  error

            ;---- set up bottom line
            load  r7, $1504             ; draw third line (length 6)
            load  r8, $1509             
            ldi   GFX_SET
            phi   r9
            call  gfx_draw_line
            lbdf  error

            ;---- set up right line
            load  r7, $0C0B             ; draw fourth line (length 8)
            load  r8, $130B             
            ldi   GFX_SET
            phi   r9
            call  gfx_draw_line
            lbdf  error
            
            load  r7, $0C04             ; draw filled rectangle inside
            load  r8, $0806             
            ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            ;-------------------------------------------------------------------
            ; Draw vertical and horizontal lines aligned with rectangle
            ;-------------------------------------------------------------------

            ;---- set up top line
            load  r7, $1A14             ; draw first line (length 6)
            load  r8, $1A19             
            ldi   GFX_SET
            phi   r9
            call  gfx_draw_line
            lbdf  error


            ;---- set up left line
            load  r7, $1C12             ; draw second line (length 8)
            load  r8, $2312             
            ldi   GFX_SET
            phi   r9
            call  gfx_draw_line
            lbdf  error

            ;---- set up bottom line
            load  r7, $2514             ; draw third line (length 6)
            load  r8, $2519             
            ldi   GFX_SET
            phi   r9
            call  gfx_draw_line
            lbdf  error

            ;---- set up right line
            load  r7, $1C1B             ; draw fourth line (length 8)
            load  r8, $231B             
            ldi   GFX_SET
            phi   r9
            call  gfx_draw_line
            lbdf  error
            
            load  r7, $1C14             ; draw rectangle inside
            load  r8, $0806             
            ldi   GFX_SET
            phi   r9
            call  gfx_draw_rect
            lbdf  error

            ; draw a few blocks
            load  r7, $0C20
            load  r8, $0101
            ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error
            

            ; draw a few blocks
            load  r7, $0C24
            load  r8, $0202
            ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            ; draw a few blocks
            load  r7, $0C2C
            load  r8, $0404
            ldi   GFX_SET
            phi   r9
            call  gfx_fill_rect
            lbdf  error

            ;---- draw inverse text wrapping around with background set
            
;            load  r7, $2A00             ;---- Set R7 at beginning of line 26
;            ldi   GFX_TXT_INVERSE       ; background set, text cleared
;            phi   r9    
;            ldi   0                     ; set for no character scaling 
;            phi   r8

;            load  rf, tst_text          ;---- set string buffer
            
;            call  oled_print_string
            
            ;---- update display until input button is pressed
show_it:    call  pixie_begin_display
            von
wait:       bn4   wait  
            voff
            call  pixie_end_display

            clc   
            return

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: align [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
                      
error:      call o_inmsg
            db 'Error drawing string.',10,13,0
            abend                       ; return to Elf/OS with an error code
            
tst_text:   db 'This text wraps around!',0

            ;---- rotation flag
rotate:     db 0            

            end   start
