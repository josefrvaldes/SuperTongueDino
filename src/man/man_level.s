.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "man/man_level.h.s"
.include "man/man_tilemap.h.s"
.include "ent/ent_level.h.s"
.include "cpct_functions.h.s"


.module level_manager


DefineComponentArrayStructure _level, max_levels, DefineCmp_Level_default ;; ....  


str00:: .asciz "Level 01"
str01:: .asciz "Level 02"
str02: .asciz "Level 03"
str03: .asciz "Level 03"
str04: .asciz "Level 04"
str05: .asciz "Level 05"
str06: .asciz "Level 06"
str07: .asciz "Level 07"
str08: .asciz "Level 08"
str09: .asciz "Level 09"
str10: .asciz "Level 10"
str11: .asciz "Level 11"
str12: .asciz "Level 12"
str13: .asciz "Level 13"
str14: .asciz "Level 14"
str15: .asciz "Level 15"
str16: .asciz "Level 16"
str17: .asciz "Level 17"
str18: .asciz "Level 18"
str19: .asciz "Level 19"


level00: DefineCmp_Level #_level00_pack_end, #str00
level01: DefineCmp_Level #_level01_pack_end, #str01
level02: DefineCmp_Level #_level02_pack_end, #str02
level03: DefineCmp_Level #_level03_pack_end, #str03
level04: DefineCmp_Level #_level04_pack_end, #str04
level05: DefineCmp_Level #_level05_pack_end, #str05
level06: DefineCmp_Level #_level06_pack_end, #str06
level07: DefineCmp_Level #_level07_pack_end, #str07
level08: DefineCmp_Level #_level08_pack_end, #str08
level09: DefineCmp_Level #_level09_pack_end, #str09
level10: DefineCmp_Level #_level10_pack_end, #str10
level11: DefineCmp_Level #_level11_pack_end, #str11
level12: DefineCmp_Level #_level12_pack_end, #str12
level13: DefineCmp_Level #_level13_pack_end, #str13
level14: DefineCmp_Level #_level14_pack_end, #str14
level15: DefineCmp_Level #_level15_pack_end, #str15
level16: DefineCmp_Level #_level16_pack_end, #str16
level17: DefineCmp_Level #_level17_pack_end, #str17
level18: DefineCmp_Level #_level18_pack_end, #str18
level19: DefineCmp_Level #_level19_pack_end, #str19



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


man_level_render::
   ld hl, #0x2602
   call cpct_setDrawCharM0_asm

   call man_level_get_current

   ld b, lev_str_h(iy) 
   ld c, lev_str_l(iy) 
   ld__iyh_b
   ld__iyl_c

   ld   de, #CPCT_VMEM_START_ASM ;; DE = Pointer to start of the screen
   ld    b, #16                  ;; B = y coordinate (24 = 0x18)
   ld    c, #8                   ;; C = x coordinate (16 = 0x10)
   call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL
   call cpct_drawStringM0_asm
   call man_level_borrar_letras_con_retraso
   ret
;    ld a, #0xFF
;    loop_tiempo:
;       dec a
;       jr z, fuera_de_loop
;       jr loop_tiempo

;    fuera_de_loop:
;       ld (#bool_dibujar_level), a ; aquí a vale 0, así que pues desactivamos el dibujar level
;       ret


man_level_borrar_letras_con_retraso:
   ld a, #0
   ld d, #2
   ld hl, #0xFFFF
   loop_tiempo:
      dec hl
      cp h
      jr z, h_era_cero
      jr loop_tiempo

      h_era_cero:
      cp l
      jr z, l_era_cero
      jr loop_tiempo

      l_era_cero:
      dec d
      jr z, fuera_de_loop
      jr loop_tiempo

   fuera_de_loop:
      jp man_tilemap_render