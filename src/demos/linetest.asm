;-------------------------------------------------------------------------------
; Draw various lines on a video display connected to an RCA CDP1861
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
            lbz   show_it               ; jump if no argument given

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

show_it:    call  pixie_clear_buffer     ; clear out buffer
            lbdf  error

            ldi    GFX_SET              ; set color 
            phi    r9            
            
            load    rf, rotate          ; set rotation flag
            ldn     rf
            plo     r9


            ;---------- horizontal line test            
            load  r7, $0010             ; draw along top border
            load  r8, $0030             
            call  gfx_draw_line

            lbnf  test_h2
            call  o_inmsg
            db    'H1 Error',10,13,0
            lbr  error
            
            
            ;---------- horizontal line test (r7, r8 need swapping)
test_h2:    load  r7, $0630             ; draw horizontal line from (32,6)
            load  r8, $0620             ; to endpoint of (48,6)
            call  gfx_draw_line

            lbnf  test_h3
            call  o_inmsg
            db    'H2 Error',10,13,0
            lbr  error

            ;---------- horizontal line test (boundaries)
test_h3:    load  r7, $2000             ; draw horizontal line from (0,32)
            load  r8, $203F             ; to endpoint of (63,32)
            call  gfx_draw_line

            lbnf  test_v1
            call  o_inmsg
            db    'H3 Error',10,13,0
            lbr  error

            ;---------- vertical line test
test_v1:    load  r7, $2030             ; draw vertical line from (32, 48)
            load  r8, $0030             ; to endpoint of (0,48)
            call  gfx_draw_line

            lbnf  test_v2
            call  o_inmsg
            db    'V1 Error',10,13,0
            lbr  error

            ;---------- vertical line test (r7, r8 need swapping)
test_v2:    load  r7, $0020             ; draw vertical line from (48,00)
            load  r8, $2020             ; to endpoint of (48,32)
            call  gfx_draw_line

            lbnf  test_v3
            call  o_inmsg
            db    'V2 Error',10,13,0
            lbr  error

            ;---------- vertical line test
test_v3:    load  r7, $0038             ; draw vertical line from (48,0)
            load  r8, $3F38             ; to endpoint of (48,63)
            call  gfx_draw_line

            lbnf  test_s1
            call  o_inmsg
            db    'V3 Error',10,13,0
            lbr  error
            
            ;----------  sloping line test (flat, positive slope)
test_s1:    load  r7, $2213
            load  r8, $2A28
            call  gfx_draw_line

            lbnf  test_s2
            call  o_inmsg
            db    'S1 Error',10,13,0
            lbr  error

            
            ;----------  sloping line test (flat, negative slope)
test_s2:    load  r7, $3833
            load  r8, $3038
            call  gfx_draw_line

            lbnf  test_s3
            call  o_inmsg
            db    'S2 Error',10,13,0
            lbr  error

            ;----------  sloping line test (flat, positive, needs swap)
test_s3:    load  r7, $1A18
            load  r8, $1203
            call  gfx_draw_line

            lbnf  test_s4
            call  o_inmsg
            db    'S3 Error',10,13,0
            lbr  error

            ;----------  sloping line test (steep, positive slope)
test_s4:    load  r7, $2213
            load  r8, $3218
            call  gfx_draw_line

            lbnf  test_s5
            call  o_inmsg
            db    'S4 Error',10,13,0
            lbr  error

            ;----------  sloping line test (steep, negative slope)
test_s5:    load  r7, $3F30
            load  r8, $1B38
            call  gfx_draw_line

            lbnf  test_done
            call  o_inmsg
            db    'S5 Error',10,13,0
            lbr  error

            ;---- update display until input button is pressed
test_done:  call  pixie_begin_display
            von
wait:       bn4   wait  
            voff
            call  pixie_end_display

            clc   
            return

usage:      call  o_inmsg               ; otherwise display usage message
            db    'Usage: linetest [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter clockwise',10,13,0
            abend                       ; and return to os
            
error:      call o_inmsg
            db 'Error drawing line',10,13,0
            abend                       ; return to Elf/OS with error code
            
            ;---- rotation flag
rotate:     db 0            
            
            end   start
