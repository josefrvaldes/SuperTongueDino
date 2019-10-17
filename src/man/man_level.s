.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "man/man_level.h.s"
.include "ent/ent_level.h.s"


.module level_manager


DefineComponentArrayStructure _level, max_levels, DefineCmp_Level_default ;; ....  


level00: DefineCmp_Level #_level00_pack_end
level01: DefineCmp_Level #_level01_pack_end
level02: DefineCmp_Level #_level02_pack_end
level03: DefineCmp_Level #_level03_pack_end
level04: DefineCmp_Level #_level04_pack_end
level05: DefineCmp_Level #_level05_pack_end
level06: DefineCmp_Level #_level06_pack_end
level07: DefineCmp_Level #_level07_pack_end
level08: DefineCmp_Level #_level08_pack_end
level09: DefineCmp_Level #_level09_pack_end
level10: DefineCmp_Level #_level10_pack_end
level11: DefineCmp_Level #_level11_pack_end
level12: DefineCmp_Level #_level12_pack_end
level13: DefineCmp_Level #_level13_pack_end
level14: DefineCmp_Level #_level14_pack_end
level15: DefineCmp_Level #_level15_pack_end
level16: DefineCmp_Level #_level16_pack_end
level17: DefineCmp_Level #_level17_pack_end
level18: DefineCmp_Level #_level18_pack_end
level19: DefineCmp_Level #_level19_pack_end



iy_current_level:: .dw #0


;; //////////////////
;; getArray
;; Input: -
;; Destroy: A, IY
man_level_getArray::
   ld  iy, #_level_array
   ld  (iy_current_level), iy
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


; Inicializa el array de niveles con todos los niveles del juego
man_level_insertar_niveles::
   ld hl, #level00
   call man_level_create
   ld hl, #level01
   call man_level_create
   ld hl, #level02
   call man_level_create
   ld hl, #level03
   call man_level_create
   ld hl, #level04
   call man_level_create
   ld hl, #level05
   call man_level_create
   ld hl, #level06
   call man_level_create
   ld hl, #level07
   call man_level_create
   ld hl, #level08
   call man_level_create
   ld hl, #level09
   call man_level_create
   ld hl, #level10
   call man_level_create
   ld hl, #level11
   call man_level_create
   ld hl, #level12
   call man_level_create
   ld hl, #level13
   call man_level_create
   ld hl, #level14
   call man_level_create
   ld hl, #level15
   call man_level_create
   ld hl, #level16
   call man_level_create
   ld hl, #level17
   call man_level_create
   ld hl, #level18
   call man_level_create
   ld hl, #level19
   call man_level_create
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


man_level_get_current::
   ld iy, (#iy_current_level)
   ret

man_level_load_next::
   call man_level_get_current
   ld  de, #sizeof_level
   add iy, de
   ld (iy_current_level), iy
   ret