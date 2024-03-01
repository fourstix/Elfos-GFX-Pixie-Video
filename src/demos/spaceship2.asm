;-------------------------------------------------------------------------------
; Display the classic Cosmac Elf Spaceship screen on a video display 
; connected to an RCA CDP1861 Pixie Video chip or equivalent.  
;
; Copyright 2024 by Gaston Williams
;
; Based on the original Elf Pixie Graphic Program
; Written by Joseph A Weisbecker
; Published in Popular Electronics, July 1979, pages 41-46
; Copyright Joseph A Weisbecker 1976-1979
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
            ; Draw spaceship image as bitmap that fills display
            ;-------------------------------------------------------------------
            load   rf, spaceship        ; point to spaceship data
            load  r8, $2040             ; bitmap h = 32, w = 64
            load  r7, $0000
            call  gfx_draw_bitmap       ; draw bitmap at origin
            lbdf  error
            
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

            ;---- rotation flag
rotate:     db 0            
            
            ; ***************************************
            ; Data for spaceship graphic image
            ; ***************************************


spaceship:  db $90, $B1, $B2, $B3, $B4, $F8, $2D, $A3
            db $F8, $3F, $A2, $F8, $11, $A1, $D3, $72
            db $70, $22, $78, $22, $52, $C4, $C4, $C4 
            db $F8, $00, $B0, $F8, $00, $A0, $80, $E2 
            db $E2, $20, $A0, $E2, $20, $A0, $E2, $20
            db $A0, $3C, $1E, $30, $0F, $E2, $69, $3F
            db $2F, $6C, $A4, $37, $33, $3F, $35, $6C
            db $54, $14, $30, $33, $00, $00, $00, $00                     
            db $00, $00, $00, $00, $00, $00, $00, $00
            db $00, $00, $00, $00, $00, $00, $00, $00
            db $7B, $DE, $DB, $DE, $00, $00, $00, $00
            db $4A, $50, $DA, $52, $00, $00, $00, $00
            db $42, $5E, $AB, $D0, $00, $00, $00, $00
            db $4A, $42, $8A, $52, $00, $00, $00, $00
            db $7B, $DE, $8A, $5E, $00, $00, $00, $00
            db $00, $00, $00, $00, $00, $00, $00, $00
            db $00, $00, $00, $00, $00, $00, $07, $E0
            db $00, $00, $00, $00, $FF, $FF, $FF, $FF
            db $00, $06, $00, $01, $00, $00, $00, $01
            db $00, $7F, $E0, $01, $00, $00, $00, $02
            db $7F, $C0, $3F, $E0, $FC, $FF, $FF, $FE
            db $40, $0F, $00, $10, $04, $80, $00, $00
            db $7F, $C0, $3F, $E0, $04, $80, $00, $00
            db $00, $3F, $D0, $40, $04, $80, $00, $00
            db $00, $0F, $08, $20, $04, $80, $7A, $1E
            db $00, $00, $07, $90, $04, $80, $42, $10
            db $00, $00, $18, $7F, $FC, $F0, $72, $1C
            db $00, $00, $30, $00, $00, $10, $42, $10
            db $00, $00, $73, $FC, $00, $10, $7B, $D0
            db $00, $00, $30, $00, $3F, $F0, $00, $00
            db $00, $00, $18, $0F, $C0, $00, $00, $00
            db $00, $00, $07, $F0, $00, $00, $00, $00

            end   start
