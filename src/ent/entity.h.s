;    Super Tongue Dino a challenging platform game
;    Copyright (C) 2019  PeanutGames
;
;    This program is free software: you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation, either version 3 of the License, or
;    (at your option) any later version.
;
;    This program is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;
;; Entity ENTITY, this is the default enemy and hero entity
;;

max_entities == 6

;; Defines a new entity component
.macro DefineCmp_Entity _x, _y, _vx, _vy, _w, _h, _invisibility, _pspr, _tipoEntidad, _aist, _pausaVel, _clock1, _clock2, _cambioDirec, _dead, _stepActual, _timeAnimat, _timeDead, _IARebotar_chocar
	.db 	_x, _y	
	.db	_vx, _vy
	.db	_w, _h
	.db	_invisibility
	.dw	_pspr		 ;; puntero del sprite
	.db	0x00, 0x00	 ;; pos X e Y del objetivo
	.db	_tipoEntidad ;; que tipo de entidad es
	.db	_aist		 ;; estatus del tipo de IA
	.dw	0xCCCC	 ;; Last video memory pointer value
	.db	_pausaVel	 ;; contador para ralentizar la velocidad de los enemigos
	.db	_clock1	 ;; contador 1 de reloj para IA de patrullar
	.db	_clock2	 ;; contador 2 de reloj para IA de patrullar
	.db	_cambioDirec ;; contador para cuando cambia de direccion la IA de rebotar
	.db	_dead
	.db	_stepActual
	.db	_timeAnimat
	.db   _timeDead
	.db   _IARebotar_chocar  ;; contador para la IA de persecucion cuando choca contra una pared
.endm

e_x		  = 0
e_y		  = 1
e_vx		  = 2
e_vy		  = 3
e_w		  = 4
e_h		  = 5
e_invisi      = 6
e_pspr_l	  = 7
e_pspr_h	  = 8
e_ai_aim_x	  = 9
e_ai_aim_y    = 10
e_tipo	  = 11
e_ai_st	  = 12
e_lastVP_l	  = 13
e_lastVP_h	  = 14
e_ai_pausaVel = 15
e_ai_reloj1   = 16
e_ai_reloj2	  = 17
e_ai_cambioDirecccion = 18
e_dead        = 19
e_stepActual  = 20
e_timeAnimat  = 21
e_timeDead    = 22
e_ai_rebotar_chocar = 23
sizeof_e	  = 24


;; Enumeracion de tipos de Entidad
e_tipo_jugador	= 0
e_tipo_enemigo1	= 1
e_tipo_enemigo2	= 2
e_tipo_enemigo3	= 3

;; Enumeracion de tipos de IA
e_ai_st_noAI	= 0
e_ai_st_stand_by	= 1
e_ai_st_move_to	= 2
e_ai_st_rebotar	= 3
e_ai_st_perseguir = 4
e_ai_st_defender  = 5
e_ai_st_patrullar = 6
e_ai_st_saltar    = 7

;; Default constructor for entity components
.macro DefineCmp_Entity_default
	DefineCmp_Entity 0, 0, 0, 0, 1, 1, 0, 0x0000, e_tipo_enemigo1, e_ai_st_noAI, 0, 0x20, 0x20, 0, 0, 0, 0x1F, 0x12, 0  ;; reserva el espacio de una entidad, NO!! crea una entidad
.endm

;; Defines entity array for components
.macro DefineCmpArray_Entity _N
	.rept _N
		DefineCmp_Entity_default
	.endm
.endm
