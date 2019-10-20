.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "sprite.h.s"
.include "ent/entity.h.s"
.include "man/entity.h.s"
.include "man/state.h.s"


.globl _hero_sp_0
.globl _hero_sp_1
.globl _hero_sp_2
.globl _hero_sp_3
.globl _hero_sp_4
.globl _hero_sp_5
.globl _hero_sp_6
.globl _hero_sp_7
.globl _enemigo2_sp_0
.globl _enemigo2_sp_1
.globl _enemigo2_sp_2
.globl _enemigo2_sp_3
.globl _enemigo2_sp_4
.globl _enemigo2_sp_5
.globl _enemigo2_sp_6
.globl _enemigo2_sp_7
.globl _enemigo1_sp_0
.globl _enemigo1_sp_1
.globl _enemigo1_sp_2
.globl _enemigo1_sp_3
.globl _enemigo1_sp_4
.globl _enemigo1_sp_5
.globl _enemigo1_sp_6
.globl _enemigo1_sp_7
.globl _explosion_sp_0
.globl _explosion_sp_1
.globl _explosion_sp_2
.globl _explosion_sp_3

vx_actual:     .db #0


;;
;; SYS_PHYSICS UPDATE
;; Input: IX -> puntero al array de entidades,    A -> numero de elementos en el array 
;; Destroy: AF, BC, DE, IX, IY, HL -- TODOS
;; Stack Use: 2 bytes
aplicate_animation::
   ld (_ent_counter), a

_update_loop:

    ld  a, e_dead(ix)
    cp  #0
    jr  z, no_dead_entity
        ;; estamos muertos == renderizar explosion
        call animation_explosion
        jr not_more_animation


no_dead_entity:
    ld  a, e_ai_st(ix)
    cp  #e_ai_st_patrullar
    jr  nz, next_ix
            call set_sprite_enemy2
        jr not_more_animation
next_ix:
    cp  #e_ai_st_noAI
    jr  nz, next_ix2
            call set_sprite_hero
        jr not_more_animation
next_ix2:
        call set_sprite_enemy1

not_more_animation:

    _ent_counter = . + 1
    ld  a, #0
    dec     a
    ret z


   ld (_ent_counter), a
   ld de, #sizeof_e
   add   ix, de
   jr _update_loop





animation_explosion:

    ld  a, e_timeDead(ix)
    dec  a
    ld  e_timeDead(ix), a
    cp  #0
    ret m

procesar_cambios_dead:
        ;; ACTIVAR DE ALGUN MODO EL "REPINTAR TODO EL TILED"
        ;; ELIMINAR ENTIDAD DEL ARRAY DE ENTIDADES
    ld  a, e_timeDead(ix)
    cp  #12
    jp  m, explosion1        
        ld  hl,  #_explosion_sp_0
    jr  finish_sprite_dead
explosion1:
    ld  a, e_timeDead(ix)
    cp  #6
    jp  m, explosion2
        ld  hl,  #_explosion_sp_1
    jr  finish_sprite_dead
explosion2:
    ld  a, e_timeDead(ix)
    cp  #2
    jp  m, explosion3
        ld  hl,  #_explosion_sp_2
    jr  finish_sprite_dead
explosion3:
    ld  a, e_timeDead(ix)
    cp  #1
    jp  m, no_more_explosion   
        ld  hl,  #_explosion_sp_3
    jr  finish_sprite_dead
no_more_explosion:

    ld  a, e_ai_st(ix)
    cp  #e_ai_st_noAI
    jr  nz, __enemy
    ;=========================================================================================================================
    ;; SOMOS EL HERO
        ;ld  a, #2
        ;call man_state_setEstado ;; cambio de estado

        ret
    ;=========================================================================================================================
__enemy:
    ;; SOMOS UN ENEMIGO
    ;; e_dead(ix) == 0  --  VIVO
    ;; e_dead(ix) == 1  --  MURIENDO 
    ;; e_dead(ix) == 2  --  MUERTO
        ld  a, #2
        ld  e_dead(ix), a
    ;=========================================================================================================================
        ret

finish_sprite_dead:
        ld  e_pspr_h(ix), h
        ld  e_pspr_l(ix), l

    ret


;;
;; METODO PARA CAMBIO DE SPRITE
;; INPUT:   A sprite  al que queremos cambiar
;; DESTROYS: AF, HL, BC, DE
;;
set_sprite_hero:

    ;call man_entity_getArray  ;; entidad que quiero en IX
    ld a, e_vx(ix)
    cp  #0
    jr  z, procesar_invisibilidad_sprite          ;; si la velocidad en x no se modifica no entro al contador
    ;; pero si debo permitir cambio de sprote de invisibilidad

    ld  a, e_timeAnimat(ix)
    dec  a
    ld  e_timeAnimat(ix), a
    jr  nz, procesar_cambios_sprite
        ;; entramos y reseteamos
        ld  a, #0x05
        ld  e_timeAnimat(ix), a

        ;; ACTUAMOS
        ld  a, e_stepActual(ix)
        dec a
        jr  z, es_paso2
            ;; ES PASO 1
            ld  a, #1
            ld  e_stepActual(ix), a
            ;call    sprite_hero_direction_paso1
            jr  procesar_cambios_sprite
es_paso2:
            ;; ES PASO 2
            ld  a, #0
            ld  e_stepActual(ix), a
            ;call    sprite_hero_direction_paso2
            ;ret

procesar_cambios_sprite:

    ld  a, e_stepActual(ix)
    dec a
    jr  z, procesar_paso2
        call    sprite_hero_paso1
        jr  finish_sprite_hero
procesar_paso2:
        call    sprite_hero_paso2
        jr  finish_sprite_hero


procesar_invisibilidad_sprite:
    ;; MOVIMINETO HACIA LA DERECHA
    ld  a,  e_invisi(ix)
    dec a
    jr nz, visibility
        call sprite_hero_invisibilidad_stopped
    jr  finish_sprite_hero
visibility:
        call sprite_hero_visibilidad_stopped  
finish_sprite_hero:
        ld  e_pspr_h(ix), h
        ld  e_pspr_l(ix), l


    ret
;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_hero_paso1:

    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso1
        ;; MOVIMINETO HACIA LA DERECHA
        ld  a,  e_invisi(ix)
        dec a
        jr nz,  no_invisibilidad_paso1_der
            ;; INVISIBLE
            ld  hl, #_hero_sp_2
        ret
no_invisibilidad_paso1_der:
            ;; VISIBLE
            ld  hl, #_hero_sp_0
        ret

movIz_paso1:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
    ld  a,  e_invisi(ix)
    dec a
    jr nz,  no_invisibilidad_paso1_iz
        ;; INVISIBLE
        ld  hl, #_hero_sp_3
    ret
no_invisibilidad_paso1_iz:
        ;; VISIBLE
        ld  hl, #_hero_sp_1
    ret
;======================================================
sprite_hero_paso2:

    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso2
        ;; MOVIMINETO HACIA LA DERECHA
        ld  a,  e_invisi(ix)
        dec a
        jr nz,  no_invisibilidad_paso2_der
            ;; INVISIBLE
            ld  hl, #_hero_sp_6
        ret
no_invisibilidad_paso2_der:
            ;; VISIBLE
            ld  hl, #_hero_sp_4
        ret

movIz_paso2:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
    ld  a,  e_invisi(ix)
    dec a
    jr nz,  no_invisibilidad_paso2_iz
        ;; INVISIBLE
        ld  hl, #_hero_sp_7
    ret
no_invisibilidad_paso2_iz:
        ;; VISIBLE
        ld  hl, #_hero_sp_5
    ret
;==============================================
sprite_hero_invisibilidad_stopped:
    ;; INVISIBLE
    add   e_x(ix)
    ld c, a
    ld a, (vx_actual)
    sub    c
    jr  nc, inv_iz
        ;; MOVIMINETO HACIA LA DERECHA
        ld  hl, #_hero_sp_2
    ret
inv_iz:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
        ld  hl, #_hero_sp_3
    ret
;===================================================
sprite_hero_visibilidad_stopped:
    ;; INVISIBLE
    add   e_x(ix)
    ld c, a
    ld a, (vx_actual)
    sub    c
    jr  nc, v_iz
        ;; MOVIMINETO HACIA LA DERECHA
        ld  hl, #_hero_sp_0
    ret
v_iz:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
        ld  hl, #_hero_sp_1
    ret
;;
;;
;;
guardar_VX:
    ld  (vx_actual), a

    ret




set_sprite_enemy2:
    ld  a, e_timeAnimat(ix)
    dec  a
    ld  e_timeAnimat(ix), a
    jr  nz, procesar_cambios_sprite_enemy2
        ;; entramos y reseteamos
        ld  a, #0x1F
        ld  e_timeAnimat(ix), a
        ;; ACTUAMOS
        ld  a, e_stepActual(ix)
        dec a
        jr  z, es_paso2_enemy2
            ld  a, #1
            ld  e_stepActual(ix), a
            jr  procesar_cambios_sprite_enemy2
es_paso2_enemy2:
            ld  a, #0
            ld  e_stepActual(ix), a

procesar_cambios_sprite_enemy2:

    ld  a, e_stepActual(ix)
    dec a
    jr  z, procesar_paso2_enemy2
        call    sprite_enemy2_paso1
        jr  finish_sprite_enemy2
procesar_paso2_enemy2:
       ; call    sprite_enemy2_paso2
        call    sprite_enemy2_paso2

finish_sprite_enemy2:
        ld  e_pspr_h(ix), h
        ld  e_pspr_l(ix), l

    ret




;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_enemy2_paso1:
    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso1_enemy2
        ;; MOVIMINETO HACIA LA DERECHA
        ld  a, e_vy(ix)
        or  a
        jp  m, movDer_grav_paso1_enemy2
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_0
        ret
movDer_grav_paso1_enemy2:
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_4
        ret

movIz_paso1_enemy2:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
        ld  a, e_vy(ix)
        or  a
        jp  m, movIz_grav_paso1_enemy2
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_1
        ret
movIz_grav_paso1_enemy2:
            ld  hl, #_enemigo2_sp_5
        ret

;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_enemy2_paso2:
    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso2_enemy2
        ;; MOVIMINETO HACIA LA DERECHA
        ld  a, e_vy(ix)
        or  a
        jp  m, movDer_grav_paso2_enemy2
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_2
        ret
movDer_grav_paso2_enemy2:
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_6
        ret

movIz_paso2_enemy2:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
        ld  a, e_vy(ix)
        or  a
        jp  m, movIz_grav_paso2_enemy2
            ;; NORMAL - GRAVEDAD INVENTIDA
            ld  hl, #_enemigo2_sp_3
        ret
movIz_grav_paso2_enemy2:
            ld  hl, #_enemigo2_sp_7
        ret







set_sprite_enemy1:
    ld  a, e_timeAnimat(ix)
    dec  a
    ld  e_timeAnimat(ix), a
    jr  nz, procesar_cambios_sprite_enemy1
        ;; entramos y reseteamos
        ld  a, #0x09
        ld  e_timeAnimat(ix), a
        ;; ACTUAMOS
        ld  a, e_stepActual(ix)
        dec a
        jr  z, es_paso2_enemy1
            ld  a, #1
            ld  e_stepActual(ix), a
            jr  procesar_cambios_sprite_enemy1
es_paso2_enemy1:
            ld  a, #0
            ld  e_stepActual(ix), a

procesar_cambios_sprite_enemy1:

    ld  a, e_stepActual(ix)
    dec a
    jr  z, procesar_paso2_enemy1
        call    sprite_enemy1_paso1
        jr  finish_sprite_enemy1
procesar_paso2_enemy1:
       ; call    sprite_enemy2_paso2
        call    sprite_enemy1_paso2

finish_sprite_enemy1:
        ld  e_pspr_h(ix), h
        ld  e_pspr_l(ix), l

    ret




;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_enemy1_paso1:
    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso1_enemy1
        ;; MOVIMINETO HACIA LA DERECHA
            ld  hl, #_enemigo1_sp_0
        ret

movIz_paso1_enemy1:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
            ld  hl, #_enemigo1_sp_1
        ret
;;
;; METODO QUE MODIFICA EL SPRITE SEGUN LA DIRECCION A LA QUEMIRA
;; INPUT: B - PASO 1 O PASO 2 (EFECTO DE ANDAR)
;; RETURN: HL - DIRECCION DEL SPRITE
;;
sprite_enemy1_paso2:
    ld  a, e_vx(ix)
    or  a
    jp  m, movIz_paso2_enemy1
        ;; MOVIMINETO HACIA LA DERECHA
            ld  hl, #_enemigo1_sp_2
        ret

movIz_paso2_enemy1:
    ;; MOVIMIENTO HACIA LA IZQUIERDA
            ld  hl, #_enemigo1_sp_3
        ret










