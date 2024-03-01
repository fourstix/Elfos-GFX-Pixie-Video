;-------------------------------------------------------------------------------
; pixie - a library for basic graphics functions useful 
; for a video display connected to an RCA CDP1861 Pixie Video 
; chip or equivalent.  These routines operate on pixels
; in a buffer used by the display.
;
; Copyright 2024 by Gaston Williams
;
; Based on code from Adafruit_GFX library
; Written by Limor Fried/Ladyada for Adafruit Industries  
; Copyright 2012 by Adafruit Industries
; Please see https://learn.adafruit.com/adafruit-gfx-graphics-library for more info
;-------------------------------------------------------------------------------
#include    ../include/ops.inc
#include    ../include/bios.inc
#include    ../include/kernel.inc
#include    ../include/gfx_display.inc
#include    ../include/pixie_def.inc
            
;---------------------------------------------------------
; Public routine - This routine updates the display 
;---------------------------------------------------------

;-------------------------------------------------------
; Name: pixie_begin_display
;
; Initiailize the Pixie Video display.
; Setup interrupt handler and enable interrupts.
;
; Parameters: (None)
;
; Returns: DF = 1 if error, 0 if no error
;-------------------------------------------------------
            proc    pixie_begin_display

            ;---- set r1 to point to interrupt
init:       ldi     high disp_int       ; set interrupt address
            phi     r1                  ; Set up interrupt register
            ldi     low disp_int        ; set interrupt address
            plo     r1                  ; to point to interrupt handler

            sei                         ; enable interrupts
            return

#ifdef PIXIE_LO
;-------------------------------------
; Low Resolution interrupt handler 
; (32 x 64)
;-------------------------------------
iret:       ldxa                ; restore D,
            ret                 ; return point X, P back to original locations
disp_int:   dec     r2          ; move stack pointer
            sav                 ; save T register
            dec     r2          ; move stack pointer
            str     r2          ; Store D onto stack
            nop                 ; 3 nops = 9 cycles to make interrupt
            nop                 ; routine exactly the 29 instruction cycles
            nop                 ; required for 1861 timing

            ;-----  point dma register to display buffer
            ldi     high pixie_display_buffer            
            phi     r0             
            ldi     low pixie_display_buffer            
            plo     r0
int_loop:   glo     r0          ; D = r0.0
            sex     r2          ; X = 2            
                      ; <----- 8 DMA cycles occur here (R0+8)
            sex     r2          ; there is time for exactly 6 instruction cycles
            dec     r0          ; utilized here by 3 two-cycle instructions
            plo     r0          ; in between dma requests
                      ; <----- 8 DMA cycles occur here (R0+8)
            sex     r2
            dec     r0
            plo     r0
                      ; <----- 8 DMA cycles occur here (R0+8)
            sex     r2
            dec     r0
            plo     r0
                      ; <----- 8 DMA cycles occur here (R0+8)
            bn1     int_loop    ; go to refresh if EF1 false
            br      iret        ; return if EF1 true (end of frame)
#else
#ifdef PIXIE_HI
;-------------------------------------
; High Resolution interrupt handler 
; (128 x 64)
;-------------------------------------
iret:       ldxa				  ; restore D
            ret				    ; set x,p
disp_int:	  nop
            dec  r2
            sav				    ; put T on stack
            dec  r2
            str  r2				; put D on stack
            sex  r2				; 2 cycles  
            sex  r2
            ldi  high pixie_display_buffer
            phi  r0
            ldi  low  pixie_display_buffer
            plo  r0
            br   iret			; end of display
#else
;-------------------------------------
; Medium Resolution interrupt handler 
; (64 x 64)
;-------------------------------------
iret:       ldxa                ; restore D
            ret                 ; point X, P back to original locations
            
disp_int:   nop                 ; nop to sync with display
            dec     r2          ; move stack pointer
            sav                 ; save T register
            dec     r2          ; move stack pointer
            str     r2          ; save D onto stack
            ;-----  point dma register to display buffer
            ldi     high pixie_display_buffer            
            phi     r0             
            ldi     low pixie_display_buffer            
            plo     r0
            
            ;----- nop cycles more required for 1861 timing  
            nop                 ; nops to make interrupt routine
            nop                 ; exactly the 29 instruction cycles                  
            sex     r2          ;  before dma occurs         
int_Loop:   glo     r0          ; set r0 to dma line
            ; <----- 8 DMA cycles occur here (R0+8)
            sex     r2          ; 6 cycles after dma           
            dec     r0          ; restore R0.1 if past page
            plo     r0
            ; <----- 8 DMA cycles occur here (R0+8)
            sex     r2          ; 6 cycles after dma
            bn1     int_loop    ; loop for 60 lines
            
int_ef1:    glo     r0          ; set r0 to dma line
            ; <----- 8 DMA cycles occur here (line 60)
            sex     r2          ; 6 cycles after dma
            dec     r0
            plo     r0
            ; <----- 8 DMA cycles occur here (line 61)
            sex     r2          ; nop           
            b1      int_ef1     ; loop for last 4 lines
            br      iret        ; display interrupt done
#endif
#endif
            endp
