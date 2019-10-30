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


;; Include all CPCtelera constant definitions, macros and variables
.include "cpctelera.h.s"
.include "cpct_functions.h.s"
.include "ent/entity.h.s"


tempo1: .db 0x0A    
tempo2: .db 0x0A

cargadorInvisibilidad:: .db #1

;; CONCLUSIONES: 0x0F = 5 segundos
;;         0x20 = 20 segundos


aplicate_invisibility::

    ;; APLICAMOS INVISIBILIDAD
    ld  a,  e_invisi(ix)
    dec a
    ret nz                    ;; si no se hace 0 es que no era invisible
    


    ld  a, (tempo1)
    dec  a
    ld  (tempo1), a
    jr  nz, salto_tempo
      ld  a, #0x0A
      ld  (tempo1), a
      ;jr  salto_tempo


      ld  a, (tempo2)
      dec  a
      ld  (tempo2), a
      jr  nz, salto_tempo

        ;; PINTAMOS ALGO, CUALQUIER COSA CONNNNNYOOOO
         ; ld  de, #0xC000
         ; ld  a, #0xFF
         ; ld  c, #8
         ; ld  b, #8
         ;     call cpct_drawSolidBox_asm

        ;;VOLVEMOS AL ESTADO PRINCIPAL
        ld  a,  #0
        ld  e_invisi(ix), a

        ld  a, #0
        ld  (cargadorInvisibilidad), a  ; no se puede utilizar la invisibilidad

        ld  a, #0x0A
        ld  (tempo1), a
        ld  (tempo2), a

salto_tempo:

  ret




man_invisibility_activarInvi::
  ld  a, #1
  ld  (cargadorInvisibilidad), a  ; Se puede utilizar la invisibilidad

  ret