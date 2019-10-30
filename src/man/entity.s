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
;; COMPONENT MANAGER
;;
.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "ent/entity.h.s"
.include "man/entity.h.s"

.globl _hero_sp_0
; .globl _hero_sp_1
; .globl _hero_sp_2
.globl _enemigo1_sp_0
.globl _enemigo2_sp_0


deathsPlayer:: .dw #0

DefineComponentArrayStructure _entity, max_entities, DefineCmp_Entity_default ;; ....


hero:: DefineCmp_Entity 0,  0,  0,  0, 4, 8, 0, _hero_sp_0,     e_tipo_jugador,  e_ai_st_noAI,      0,    0,    0, 0, 0, 0, 0x05, 18, 0
ene1:: DefineCmp_Entity 0,  0,  1,  1, 4, 8, 0, _enemigo1_sp_0, e_tipo_enemigo1, e_ai_st_rebotar,   0,    0,    0, 0, 0, 0, 0x09, 18, 0
ene2:: DefineCmp_Entity 0,  0, -1,  3, 4, 8, 0, _enemigo2_sp_0, e_tipo_enemigo2, e_ai_st_patrullar, 0, 0x09, 0x09, 0, 0, 0, 0x1F, 18, 0


;; //////////////////
;; getArray
;; Input: -
;; Destroy: A, IX
man_entity_getArray::
	ld  ix, #_entity_array
	ld	a, (_entity_num)
	ret



;; //////////////////
;; init Entity
;; Input: -
;; Destroy: AF, HL
man_entity_init::
	xor a   				;; pone a con el valor de 0, solo ocupa una operacion
	ld 	(_entity_num), a

	ld	hl, #_entity_array
	ld	(_entity_pend), hl

	ret



;; //////////////////
;; NEW Entity
;; Input: -
;; Destroy: F, BC, DE, HL
;; Return: BC -> tamaño de la entidad,   DE -> apunta al elemento creado
man_entity_new::
	;; Incrementar numero de entidades
	ld	hl, #_entity_num
	inc	(hl)

	;; Mueve el puntero del array al siguiente elemento vacio
	ld	hl, (_entity_pend)
	ld	d, h
	ld	e, l
	ld	bc, #sizeof_e
	add hl, bc
	ld	(_entity_pend),hl

	ret 

;; //////////////////
;; CREATE Entity
;; Input: HL -> puntero para inicializar valores de la entidad
;; Destroy: F, BC, DE, HL
;; Return: IX -> puntero al componente creado
man_entity_create::
	push hl
	call man_entity_new

	ld__ixh_d  ;; carga d en el registro alto de ix
	ld__ixl_e

	pop hl
	ldir

	ret


man_entity_delete::
	ld	a, (_entity_num)
	dec	a
	ld 	(_entity_num), a

	ret