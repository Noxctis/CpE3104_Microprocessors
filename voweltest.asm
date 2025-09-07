; ============
; COM template
; ============
org 100h

    jmp start                   ; jump over data

; -----------------
; Data definitions
; -----------------
MSG1    db 'Enter a string (max 20 chars): $'   ; prints until $
RESULT  db 13,10,'Number of vowels: $'          ; 13 cret, 10 newline acts as enter
BUFFER  db 21        ; maximum length (20) + 1
LEN     db ?         ; actual number of characters read                 2nd byte actual length
DATAIN  db 21 dup(?) ; storage for string up to 20 unknown values       rest byte actual values + cret

; -----------------
; Code section
; -----------------
start:
    ; setup DS
    push cs
    pop  ds

    ; prompt user
    mov dx, offset MSG1 ;prints prompt
    mov ah, 09h
    int 21h

    ; read string using interrupt 0Ah - input of a string to DS:DX, first byte is buffer size, second byte is number of chars actually read. this function does not add '$' in the end of string.
    mov dx, offset BUFFER ; 1st byte is max chars
    mov ah, 0Ah           ; 2nd byte (len) actual length)
    int 21h               ; rest byte actual data

    ; SI will point to the data portion of buffer
    lea si, DATAIN
    xor cx, cx                 ; CX = vowel counter = 0 canonical way to zero out?

next_char:
    mov al, [si]               ; get next character at address [SI]
    cmp al, 0Dh                ; Enter (carriage return)?
    je done_count              ; if yes, end of input

    ; convert to uppercase (clear bit 5) bin 1101 1111 since lowercase and uppercase differ by 32 in decimal which is the 5th bit being 0 and anding with DF forces the 5th bit to be zero and the rest of the bits being theirselves 
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

    ; print count in decimal (only 0-9) i doubt theres a word with more than 9 vowels? anyways it breaks because theres a gap between numbers and letters and extra logic is needed if i want to print in Hex
    mov ax, cx
    add al, '0' ; since the counter is in decimal we add the hex value of 0 to make it hex value of a decimal in register to print it
    mov dl, al  ; intterupt write character to standard output. entry: DL = character to write, after execution AL = DL.
    mov ah, 02h
    int 21h

    ; exit
    mov ax, 4C00h ; standard exit
    int 21h
