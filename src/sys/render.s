;;
;; SQUARE RENDER SYSTEM
;;
.include "cpctelera.h.s"
.include "tilesets/cabeceras_tilesets.h.s"
.include "man/entity.h.s"
.include "cpct_functions.h.s"
.include "ent/entity.h.s"
.include "ent/ent_obstacle.h.s"
.include "man/man_obstacle.h.s"




.module sys_entity_render

.globl _hero_pal

.globl _level0_pack_end
.globl _level1_pack_end
.globl _tiles_castillo_pack_end

;; //////////////////
;; Square Render System Constants
screen_start = 0xC000


decompress_buffer             = 0x4000
tileset_max_size              = 0x300
level_max_size                = 0x1F4 ; hay que acordarse de poner en el buildconfig que nuestro código empezará a partir de tileset_max_size + level_max_size, que en este caso es 4F4
total_max_size                = tileset_max_size + level_max_size
decompress_buffer_tilemap_end = decompress_buffer + level_max_size - 1
decompress_buffer_tileset_end = decompress_buffer + total_max_size - 1
tilemap_ptr                   = decompress_buffer + 0
tileset_ptr                   = decompress_buffer + level_max_size

ancho_tilemap                 = #20




;; //////////////////
;; Sys Render Init
;; Input: -
;; Destroy: AF, BC, DE, HL
sys_eren_init::
      ld    c, #0
      call cpct_setVideoMode_asm
      ld    hl, #_hero_pal
      ld    de, #16
      call cpct_setPalette_asm
      cpctm_setBorder_asm HW_WHITE
      call sys_eren_load_tilemap
      ret


sys_eren_load_tilemap::
      ; descomprimimos tilemap del nivel que toque a continuación del tileset
      ld hl, #_level0_pack_end
      ld de, #decompress_buffer_tilemap_end
      call cpct_zx7b_decrunch_s_asm

      ; descomprimimos el tileset
      ld hl, #_tiles_castillo_pack_end
      ld de, #decompress_buffer_tileset_end
      call cpct_zx7b_decrunch_s_asm

      ld bc, #0x1914       ; b = alto en tiles, c = ancho en tiles
      ld de, #ancho_tilemap ; ancho en tiles del tilemap, en realidad será fijo, siempre será 20
      ld hl, #tileset_ptr  ; puntero al inicio del tileset
      call cpct_etm_setDrawTilemap4x8_ag_asm


      ld hl, #0xC000       ; posición de memoria de video, a priori siempre será ésta
      ld de, #tilemap_ptr  ; posición al tilemap
      call cpct_etm_drawTilemap4x8_ag_asm
      ret



sys_eren_update::
      call sys_eren_render_entities
      call man_obstacle_getArray
      ret



;; //////////////////
;; Sys Render Update
;; Input: IX -> Puntero al array de entidades,   A -> numero de elementos en el array
;; Destroy: AF, BC, DE, HL, IX
;; Stack Use: 2 bytes
sys_eren_render_entities::
      ld    (_ent_counter), a

_update_loop:
      ;; Erase Previous Instance

      ;cpctm_setBorder_asm HW_RED


      ld    e, e_lastVP_l(ix)
      ld    d, e_lastVP_h(ix)
      xor   a
      ld    c, e_w(ix)
      ld    b, e_h(ix)
      push  bc
      call  cpct_drawSolidBox_asm

      ;; Calcular puntero a memoria de video
      ld    de, #screen_start
      ld    c, e_x(ix)
      ld    b, e_y(ix)
      call  cpct_getScreenPtr_asm

      ;; Almacena el puntero de memoria de video al final
      ld    e_lastVP_l(ix), l
      ld    e_lastVP_h(ix), h

      ;; Drae Entity Sprite
      ex    de, hl
      ld    l, e_pspr_l(ix)
      ld    h, e_pspr_h(ix)
      pop   bc
      call cpct_drawSprite_asm

      ;cpctm_setBorder_asm HW_WHITE

      _ent_counter = . + 1
            ld    a, #0
            dec   a
            ret   z

            ld    (_ent_counter), a
            ld    bc, #sizeof_e
            add   ix, bc
            jr    _update_loop






sys_eren_update_obstacle::
      call sys_eren_render_obstacles

      ret

;; //////////////////
;; Sys Render Update Obstacles
;; Input: IY -> Puntero al array de entidades,   A -> numero de elementos en el array
;; Destroy: AF, BC, DE, HL, IY
;; Stack Use: 2 bytes
sys_eren_render_obstacles::
      ld    (_obs_counter), a

_update_loop_obstacles:
      ;; Calcular puntero a memoria de video
      ld    de, #screen_start
      ld    c, obs_x(iy)
      ld    b, obs_y(iy)
      call  cpct_getScreenPtr_asm

      ;; Almacena el puntero de memoria de video al final
      ld    obs_lastVP_l(iy), l
      ld    obs_lastVP_h(iy), h

      ;; Drae Entity Sprite
      ex    de, hl
      ld    a, obs_color(iy)
      ld    c, obs_w(iy)
      ld    b, obs_h(iy)
      call cpct_drawSolidBox_asm

      _obs_counter = . + 1
            ld    a, #0
            dec   a
            ret   z

            ld    (_obs_counter), a
            ld    bc, #sizeof_obs
            add   iy, bc
            jr    _update_loop_obstacles


sys_eren_clearScreen::
      ld   a, #0xC0
      ld   h, a
      ld de, #0
      ld   l, e
      ld  bc, #0x4000  
      jp cpct_memset_f64_asm