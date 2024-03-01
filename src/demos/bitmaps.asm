;-------------------------------------------------------------------------------
; Display a set of bitmaps on a video display connected to an RCA CDP1861
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

main:       lda   ra                    ; move past any spaces
            smi   ' '
            lbz   main
            dec   ra                    ; move back to non-space character
            ldn   ra                    ; get byte
            lbz   good                  ; jump if no argument given

            smi   '-'                 ; was it a dash to indicate option?
            lbnz  usage               ; if not a dash, show error  
            inc   ra                  ; move to next character
            lda   ra                  ; check for fill option 
            smi   'r'
            lbnz  usage               ; bad option, show usage message
       
sp_1:       lda   ra                  ; move past any spaces
            smi   ' '
            lbz   sp_1

            dec   ra                  ; move back to non-space character
            ldn   ra                  ; get rotation value
            smi   '0'                 ; should be 0, 1, 2 or 3
            lbnf  usage               ; if less than zero, show usage message
            ldn   ra                  ; check again
            smi   '4'                 ; should be 0, 1, 2 or 3
            lbdf  usage               ; if greater than 3, show usage message
            load  rf, rotate          ; point rf to rotate flag
            ldn   ra                  ; get rotation paramater
            smi   '0'                 ; convert character to digit value
            str   rf                  ; save as rotate flag

good:       call  pixie_clear_buffer   ; clear out buffer

            ldi   GFX_SET             ; set color 
            phi   r9
            
            load  rf, rotate          ; set rotation flag
            ldn   rf
            plo   r9

                                  
            load  rf, test_bmp        ; point to bitmap buffer             
            load  r8, $1010           ; bitmap h = 16, w = 16
            load  r7, $0004
            call  gfx_draw_bitmap     ; draw bitmap at random location
            lbdf  error

            load  rf, test_bmp        ; point to bitmap buffer             
            load  r8, $1010           ; bitmap h = 16, w = 16
            load  r7, $2010
            call  gfx_draw_bitmap     ; draw bitmap at random location
            lbdf  error

            load  rf, test_bmp        ; point to bitmap buffer             
            load  r8, $1010           ; bitmap h = 16, w = 16
            load  r7, $101C
            call  gfx_draw_bitmap     ; draw bitmap at random location
            lbdf  error

            load  rf, test_bmp        ; point to bitmap buffer             
            load  r8, $1010           ; bitmap h = 16, w = 16
            load  r7, $282F
            call  gfx_draw_bitmap     ; draw bitmap at random location
            lbdf  error
            lbr   show_it

            ;---- update display until input button is pressed
show_it:    call  pixie_begin_display
            von
wait:       bn4   wait  
            voff
            call  pixie_end_display

            call o_inmsg
                db 'Done.',10,13,0
            clc
            return                      ; return to Elf/OS

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: bitmaps [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
                      
error:      call o_inmsg
            db 'Error drawing bitmap.',10,13,0
            abend                       ; return to Elf/OS with an error code
               
;----- Adafruit flower
test_bmp:   db $00, $C0, $01, $C0, $01, $C0, $03, $E0
            db $F3, $E0, $FE, $F8, $7E, $FF, $33, $9F
            db $1F, $FC, $0D, $70, $1B, $A0, $3F, $E0
            db $3F, $F0, $7C, $F0, $70, $70, $30, $30
            
          ;---- rotation flag
rotate:     db 0            
            
            end   start
