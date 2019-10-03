;;
;;  Component Array Structure header
;;


.macro DefineComponentArrayStructure _Tname, _N, _DefineTypeMacroDefault ;; ...
	_Tname'_num:	.db 0
	_Tname'_pend:	.dw _Tname'_array
	_Tname'_array:	
	.rept _N
		_DefineTypeMacroDefault
	.endm
.endm	

;.macro DefineComponentArrayStructure_Size _Tname, _N, _ComponentSize ;; ...
;	_Tname'_num:	.db 0
;	_Tname'_pend: 	.dw _Tname'_array
;	_Tname'_array:	.ds 	_N * _ComponentSize
;.endm
