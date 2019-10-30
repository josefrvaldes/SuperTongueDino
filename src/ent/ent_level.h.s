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
;; Entity LEVEL, this is the default level entity
;;
max_levels == 51
final_Level == 50

;; Defines a new entity component
.macro DefineCmp_Level _pack_end, _str
   .dw   _pack_end   
   .dw   _str   
.endm

lev_pack_end_l        = 0
lev_pack_end_h        = 1
lev_str_l        	    = 2
lev_str_h             = 3
sizeof_level          = 4


;; Default constructor for entity components
.macro DefineCmp_Level_default
   DefineCmp_Level 0x0000, 0x0000 ;; reserva el espacio de una entidad, NO!! crea una entidad
.endm

;; Defines entity array for components
.macro DefineCmpArray_Level _N
   .rept _N
      DefineCmp_Level_default
   .endm
.endm
