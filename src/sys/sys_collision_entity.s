.include "cpctelera.h.s"
.include "ent/entity.h.s"
.include "sys/physics.h.s"
.include "man/state.h.s"

;;
;; IX: PUNTERO PRIMERA ENTIDAD
;;  A: NUMERO DE ENTIDADES
;;
sys_collision_entity_init::
	ret


sys_collision_entity_update::
	add	a, #1
	ld	(_entity_counter), a


_next_ix:
	;; guardamos en DE el puntero IX de la entidad
	ld__e_ixl
	ld__d_ixh

	_entity_counter = . + 1
		ld	a, #0  ;; 1
		dec	a      ;; 0
		jr 	z, _exit
		ld	(_entity_counter2), a
		ld	(_entity_counter), a

		ld	bc, #sizeof_e
		add	ix, bc

	;; Save IX puntero a la siguiente entidad
	push  ix

	;; en este momento IX es la PRIMERA ENTIDAD
	ld__ixl_e
	ld__ixh_d

	ld__iyl_e
	ld__iyh_d

_next_iy:

	_entity_counter2 = . + 1
		ld	a, #0  ;; 1
		dec	a      ;; 0
		jr 	z, _trozo
		ld	(_entity_counter2), a

		ld	bc, #sizeof_e
		add	iy, bc


	;; TENEMOS LAS DOS ENTIDADES EN IX y IY
	call sys_collision_check

	jr	c, __no_collision
		;; HA HABIDO COLISION:
		;; LA FORMA MAS RAPIDA DE SABER SI ENTRE EL PERSONAJE PRINCIPAL Y UN ENEMIG
		;; O DOS ENEMIGOS ES SABIENDO SI LA ENTIDAD EN IX ES EL HERO
		ld	a, e_ai_st(ix)
		cp	#e_ai_st_noAI
		jr	nz, _no_hero
_hero:
		;call process_dead_hero
		cpctm_setBorder_asm HW_RED
		ld	a, #1
		ld	e_dead(ix), a
		;;ld	e_dead(ix), #1			-> DESCOMENTAR PARA MORIR EL JUGADOR

		jr	__no_collision
_no_hero:
		call change_direcction_entity
		cpctm_setBorder_asm HW_RED
__no_collision:

	jr	_next_iy
_trozo:
	pop	ix
	jr	_next_ix
_exit:

	ret

;; IX ENTITY 1
;; IY ENTITY 2
;; RETURN : SI CARRY: NO COLISION // SI NO CARRY: COLISION
sys_collision_check:

	;; COLLISIONS X
	ld	a, e_x(ix)
	add	e_w(ix)
	sub	e_x(iy)
	ret	c

	ld	a, e_x(iy)
	add	e_w(iy)
	sub	e_x(ix)
	ret	c


	;; COLLISIONS Y
	ld	a, e_y(ix)
	add	e_h(ix)
	sub	e_y(iy)
	ret	c

	ld	a, e_y(iy)
	add	e_h(iy)
	sub	e_y(ix)
	ret
