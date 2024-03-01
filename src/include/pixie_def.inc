#ifdef PIXIE_LO
;-------------------------------------
; Low Resolution display constants 
;-------------------------------------
#define DISP_WIDTH    64
#define DISP_HEIGHT   32
#define BUFFER_SIZE  256

#else
#ifdef PIXIE_HI
;-------------------------------------
; High Resolution display constants 
;-------------------------------------
#define DISP_WIDTH    64
#define DISP_HEIGHT  128
#define BUFFER_SIZE 1024

#else
;-------------------------------------
; Medium Resolution display constants 
; (default) 
;-------------------------------------
#define DISP_WIDTH    64
#define DISP_HEIGHT   64
#define BUFFER_SIZE  512
#endif
#endif

;-----------------------------------
; Pixel constants
;-----------------------------------
#define GFX_SET     $01
#define GFX_CLEAR   $00
#define GFX_INVERT  $80

;-----------------------------------
; Public Text color style constants
;-----------------------------------
#define GFX_TXT_NORMAL    $01
#define GFX_TXT_INVERSE   $00
#define GFX_TXT_OVERLAY   $80


;-----------------------------------
; Public Text size constants
;-----------------------------------
#define GFX_TXT_SMALL    $00
#define GFX_TXT_MEDIUM   $02
#define GFX_TXT_LARGE    $04
#define GFX_TXT_HUGE     $08


;-------------------------------------------------------------------------------
; OLED routines used by other routines
;-------------------------------------------------------------------------------
            extrn   pixie_display_buffer            
            extrn   pixie_display_ptr
            extrn   pixie_write_pixel
            extrn   pixie_fill_buffer
            extrn   pixie_clear_buffer
            extrn   pixie_fast_v_line
            extrn   pixie_fast_h_line
            extrn   pixie_begin_display
            extrn   pixie_end_display
            extrn   pixie_fill_bg
            extrn   pixie_print_char
