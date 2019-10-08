;;
;; COMPONENT MANAGER
;;
.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "ent/entity.h.s"
.include "man/entity.h.s"


.module entity_manager


DefineComponentArrayStructure _entity, max_entities, DefineCmp_Entity_default ;; ....



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