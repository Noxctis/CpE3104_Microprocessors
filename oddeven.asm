
org 100h

    jmp start                 


; -----------------
MSG1 db 'Enter a digit (0-9): $'
EVEN_MSG db 13,10,'The number is EVEN.$'
ODD_MSG  db 13,10,'The number is ODD.$'

; -----------------
; Code section
; -----------------
start:
    ; Setup DS
    push cs
    pop  ds

    ; Prompt user
    mov dx, offset MSG1
    mov ah, 09h
    int 21h

    ; Input a character from keyboard
    mov ah, 01h
    int 21h
    sub al, '0'               

    ; Check if even or odd
    test al, 1                ; test least significant bit
    jz is_even                ; if 0 ? EVEN
    jmp is_odd                ; else ODD

is_even:
    mov dx, offset EVEN_MSG
    mov ah, 09h
    int 21h
    jmp done

is_odd:
    mov dx, offset ODD_MSG
    mov ah, 09h
    int 21h

done:
    mov ax, 4C00h
    int 21h
