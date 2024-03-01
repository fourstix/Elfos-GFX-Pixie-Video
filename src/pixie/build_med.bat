[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_display_buffer.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_display_ptr.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_clear_buffer.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_fill_buffer.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_write_pixel.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_begin_display.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_end_display.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_fast_h_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_fast_v_line.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_fill_bg.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_print_char.asm
[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED pixie_print_string.asm

[Your_Path]\Asm02\asm02 -L -D1802MINIPLUS -DPIXIE_MED gfx_display.asm

type pixie_display_buffer.prg pixie_display_ptr.prg > pixie.lib
type pixie_begin_display.prg pixie_end_display.prg >> pixie.lib
type pixie_clear_buffer.prg pixie_fill_buffer.prg  >> pixie.lib
type pixie_write_pixel.prg pixie_begin_display.prg >> pixie.lib
type pixie_fast_h_line.prg pixie_fast_v_line.prg >> pixie.lib
type pixie_fill_bg.prg pixie_print_char.prg >> pixie.lib
type pixie_print_string.prg gfx_display.prg >> pixie.lib

copy pixie.lib ..\lib\pixie.lib
