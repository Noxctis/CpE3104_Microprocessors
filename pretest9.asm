

DATA SEGMENT
    MSG1 DB 'TEMPERATURE IN CELSUIS: $'  ; ask the user to input 2-DIGIT temperature
    MSG2 DB 10, 13, 'TEMPERATURE IN FAHRENHEIT: $'
    INST DB 10 DUP ('$')
    TEMP DB ?
    X DB 5
    Y DB 32
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:                 
    MOV AX, DATA         ; stores initialized data
    MOV DS, AX
    LEA DX, MSG1         ; display message to ask for celsius input
    MOV AH, 9
    INT 21H
    MOV AH, 1            ; stores input in AL by character
    INT 21H
    
    SUB AL, 30H          ; begin solving for fahrenheit
    MOV AH, 0
    MOV BL, 10
    MUL BL
    MOV BL, AL
    MOV AH, 1
    INT 21H
    SUB AL, 30H
    MOV AH, 0
    ADD AL, BL
    MOV TEMP, AL
    MOV DL, 09H
    MUL DL
    MOV BL, X
    DIV BL
    MOV AH, 0
    ADD AL, Y  
    
    LEA SI, INST         
    CALL HEX2DEC         ; convert answer to decimal
    
    LEA DX, MSG2         ; display computed answer
    MOV AH, 9
    INT 21H  
    LEA DX, INST
    MOV AH, 9
    INT 21H
    MOV AH, 4CH          ; terminates the program
    INT 21H
CODE ENDS

HEX2DEC PROC NEAR        ; needed to convert hexadecimal to decimal
    MOV CX, 0
    MOV BX, 10
    
LOOP1:
    MOV DX, 0
    DIV BX
    ADD DL, 30H
    PUSH DX
    INC CX
    CMP AX, 9
    JG LOOP1
    
    ADD AL, 30H
    MOV [SI], AL
    
LOOP2:
    POP AX
    INC SI
    MOV [SI], AL
    LOOP LOOP2
    RET
    
HEX2DEC ENDP
END START