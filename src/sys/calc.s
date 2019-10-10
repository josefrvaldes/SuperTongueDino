
;Inputs:
;     D es el numerador
;     E es el denominador
;Outputs:
;     A es el resto
;     D es el resultado
dividir_d_e::
   ld b, #8
   xor a
      sla d
      rla
      cp e
      jr c, . + 4
         inc d
         sub e
      djnz . - 8
   ret