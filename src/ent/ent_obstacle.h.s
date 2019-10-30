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
;; Entity OBSTACLE
;;
max_obstacles == 12

;; Defines a new entity component
.macro DefineCmp_Obstacle _x, _y, _w, _h, _color
    .db     _x, _y  
    .db _w, _h
    .db _color
    .dw 0xCCCC  ;; Last video memory pointer value
.endm

obs_x        = 0
obs_y        = 1
obs_w        = 2
obs_h        = 3
obs_color    = 4
obs_lastVP_l = 5
obs_lastVP_h = 6
sizeof_obs   = 7

;; Default constructor for entity components
.macro DefineCmp_Obstacle_default
    DefineCmp_Obstacle 0, 0, 0, 0, 0xFF
.endm

;; Defines entity array for components
.macro DefineCmpArray_Obstacle _N
    .rept _N
        DefineCmp_Obstacle_default
    .endm
.endm