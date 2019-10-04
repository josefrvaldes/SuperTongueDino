;;
;;  ENTITY AI CONTROL SYSTEM
;;
.include "cpctelera.h.s"
.include "cmp/entity.h.s"
.include "man/entity.h.s"



.module sys_ai_control



;; //////////////////
;; Inits AI system
;; Input: IX -> puntero al array de entidades
sys_ai_control_init::
	ld 	(_ent_array_ptr_temp_standby), ix  ;; temporal

	ld 	(_ent_array_ptr), ix
	ret




;; //////////////////
;; SAI Stand by
sys_ai_stand_by::
_ent_array_ptr_temp_standby = . + 2
	ld	iy, #0x0000

	ld 	a, e_ai_aim_x(iy)
	or 	a
	ret	z

	;; Cambiar estado si se pulsa una tecla
	ld	a, e_x(iy)
	ld	e_ai_aim_x(ix), a
	ld	a, e_y(iy)
	ld	e_ai_aim_y(ix), a
	ld	e_ai_st(ix), #e_ai_st_move_to

	ret




;; //////////////////
;; Ai Move to
sys_ai_move_to::
	ld	e_vy(ix), #0
	ld	e_vx(ix), #0 ;; IMPORTANTE !!! esto no lo pone en su video pero creo que se debe poner por la linea anterior que si pone

	;;DETECTAR X
	ld	a, e_ai_aim_x(ix)		;; A = obj_x
	sub	e_x(ix)			;; A = obj_x - x
	jr	nc, _objx_greater_or_equal
_objx_lesser:
	ld	e_vx(ix), #-1
	jr	_endif_x
_objx_greater_or_equal:
	jr	z, _arrived_x
	ld	e_vx(ix), #1
	jr	_endif_x
_arrived_x:
	ld	e_vx(ix), #0
_endif_x:

	;; DETECTAR Y
	ld	a, e_ai_aim_y(ix)		;; A = obj_y
	sub	e_y(ix)			;; A = obj_y - y
	jr	nc, _objy_greater_or_equal
_objy_lesser:
	ld	e_vy(ix), #-1
	jr	_endif_y
_objy_greater_or_equal:
	jr	z, _arrived_y
	ld	e_vy(ix), #1
	jr	_endif_y
_arrived_y:
	ld	e_vy(ix), #0
	ld	a, e_vx(ix)
	or	a
	jr	nz, _endif_y
	ld	e_ai_st(ix), #e_ai_st_stand_by	;; la X e Y son 0, por lo que ha llegado
_endif_y:

	ret



;; //////////////////
;; Sys AI CONTROL UPDATE
;; Input: IX -> puntero al array de entidades,    A -> numero de elementos en el array 
;; Destroy: AF, BC, DE, IX
;; Stack Use: 2 bytes
sys_ai_control_update::
	ld	(_ent_counter), a

_ent_array_ptr = . + 2
	ld	ix, #0x0000

_loop:

	ld	a, e_ai_st(ix)
	cp	#e_ai_st_noAI
	jr	z, _no_AI_ent
_AI_ent:
	cp 	#e_ai_st_stand_by
	call	z, sys_ai_stand_by
	cp 	#e_ai_st_move_to
	call	z, sys_ai_move_to
_no_AI_ent:

_ent_counter = . + 1
	ld 	a, #0
	dec	a
	ret 	z


	ld	(_ent_counter), a
	;; salta a la siguiente entidad
	ld	de, #sizeof_e
	add	ix, de

	jr	_loop