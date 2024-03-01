;-------------------------------------------------------------------------------
; Display a set of filled rectangles on a video display connected to an 
; RCA CDP1861 Pixie Video chip or equivalent.  
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

good:       call  pixie_clear_buffer    ; clear out buffer


            ldi    GFX_SET              ; set color to draw
            phi    r9       

            load   rf, rotate           ; set rotation flag
            ldn    rf
            plo    r9

            shr                         ; check lsb to see if landscape or portrait
            lbdf    portrait            ; r=1 or r=3, portrait

landscape:  load   r7, $0000            ; draw first block 
            load   r8, $3F3F             
            call   gfx_fill_rect
            lbdf   error
            
            ldi    GFX_CLEAR            ; set color to clear 
            phi    r9

            load   r7, $0808            ; clear a block inside
            load   r8, $3030            
            call   gfx_fill_rect
            lbdf   error

            ldi    GFX_SET              ; set color to draw
            phi    r9            

            load   r7, $1010            ; draw last block
            load   r8, $2020             
            call   gfx_fill_rect
            lbdf   error
            
            
            ldi    GFX_CLEAR            ; set color to draw
            phi    r9            

            load  r7, $1818           ; draw last rectangle
            load  r8, $1010             
            call  gfx_draw_rect
            lbdf  error

            load  r7, $2F18             ; draw notch at bottom
            load  r8, $1010             
            call  gfx_fill_rect
            lbdf  error

            lbr    show_it

portrait:   load  r7, $0000             ; draw rectangle inside first
            load  r8, $3F3F             
            call  gfx_fill_rect
            lbdf  error

            ldi    GFX_CLEAR            ; set color to clear 
            phi    r9

            load  r7, $0808             ; draw rectangle inside second
            load  r8, $3030             
            call  gfx_fill_rect
            lbdf  error
            
            ldi    GFX_SET              ; set color to draw
            phi    r9            
            
            load  r7, $1010             ; draw next last rectangle
            load  r8, $2020            
            call  gfx_fill_rect
            lbdf  error

            ldi    GFX_CLEAR            ; set color to draw
            phi    r9            

            load  r7, $1818             ; draw rectangle at bottom
            load  r8, $1010             
            call  gfx_fill_rect
            lbdf  error

            load  r7, $2F18             ; draw notch at bottom
            load  r8, $1010             
            call  gfx_fill_rect
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
            db    'Usage: blocks [-r n, where n = 0|1|2|3]',10,13
            db    'Option: -r n, rotate by n*90 degrees counter-clockwise',10,13,0
            abend                       ; and return to os            
                                    
error:      call o_inmsg
            db 'Error drawing blocks.',10,13,0
            abend                       ; return to Elf/OS with an error code
      
            ;---- rotation flag
rotate:     db 0                                    
            
            end   start
