;;----------------------------------LICENSE NOTICE-----------------------------------------------------
;;    Super Tongue Dino is a challenging platform game
;;    Copyright (C) 2019  Carlos de la Fuente / Jose Martinez / Jose Francisco Valdes / (@clover_gs)
;;
;;    This program is free software: you can redistribute it and/or modify
;;    it under the terms of the GNU General Public License as published by
;;    the Free Software Foundation, either version 3 of the License, or
;;    (at your option) any later version.
;;
;;    This program is distributed in the hope that it will be useful,
;;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;    GNU General Public License for more details.
;;
;;    You should have received a copy of the GNU General Public License
;;    along with this program.  If not, see <https://www.gnu.org/licenses/>.
;;------------------------------------------------------------------------------------------------------


;;
;; SQUARE RENDER SYSTEM
;;
.include "cpctelera.h.s"
.include "man/entity.h.s"
.include "cpct_functions.h.s"
.include "ent/entity.h.s"
.include "ent/ent_level.h.s"
.include "man/man_level.h.s"
.include "ent/ent_obstacle.h.s"
.include "man/man_obstacle.h.s"
.include "man/man_tilemap.h.s"




.globl _hero_pal



;; //////////////////
;; Square Render System Constants
screen_start = 0xC000




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
	;cpctm_setBorder_asm HW_WHITE
	call sys_eren_load_tilemap
   call sys_eren_drawLevel
   ret




sys_eren_load_tilemap::
	call man_tilemap_load
	jp man_tilemap_render



sys_eren_update::
	call sys_eren_render_entities
   ret;jp sys_eren_drawLevel



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







;; Draw easter egg plant
;; Input: IY -> pointer to dirt Sprite, A -> initialHeight , B-> initialPositionY
;; Destroy: DE, BC, HL, A
sys_eren_drawPlant::
      ;; Calcular puntero a memoria de video
      ex    af, af'
      ld    de, #screen_start
      ld    c, #28
      call  cpct_getScreenPtr_asm
      ; Drae Entity Sprite
      ex    af, af'  ;; para evitar borrar A en el call
      ex    de, hl
      ld    l, 0(iy)
      ld    h, 1(iy)
      ld    c, #24
      ld    b, a
      call cpct_drawSprite_asm
      ret


;; Draw the dirt of easter egg plant
;; Input: IY -> pointer to dirt Sprite
;; Destroy: DE, BC, HL, A
sys_eren_DrawDirtOfPlant::
      ld    de, #screen_start
      ld    c, #25
      ld    a, #137
      ld    b, a
      call  cpct_getScreenPtr_asm
      ; Drae Entity Sprite
      ex    de, hl
      ld    l, 0(iy)
      ld    h, 1(iy)
      ld    c, #30
      ld    a, #8
      ld    b, a
      call cpct_drawSprite_asm
      ret

sys_eren_drawLevel::
   jp man_level_render