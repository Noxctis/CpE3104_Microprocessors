org 100

jmp start


    PASSWORD DB 'HANS14'   ; stored password is HANS14
    PASS EQU ($-PASSWORD)
    MSG1 DB 10, 13, 'PASSWORD: $'
    MSG2 DB 10, 13, 'ACCESS GRANTED! $'
    MSG3 DB 10, 13, 'ACCESS DENIED! $'
    NEW DB 10, 13, '$'
    INST DB 10 DUP(0)

    
START:
    MOV AX, DATA           ; stores initialized data
    MOV DS, AX
    LEA DX, MSG1           ; display message to ask for password input
    MOV AH, 09H
    INT 21H
    MOV SI, 00
    
INPUT:
    MOV AH, 08H            ; reads password input by character
    INT 21H
    CMP AL, 0DH
    JE NEXT                ; jumps to next function 
    
    MOV [INST+SI], AL
    MOV DL, '*'
    MOV AH, 02H            ; outputs '*' for every character input
    INT 21H
    
    INC SI
    JMP INPUT
    
NEXT:
    MOV BX, 00
    MOV CX, PASS
    
CHECK:
    MOV AL, [INST+BX]
    MOV DL, [PASSWORD+BX]
    CMP AL, DL             ; compares input to stored password
    JNE FAIL               ; if not equal, calls fail function to display error message
    
    INC BX
    LOOP CHECK             ; checks per character
    
    LEA DX, MSG2           ; displays success message
    MOV AH, 09H
    INT 21H
    JMP FINISH             ; calls function to terminate program
    
FAIL:
    LEA DX, MSG3           ; displays fail login message
    MOV AH, 09H
    INT 21H
    
FINISH:                    ; terminates the progeam
    MOV AH, 4CH
    INT 21H
    
CODE ENDS
END START
END