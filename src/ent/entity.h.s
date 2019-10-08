;;
;; Entity ENTITY, this is the default enemy and hero entity
;;

max_entities == 4

;; Defines a new entity component
.macro DefineCmp_Entity _x, _y, _vx, _vy, _w, _h, _pspr, _aist
	.db 	_x, _y	
	.db	_vx, _vy
	.db	_w, _h
	.dw	_pspr		;; puntero del sprite
	.db	0x00, 0x00	;; pos X e Y del objetivo
	.db	_aist		;; estatus del tipo de IA
	.dw	0xCCCC	;; Last video memory pointer value
.endm

e_x		= 0
e_y		= 1
e_vx		= 2
e_vy		= 3
e_w		= 4
e_h		= 5
e_pspr_l	= 6
e_pspr_h	= 7
e_ai_aim_x	= 8
e_ai_aim_y  = 9
e_ai_st	= 10
e_lastVP_l	= 11
e_lastVP_h	= 12
sizeof_e	= 13


;; Enumeracion de tipos de IA
e_ai_st_noAI	= 0
e_ai_st_stand_by	= 1
e_ai_st_move_to	= 2


;; Default constructor for entity components
.macro DefineCmp_Entity_default
	DefineCmp_Entity 0, 0, 0, 0, 1, 1, 0x0000, e_ai_st_noAI  ;; reserva el espacio de una entidad, NO!! crea una entidad
.endm

;; Defines entity array for components
.macro DefineCmpArray_Entity _N
	.rept _N
		DefineCmp_Entity_default
	.endm
.endm
