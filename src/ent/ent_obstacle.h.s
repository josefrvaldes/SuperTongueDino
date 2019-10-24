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