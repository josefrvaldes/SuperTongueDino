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
.include "man/man_invisibility.h.s"
.include "sys/sys_collision_entity.h.s"
.include "man/sprite.h.s"
.include "sys/sys_deleteEntity.h.s"
;.include "man/sprite.h.s"
.include "sys/sys_music.h.s"
.include "man/man_tilemap.h.s"

;.include "sys/sys_deathCounter.h.s"

.module game_manager


bool_mostrar_menu: .db #0


.globl _hero_sp_1
.globl _hero_sp_0
.globl _hero_sp_2
.globl _enemigo1_sp_0
.globl _enemigo2_sp_0


;; Manager Variables
; ; ent1: DefineCmp_Entity 60,  40,  0,  0, 4, 8, 0, _hero_sp_0,     e_tipo_jugador,  e_ai_st_noAI,      0,    0,    0, 0, 0, 0, 0x05, 18, 0
; ent1: DefineCmp_Entity 1,  17,  0,  0, 4, 8, 0, _hero_sp_0,     e_tipo_jugador,  e_ai_st_noAI,      0,    0,    0, 0, 0, 0, 0x05, 18, 0
; ;ent2: DefineCmp_Entity 50,  40,  0,  0, 4, 8, 0, _hero_sp_0,     e_tipo_jugador,  e_ai_st_noAI,      0,    0,    0, 0, 0, 0, 0x05, 18, 0
; ;ent3: DefineCmp_Entity 70,  40,  0,  0, 4, 8, 0, _hero_sp_0,     e_tipo_jugador,  e_ai_st_noAI,      0,    0,    0, 0, 0, 0, 0x05, 18, 0
; ;ent4: DefineCmp_Entity 50,  50,  0,  0, 4, 8, 0, _hero_sp_0,     e_tipo_jugador,  e_ai_st_noAI,      0,    0,    0, 0, 0, 0, 0x05, 18, 0
; ;ent5: DefineCmp_Entity 70,  50,  0,  0, 4, 8, 0, _hero_sp_0,     e_tipo_jugador,  e_ai_st_noAI,      0,    0,    0, 0, 0, 0, 0x05, 18, 0
; ent2: DefineCmp_Entity 10,  182,  1,  1, 4, 8, 0, _enemigo1_sp_0, e_tipo_enemigo1, e_ai_st_rebotar,   0,    0,    0, 0, 0, 0, 0x09, 18, 0
; ;ent2: DefineCmp_Entity 15,  20, -1, 3, 4,  8, 0, _enemigo2_sp_0, e_tipo_enemigo2, e_ai_st_patrullar, 0, 0x20, 0x20, 0, 0, 0, 0x1F, 18, 0
; ent3: DefineCmp_Entity 60,  20, -1, 3, 4,  8, 0, _enemigo2_sp_0, e_tipo_enemigo2, e_ai_st_patrullar, 0, 0x20, 0x20, 0, 0, 0, 0x1F, 18, 0
; ; ent4: DefineCmp_Entity 22,  30, -1, 3, 4,  8, 0, _enemigo2_sp_0, e_tipo_enemigo2, e_ai_st_patrullar, 0, 0x20, 0x20, 0, 0, 0, 0x1F, 18, 0
; ;ent5: DefineCmp_Entity 22,  10, -1, 3, 4,  8, 0, _enemigo2_sp_0, e_tipo_enemigo2, e_ai_st_patrullar, 0, 0x20, 0x20, 0, 0, 0, 0x1F, 18, 0
; ;ent3: DefineCmp_Entity 10,  20, 1, 3, 4,  8, 0, _enemigo2_sp_0, e_tipo_enemigo2, e_ai_st_patrullar, 0, 0x20, 0x20, 0, 0, 0, 0x0F,  18, 0

; ;ent3: DefineCmp_Entity 40, 0,    2, 0xFC, 4,  8, _hero_sp_0, e_ai_st_stand_by
; ;ent4: DefineCmp_Entity 50,  0,    2, 0xFC, 4,  8, _hero_sp_0, e_ai_st_stand_by

	
;; //////////////////
;; Manager Game Init
;; Input: -
;; Destroy: AF, BC, DE, HL, IX
man_game_init::


	;; Obstacle manager
	call man_obstacle_init
	;; nos da el puntero al array de obstaculos
	call man_obstacle_getArray

;======================================================0
	
	;; Init Systems
	call man_entity_getArray
	call sys_ai_control_init
	call sys_eren_init
	call sys_physics_init
	call sys_input_init
	call sys_collision_entity_init
    
    
    	call man_invisibility_activarInvi
	ret



;; //////////////////
;; Manager Game Update
;; Input: -
;; Destroy: -
man_game_update::				;; MEJORAR!!! esto ya que estoy pasando IX al update y se puede pasar en el Init


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
	;cpctm_setBorder_asm HW_YELLOW
	call man_entity_getArray
	call sys_ai_control_update

	;cpctm_setBorder_asm HW_BLUE
	call man_entity_getArray
	call aplicate_animation

	;cpctm_setBorder_asm HW_WHITE
	;cpctm_setBorder_asm HW_GREEN
	call man_entity_getArray
	call sys_physics_update

	;cpctm_setBorder_asm HW_ORANGE
	call man_entity_getArray
	call sys_collision_entity_update

	;cpctm_setBorder_asm HW_BLACK
	call man_entity_getArray
	call sys_delete_entity
	;cpctm_setBorder_asm HW_WHITE

	;call sys_print_death

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
	jr z, salir_menuIngame
	abrir_menuIngame:
	ld a, #1
	ld (#bool_mostrar_menu), a
	call menuIngame_init
	ret
	
	salir_menuIngame:
	ld a, #0
	ld (#bool_mostrar_menu), a
	call sys_eren_clearScreen

	;; Repintar actual tilemap
	;call man_tilemap_load
      call man_tilemap_render

	ret


man_game_cerrarMenuIngame::
	ld a, #0
	ld (#bool_mostrar_menu), a

	ret