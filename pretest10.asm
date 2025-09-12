org 100

DATA SEGMENT
    MSG1 DB "SINGLE DIGIT DECIMAL NUMBER: $"
    MSG2 DB "BINARY NUMBER IS (ignore first 5 digits): $"
    STR1 DB 20 DUP('$')
    STR2 DB 20 DUP('$')
    LINE DB 10,13,'$'
DATA ENDS

CODE SEGMENT
    ASSUME CS:CODE, DS:DATA
    
START:
    MOV AX, DATA
    MOV DS, AX
    LEA DX, MSG1
    MOV AH, 09H
    INT 21H    
    
    MOV AH, 01H
    INT 21H    
         
    LEA SI, STR1
    MOV BH, 00
    MOV BL, 2
      
CONV:
    DIV BL
    ADD AH, '0'
    MOV BYTE PTR[SI],AH
    MOV AH, 00
    INC SI
    INC BH
    CMP AL, 00
    JNE CONV

    MOV CL, BH
    LEA SI, STR1
    LEA DI, STR2
    MOV CH, 00
    ADD SI, CX
    DEC SI

LOOP1:
    MOV AH,BYTE PTR[SI]
    MOV BYTE PTR[DI],AH
    DEC SI
    INC DI
    LOOP LOOP1 
         
    LEA DX, LINE
    MOV AH, 09H
    INT 21H
         
    LEA DX, MSG2
    MOV AH, 09H
    INT 21H
         
    LEA DX, STR2
    MOV AH, 09H
    INT 21H

    MOV AH, 4CH
    INT 21H    
    
CODE ENDS
END START