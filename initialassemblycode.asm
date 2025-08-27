
ORG 100h

; Prompt the user
MOV AH, 09h
LEA DX, prompt
INT 21h

; Read first initial
MOV AH, 01h
INT 21h
MOV first, AL

; Read middle initial
MOV AH, 01h
INT 21h
MOV middle, AL

; Read last initial
MOV AH, 01h
INT 21h
MOV last, AL

; Print newline
CALL new_line

; Print first initial
MOV DL, first
MOV AH, 02h
INT 21h
CALL new_line

; Print middle initial
MOV DL, middle
MOV AH, 02h
INT 21h
CALL new_line

; Print last initial
MOV DL, last
MOV AH, 02h
INT 21h
CALL new_line

RET

; Subroutine to print newline
new_line:
    MOV AH, 02h
    MOV DL, 13     ; Carriage return
    INT 21h
    MOV DL, 10     ; Line feed
    INT 21h
    RET

; Data section
prompt DB 'Enter your initials (first, middle, last): $'
first DB ?
middle DB ?
last DB ?
