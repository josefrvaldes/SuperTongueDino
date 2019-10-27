.include "cpctelera.h.s"
.include "ent/array_structure.h.s"
.include "man/man_level.h.s"
.include "man/man_tilemap.h.s"
.include "ent/ent_level.h.s"
.include "cpct_functions.h.s"
.include "man/state.h.s"


.module level_manager




DefineComponentArrayStructure _level, max_levels, DefineCmp_Level_default ;; ....  


; str00: .asciz "LEVEL 00"
str01: .asciz "LEVEL 01"
str02: .asciz "LEVEL 02"
str03: .asciz "LEVEL 03"
str04: .asciz "LEVEL 04"
str05: .asciz "LEVEL 05"
str06: .asciz "LEVEL 06"
str07: .asciz "LEVEL 07"
str08: .asciz "LEVEL 08"
str09: .asciz "LEVEL 09"
str10: .asciz "LEVEL 10"
str11: .asciz "LEVEL 11"
str12: .asciz "LEVEL 12"
str13: .asciz "LEVEL 13"
str14: .asciz "LEVEL 14"
str15: .asciz "LEVEL 15"
str16: .asciz "LEVEL 16"
str17: .asciz "LEVEL 17"
str18: .asciz "LEVEL 18"
str19: .asciz "LEVEL 19"
str20: .asciz "LEVEL 20"
str21: .asciz "LEVEL 21"
str22: .asciz "LEVEL 22"
str23: .asciz "LEVEL 23"
str24: .asciz "LEVEL 24"
str25: .asciz "LEVEL 25"
str26: .asciz "LEVEL 26"
str27: .asciz "LEVEL 27"
str28: .asciz "LEVEL 28"
str29: .asciz "LEVEL 29"
str30: .asciz "LEVEL 30"
str31: .asciz "LEVEL 31"
str32: .asciz "LEVEL 32"
str33: .asciz "LEVEL 33"
str34: .asciz "LEVEL 34"
str35: .asciz "LEVEL 35"
str36: .asciz "LEVEL 36"
str37: .asciz "LEVEL 37"
str38: .asciz "LEVEL 38"
str39: .asciz "LEVEL 39"
str40: .asciz "LEVEL 40"
str41: .asciz "LEVEL 41"
str42: .asciz "LEVEL 42"
str43: .asciz "LEVEL 43"
str44: .asciz "LEVEL 44"
str45: .asciz "LEVEL 45"
str46: .asciz "LEVEL 46"
str47: .asciz "LEVEL 47"
str48: .asciz "LEVEL 48"
str49: .asciz "LEVEL 49"
str50: .asciz "LEVEL 50"


; level00: DefineCmp_Level #_level00_pack_end, #str00
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
;    ld hl, #level00
;    call man_level_create
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
   ld   de, #CPCT_VMEM_START_ASM ;; DE = Pointer to start of the screen
   ld    b, #84                  ;; B = y coordinate (24 = 0x18)
   ld    c, #20                   ;; C = x coordinate (16 = 0x10)
   call cpct_getScreenPtr_asm    ;; Calculate video memory location and return it in HL
   
   ld d, h     ; pos memoria inicio
   ld e, l     ; pos memoria inicio
   
;    push de
;    ld h, #HW_WHITE
;    ld l, #HW_WHITE
;    call cpct_px2byteM0_asm
;    pop de

   ld a, #0xC0    ; color
   ld c, #40   ; ancho en bytes
   ld b, #24   ; alto en bytes
   call cpct_drawSolidBox_asm

   ld h, #1
   ld l, #12
   call _mySetDrawCharM0

   call man_level_get_current

   ld b, lev_str_h(iy) 
   ld c, lev_str_l(iy) 
   ld__iyh_b
   ld__iyl_c

   ld   de, #CPCT_VMEM_START_ASM ;; DE = Pointer to start of the screen
   ld    b, #92                  ;; B = y coordinate (24 = 0x18)
   ld    c, #24                   ;; C = x coordinate (16 = 0x10)
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