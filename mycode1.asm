
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

ORG 100H


START:
    MOV AL, 0F0H
    MOV BL, 10H
    ADD AL, BL
    MOV CL, AL
    SUB CL, BL
    ADC CL, BL
    MUL  BL
    MUL  CX
    IMUL BH
    IMUL DX
    DIV  BL
    DIV  CX
    IDIV BL
    IDIV CX

ret




