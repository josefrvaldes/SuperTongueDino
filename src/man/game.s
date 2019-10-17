;;
;;  GAME MANAGER
;;
.include "cpctelera.h.s"
.include "sys/render.h.s"
.include "ent/entity.h.s"
.include "ent/ent_obstacle.h.s"
.include "sys/physics.h.s"
.include "sys/render.h.s"
.include "sys/input.h.s"
.include "man/entity.h.s"
.include "man/man_obstacle.h.s"
.include "sys/ai_control.h.s"
.include "man/menuIngame.h.s"
.include "man/man_level.h.s"
.include "man_invisibility.h.s"
.include "sys/sys_collision_entity.h.s"
;.include "man/sprite.h.s"

.module game_manager


bool_mostrar_menu: .db #0

nivel:: .db #21


.globl _hero_sp_1
.globl _hero_sp_0
.globl _hero_sp_2
.globl _enemigo1_sp_0
.globl _enemigo2_sp_0


;; Manager Variables
ent1: DefineCmp_Entity 50,  40,  0,  0, 4, 8, 0, _hero_sp_0,     e_tipo_jugador,  e_ai_st_noAI, 0, 0, 0, 0
;ent2: DefineCmp_Entity 30,  30,  1,  1, 4, 8, 0, _enemigo1_sp_0, e_tipo_enemigo1, e_ai_st_rebotar, 0, 0, 0, 0
ent2: DefineCmp_Entity 15,  20, -1, 3, 4,  8, 0, _enemigo2_sp_0, e_tipo_enemigo2, e_ai_st_patrullar, 0, 0x20, 0x20, 0
;ent3: DefineCmp_Entity 10,  20, 1, 3, 4,  8, 0, _enemigo2_sp_0, e_tipo_enemigo2, e_ai_st_patrullar, 0, 0x20, 0x20, 0

;ent3: DefineCmp_Entity 40, 0,    2, 0xFC, 4,  8, _hero_sp_0, e_ai_st_stand_by
;ent4: DefineCmp_Entity 50,  0,    2, 0xFC, 4,  8, _hero_sp_0, e_ai_st_stand_by

	
;; //////////////////
;; Manager Game Init
;; Input: -
;; Destroy: AF, BC, DE, HL, IX
man_game_init::

	call man_level_init
	call man_level_insertar_niveles



	;; Obstacle manager
	call man_obstacle_init
	;; nos da el puntero al array de obstaculos
	call man_obstacle_getArray


;======================================================0


	;; Entity manager
	call man_entity_init

	
	;; Init Systems
	call man_entity_getArray
	call sys_ai_control_init
	call sys_eren_init
	call sys_physics_init
	call sys_input_init
	call sys_collision_entity_init

	;; Init 3 entities
	ld hl, #ent1
	call man_entity_create
	ld hl, #ent2
	call man_entity_create
	;ld hl, #ent3
	;call man_entity_create
	;ld hl, #ent4
	;call man_entity_create


	ret



;; //////////////////
;; Manager Game Update
;; Input: -
;; Destroy: -
man_game_update::				;; MEJORAR!!! esto ya que estoy pasando IX al update y se puede pasar en el Init

	;ld	a, e_x(ix)
	;add	e_vx(ix)
	;ld	c, a
	;ld	a, e_vx(ix)
	;sub	c
	;jr	z, continuar
	;jr	c, sprite_1
	;	ld	hl, #_hero_sp_1
	;	ld	e_pspr_l(ix), l
	;	ld	e_pspr_h(ix), h
	;	jr continuar
;sprite_1:
;	ld	hl, #_hero_sp_0
;	ld	e_pspr_l(ix), l
;	ld	e_pspr_h(ix), h
;continuar:

	ld a, (#bool_mostrar_menu) ;; comprobacion menu ingame abierto
	dec a
	jr z, #update_menuIngame


	call man_entity_getArray
	call sys_input_update

	;call man_entity_getArray
	;call set_sprite_hero

	call man_entity_getArray
	call aplicate_invisibility

	;cpctm_setBorder_asm HW_RED
	call man_entity_getArray
	call sys_ai_control_update

	;cpctm_setBorder_asm HW_WHITE
	call man_entity_getArray
	call sys_physics_update

	call man_entity_getArray
	call sys_collision_entity_update

	ret

update_menuIngame:
	call menuIngame_update
	call menuIngame_input
	ret



;; //////////////////
;; Manager Game Render
;; Input: -
;; Destroy: -
man_game_render::
	ld a, (#bool_mostrar_menu) ;; comprobacion menu ingame abierto
	dec a
	jr z, #render_menuIngame

	call man_entity_getArray
	call sys_eren_update

	ret
render_menuIngame:
	call menuIngame_render
	ret




; ===============
; Elimina: A
abrir_cerrar_menuIngame::
	ld a, (#bool_mostrar_menu) ;; comprobacion menu ingame abierto
	dec a
	jr z, #salir_menuIngame
	abrir_menuIngame:
	ld a, #1
	ld (#bool_mostrar_menu), a
	call menuIngame_init
	ret
	
	salir_menuIngame:
	ld a, #0
	ld (#bool_mostrar_menu), a
	call sys_eren_clearScreen


	;; TEMPORANEO !!! Para dibujar el tileset pero descomprime y todo
	call sys_eren_init

	ret


man_game_cerrarMenuIngame::
	ld a, #0
	ld (#bool_mostrar_menu), a
	ret