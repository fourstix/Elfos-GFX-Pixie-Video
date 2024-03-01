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
            extrn   pixie_begin_display
            extrn   pixie_end_display
            extrn   pixie_fill_buffer
            extrn   pixie_clear_buffer
            extrn   pixie_print_char
            extrn   pixie_print_string
