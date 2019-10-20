.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "man/entity.h.s"
.include "ent/entity.h.s"



only_one_dead: .db #0  ;; 0 = no hay ningua muerta // 1 = ya tenemos una muerta


;;
;; DELETE ENTITY
;; Input: IX -> puntero al array de entidades,    A -> numero de elementos en el array 
;; Destroy: AF, BC, DE, IX, IY, HL -- TODOS
;;
sys_delete_entity::
   ld (_ent_counter), a


_update_loop:

	;; Buscar aquellas que tengan e_dead(ix) == 2
	ld	a, e_dead(ix)
	cp	#2
	jr	nz, __no_delete
		;; La entidad esta muerta - eliminar
		;; nos guardamos el puntero a la entidad (donde empieza)
		ld	a, (only_one_dead)
		cp	#0
		jr	nz, __no_delete
			;; ELIMINMOS DE VERDAD
			ld__e_ixl
			ld__d_ixh
			;ld	h, d
			;ld	l, e
			push de

			;; INDICAMOS QUE ELIMINAMOS DE VERDAD
			ld	a, #1
			ld	(only_one_dead), a

__no_delete:
	;; La entidad no esta "muerta"

	_ent_counter = . + 1
	ld	a, #0
	dec 	a
	jr	nz, next_ix

		ld	a, (only_one_dead)
		cp	#1
		ret	nz

		;; intercambiar la ultima entidad con la que muere
		;; IX LA ULTIMA ENTIDAD
		;; DE LA ENTIDAD A EIMINAR
		ld bc, #sizeof_e
		;pop de
		ld__e_ixl
		ld__d_ixh
		ld	h, d
		ld	l, e

		pop de

   		ldir

   		call man_entity_delete

		;; ANTES DE IRNOS VOLVER A DEJAR A 0 LA VARIABLE QUE NOS PERMITE MATAR UNA ENTIDAD
		ld	a, #0
		ld	(only_one_dead), a

	ret

next_ix:
   ld (_ent_counter), a
   ld bc, #sizeof_e
   add   ix, bc
   jr _update_loop
;; FIN  -- delete entity --
;; ---------------------------------------------------------------------------------------------------------------------------------------------------- ;;
