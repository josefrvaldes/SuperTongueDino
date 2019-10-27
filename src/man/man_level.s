.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "man/man_level.h.s"
.include "man/man_tilemap.h.s"
.include "ent/ent_level.h.s"
.include "cpct_functions.h.s"
.include "man/state.h.s"


.module level_manager

.globl _myDrawStringM0


DefineComponentArrayStructure _level, max_levels, DefineCmp_Level_default ;; ....  


str00: .asciz "Level 01"
str01: .asciz "Level 02"
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
str20: .asciz "Level 20"
str21: .asciz "Level 21"
str22: .asciz "Level 22"
str23: .asciz "Level 23"
str24: .asciz "Level 24"
str25: .asciz "Level 25"
str26: .asciz "Level 26"
str27: .asciz "Level 27"
str28: .asciz "Level 28"
str29: .asciz "Level 29"
str30: .asciz "Level 30"
str31: .asciz "Level 31"
str32: .asciz "Level 32"
str33: .asciz "Level 33"
str34: .asciz "Level 34"
str35: .asciz "Level 35"
str36: .asciz "Level 36"
str37: .asciz "Level 37"
str38: .asciz "Level 38"
str39: .asciz "Level 39"
str40: .asciz "Level 40"
str41: .asciz "Level 41"
str42: .asciz "Level 42"
str43: .asciz "Level 43"
str44: .asciz "Level 44"
str45: .asciz "Level 45"
str46: .asciz "Level 46"
str47: .asciz "Level 47"
str48: .asciz "Level 48"
str49: .asciz "Level 49"
str50: .asciz "Level 50"


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
level20: DefineCmp_Level #_level20_pack_end, #str20
level21: DefineCmp_Level #_level21_pack_end, #str21
level22: DefineCmp_Level #_level22_pack_end, #str22
level23: DefineCmp_Level #_level23_pack_end, #str23
level24: DefineCmp_Level #_level24_pack_end, #str24
level25: DefineCmp_Level #_level25_pack_end, #str25
level26: DefineCmp_Level #_level26_pack_end, #str26
level27: DefineCmp_Level #_level27_pack_end, #str27
level28: DefineCmp_Level #_level28_pack_end, #str28
level29: DefineCmp_Level #_level29_pack_end, #str29
level30: DefineCmp_Level #_level30_pack_end, #str30
level31: DefineCmp_Level #_level31_pack_end, #str31
level32: DefineCmp_Level #_level32_pack_end, #str32
level33: DefineCmp_Level #_level33_pack_end, #str33
level34: DefineCmp_Level #_level34_pack_end, #str34
level35: DefineCmp_Level #_level35_pack_end, #str35
level36: DefineCmp_Level #_level36_pack_end, #str36
level37: DefineCmp_Level #_level37_pack_end, #str37
level38: DefineCmp_Level #_level38_pack_end, #str38
level39: DefineCmp_Level #_level39_pack_end, #str39
level40: DefineCmp_Level #_level40_pack_end, #str40
level41: DefineCmp_Level #_level41_pack_end, #str41
level42: DefineCmp_Level #_level42_pack_end, #str42
level43: DefineCmp_Level #_level43_pack_end, #str43
level44: DefineCmp_Level #_level44_pack_end, #str44
level45: DefineCmp_Level #_level45_pack_end, #str45
level46: DefineCmp_Level #_level46_pack_end, #str46
level47: DefineCmp_Level #_level47_pack_end, #str47
level48: DefineCmp_Level #_level48_pack_end, #str48
level49: DefineCmp_Level #_level49_pack_end, #str49
level50: DefineCmp_Level #_level50_pack_end, #str50



iy_current_level::  .dw #0
memory_firstLevel:: .dw #_level_array
num_current_level:: .db #0



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
   ld hl, #level20
   call man_level_create
   ld hl, #level21
   call man_level_create
   ld hl, #level22
   call man_level_create
   ld hl, #level23
   call man_level_create
   ld hl, #level24
   call man_level_create
   ld hl, #level25
   call man_level_create
   ld hl, #level26
   call man_level_create
   ld hl, #level27
   call man_level_create
   ld hl, #level28
   call man_level_create
   ld hl, #level29
   call man_level_create
   ld hl, #level30
   call man_level_create
   ld hl, #level31
   call man_level_create
   ld hl, #level32
   call man_level_create
   ld hl, #level33
   call man_level_create
   ld hl, #level34
   call man_level_create
   ld hl, #level35
   call man_level_create
   ld hl, #level36
   call man_level_create
   ld hl, #level37
   call man_level_create
   ld hl, #level38
   call man_level_create
   ld hl, #level39
   call man_level_create
   ld hl, #level40
   call man_level_create
   ld hl, #level41
   call man_level_create
   ld hl, #level42
   call man_level_create
   ld hl, #level43
   call man_level_create
   ld hl, #level44
   call man_level_create
   ld hl, #level45
   call man_level_create
   ld hl, #level46
   call man_level_create
   ld hl, #level47
   call man_level_create
   ld hl, #level48
   call man_level_create
   ld hl, #level49
   call man_level_create
   ld hl, #level50
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

   ld    a, (num_current_level)
   inc   a
   ld    (num_current_level), a

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
   call _myDrawStringM0
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




comprobarFinalJuego::
   ld    a, (num_current_level)
   ld    b, a
   ld    a, #final_Level
   cp    b
   jr    c, ultimoNivel_pasado
   jr    z, ultimoNivel_pasado
   ld    a, #0
   ret

   ultimoNivel_pasado:
   ld    a, #3
   call man_state_setEstado ; salir menu principal
   ld    a, #1

   ret