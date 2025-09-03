; ============
; COM template
; ============
org 100h

    jmp start                   ; jump over data

; -----------------
; Data definitions
; -----------------
MSG1    db 'Enter a string (max 20 chars): $'
RESULT  db 13,10,'Number of vowels: $'
BUFFER  db 21        ; maximum length (20) + 1
LEN     db ?         ; actual number of characters read
DATAIN  db 21 dup(?) ; storage for string

; -----------------
; Code section
; -----------------
start:
    ; setup DS
    push cs
    pop  ds

    ; prompt user
    mov dx, offset MSG1
    mov ah, 09h
    int 21h

    ; read string using DOS function 0Ah
    mov dx, offset BUFFER
    mov ah, 0Ah
    int 21h

    ; SI will point to the data portion of buffer
    lea si, DATAIN
    xor cx, cx                 ; CX = vowel counter = 0

next_char:
    mov al, [si]               ; get next character
    cmp al, 0Dh                ; Enter (carriage return)?
    je done_count              ; if yes, end of input

    ; convert to uppercase (clear bit 5)
    and al, 0DFh

    ; check against vowels
    cmp al, 'A'
    je is_vowel
    cmp al, 'E'
    je is_vowel
    cmp al, 'I'
    je is_vowel
    cmp al, 'O'
    je is_vowel
    cmp al, 'U'
    je is_vowel
    jmp skip

is_vowel:
    inc cx                     ; found vowel, increase count

skip:
    inc si                     ; move to next char
    jmp next_char

done_count:
    ; print result message
    mov dx, offset RESULT
    mov ah, 09h
    int 21h

    ; print count in decimal (only 0–9 for demo)
    mov ax, cx
    add al, '0'
    mov dl, al
    mov ah, 02h
    int 21h

    ; exit
    mov ax, 4C00h
    int 21h
