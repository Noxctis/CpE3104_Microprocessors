
org 100h

    jmp start                 


; -----------------
; Data definitions
; -----------------
MSG1 db 'Enter a digit (0-9): $'            ; define byte(1 char) my prompt ending with $ for the interrupt
EVEN_MSG db 13,10,'The number is EVEN.$'    ; newline (10) and cret(13) acts like enter
ODD_MSG  db 13,10,'The number is ODD.$'

; -----------------
; Code section
; -----------------
start:
    ; setup DS
    push cs
    pop  ds

    ; prompt user
    mov dx, offset MSG1 ; loads the address of MSG1 into dx
    mov ah, 09h         ; for interrupt output of a string at DS:DX. String must be terminated by '$'.
    int 21h             ; for interrupt

    ; input a character from keyboard
    mov ah, 01h         ;for interrupt read character from standard input, with echo, result is stored in AL.
    int 21h             ;for interrupt
    sub al, '0' ;0 in hex is 30 so it makes it into its decimal value               

    ; Check if even or odd
    test al, 1                ; test least significant bit wtih 1 in decimal which is 1 in binary since its all 2^n and lsb determines if odd or even 0 if even 1 if odd.
    jz is_even                ; if zero flag = 0 ? EVEN
    jmp is_odd                ; else ODD

is_even:
    mov dx, offset EVEN_MSG   ; prints even message if its even
    mov ah, 09h
    int 21h
    jmp done

is_odd:
    mov dx, offset ODD_MSG    ; prints odd message if odd
    mov ah, 09h
    int 21h

done:
    mov ax, 4C00h             ; return control to the operating system (stop program).
    int 21h
