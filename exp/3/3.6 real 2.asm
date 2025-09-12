ORG 100h

    push cs
    pop  ds

    LEA DX, STRING       ; ??? DX, STRING
    MOV AH, 09h          ; MOV AH, ???
    INT 21h              ; INT ???

    CALL REVERSE         ; ??? REVERSE

    ; print reversed
    LEA DX, STRING       ; LEA ???,???
    MOV AH, 09h          ; ??? ???, 09H
    INT 21h              ; ??? 21H

RET

REVERSE:
    LEA SI, STRING       
    MOV CX, 23           ; MOV CX,???

LOOP1:
    XOR AX, AX           ; XOR ???,???
    MOV AL, [SI]         ; MOV AL, ???
    CMP AL, '$'          ; CMP AL, ???
    JE  LABEL1           ; ??? LABEL1
    PUSH AX              ; PUSH ???
    INC SI
    LOOP LOOP1           ; LOOP ???

LABEL1:
    MOV SI, OFFSET STRING ; MOV SI, ??? STRING
    MOV CX, 23            ; MOV CX, ???

LOOP2:
    POP DX
    MOV [SI], DL         ; MOV ???, DL
    INC SI               ; INC ???
    LOOP LOOP2           ; ??? LOOP2

EXIT:
    MOV AH, 4Ch          ; MOV ???,???
RET

STRING DB 'THIS IS A SAMPLE STRING$'   ; STRING ??? '...$'
