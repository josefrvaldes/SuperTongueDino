.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "man/man_level.h.s"
.include "ent/ent_level.h.s"

.globl _level00_pack_end
.globl _level01_pack_end
.globl _tileset_juego_pack_end

decompress_buffer             = 0x4000
tileset_max_size              = 0x780
level_max_size                = 0x1F4    ; hay que acordarse de poner en el buildconfig que nuestro código empezará a partir de tileset_max_size + level_max_size, que en este caso es 4F4
total_max_size                = tileset_max_size + level_max_size
decompress_buffer_tilemap_end = decompress_buffer + level_max_size - 1
decompress_buffer_tileset_end = decompress_buffer + total_max_size - 1
tilemap_ptr                   = decompress_buffer + 0
tileset_ptr                   = decompress_buffer + level_max_size

ancho_tilemap                 = #20



man_tilemap_init::
   call man_level_getArray 
   jp man_tilemap_load


man_tilemap_load::
   call man_level_get_current 
   ; descomprimimos tilemap del nivel que toque a continuación del tileset
   ld h, lev_pack_end_h(iy)
   ld l, lev_pack_end_l(iy)
   call man_tilemap_descomprimir_nuevo_nivel

   ; descomprimimos el tileset
   ld hl, #_tileset_juego_pack_end
   ld de, #decompress_buffer_tileset_end
   jp cpct_zx7b_decrunch_s_asm


man_tilemap_render::
   ld bc, #0x1914       ; b = alto en tiles, c = ancho en tiles
   ld de, #ancho_tilemap ; ancho en tiles del tilemap, en realidad será fijo, siempre será 20
   ld hl, #tileset_ptr  ; puntero al inicio del tileset
   call cpct_etm_setDrawTilemap4x8_ag_asm


   ld hl, #0xC000       ; posición de memoria de video, a priori siempre será ésta
   ld de, #tilemap_ptr  ; posición al tilemap
   jp cpct_etm_drawTilemap4x8_ag_asm



; Input
;     hl: _levelX_pack_end
; Destroys:
;     DE
man_tilemap_descomprimir_nuevo_nivel::
   ; descomprimimos tilemap del nivel que toque a continuación del tileset
   ld h, lev_pack_end_h(iy)
   ld l, lev_pack_end_l(iy)
   ld de, #decompress_buffer_tilemap_end
   jp cpct_zx7b_decrunch_s_asm