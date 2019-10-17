.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "man/man_level.h.s"
.include "ent/ent_level.h.s"


.module level_manager


DefineComponentArrayStructure _level, max_levels, DefineCmp_Level_default ;; ....  


num_current_level:: .db #0


;; //////////////////
;; getArray
;; Input: -
;; Destroy: A, IX
man_level_getArray::
   ld  ix, #_level_array
   ld a, (_level_num)
   ret



;; //////////////////
;; init Entity
;; Input: -
;; Destroy: AF, HL
man_level_init::
   xor a             ;; pone a con el valor de 0, solo ocupa una operacion
   ld    (_level_num), a

   ld hl, #_level_array
   ld (_level_pend), hl

   ret



;; //////////////////
;; NEW Entity
;; Input: -
;; Destroy: F, BC, DE, HL
;; Return: BC -> tamaño de la entidad,   DE -> apunta al elemento creado
man_level_new::
   ;; Incrementar numero de entidades
   ld hl, #_level_num
   inc   (hl)

   ;; Mueve el puntero del array al siguiente elemento vacio
   ld hl, (_level_pend)
   ld d, h
   ld e, l
   ld bc, #sizeof_level
   add hl, bc
   ld (_level_pend),hl

   ret 

;; //////////////////
;; CREATE Entity
;; Input: HL -> puntero para inicializar valores de la entidad
;; Destroy: F, BC, DE, HL
;; Return: IX -> puntero al componente creado
man_level_create::
   push hl
   call man_level_new

   ld__ixh_d  ;; carga d en el registro alto de ix
   ld__ixl_e

   pop hl
   ldir

   ret