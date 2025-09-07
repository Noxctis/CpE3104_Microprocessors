org 100h                      ; .COM starts execution at offset 0100h

    jmp start                 ; jump over data section

; -------------------------
; Data / Messages
; -------------------------
PROMPT   db 'Enter a string (max 60): $'
CRLF     db 13,10,'$'

MSG_NO   db 13,10,'There is no number in the inputted string.',13,10,'$'
MSG_YES  db 13,10,'The inputted string contains a number.',13,10,'$'

MSG_PAL  db 13,10,'The string IS a palindrome.',13,10,'$'
MSG_NPAL db 13,10,'The string is NOT a palindrome.',13,10,'$'

BUFMAX   equ 60               ; user may type up to 60 chars (CR not counted)
INBUF    db BUFMAX            ; [0] max chars DOS may accept
         db 0                 ; [1] LEN = actual number of chars typed (no CR)
         db BUFMAX dup(?)     ; [2..] the characters; DOS stores CR at data[LEN]

; -------------------------
; Code
; -------------------------
start:
    push cs                   ; DS must equal CS for .COM
    pop  ds

    mov  dx, offset PROMPT    ; DS:DX -> "$"-terminated prompt
    mov  ah, 09h              ; DOS print string
    int  21h

    mov  dx, offset INBUF     ; DS:DX -> [max][len][data...]
    mov  ah, 0Ah              ; DOS buffered input
    int  21h                  ; returns with LEN in [INBUF+1], data at [INBUF+2]

    ; ------------------------------
    ; (a) DETECT if any digit exists
    ; ------------------------------
    lea  si, [INBUF+2]        ; SI = &data[0]
    mov  cl, [INBUF+1]        ; CL = LEN (0..60)
    xor  ch, ch               ; CX = LEN
    xor  bl, bl               ; BL = found_flag (0 = none yet)

ScanDigits:
    jcxz NoMoreScan           ; if CX==0, done scanning
    lodsb                     ; AL = *SI; SI++
    cmp  al, '0'              ; below '0'?
    jb   NotDigit
    cmp  al, '9'              ; above '9'?
    ja   NotDigit
    mov  bl, 1                ; found at least one digit
    jmp  NoMoreScan           ; we only need to know it exists

NotDigit:
    loop ScanDigits           ; CX-- and repeat
NoMoreScan:

    cmp  bl, 0                ; found_flag == 0 ?
    jne  HasNumber
    mov  dx, offset MSG_NO    ; none found
    mov  ah, 09h
    int  21h
    jmp  PalindromeCheck

HasNumber:
    mov  dx, offset MSG_YES   ; at least one digit exists
    mov  ah, 09h
    int  21h

; -----------------------------------------
; (b) PALINDROME CHECK (case-insensitive)
; -----------------------------------------
PalindromeCheck:
    ; set left pointer DI = &data[0]
    lea  di, [INBUF+2]        ; DI = start
    ; set right pointer SI = &data[LEN-1]
    mov  al, [INBUF+1]        ; AL = LEN
    mov  ah, 0
    mov  si, di               ; SI = base
    add  si, ax               ; SI = base + LEN
    dec  si                   ; SI = last valid char (index LEN-1)

PalLoop:
    ; stop if left >= right ? it's a palindrome
    mov  bx, di               ; BX = left
    cmp  bx, si               ; left ? right
    jae  IsPalindrome         ; crossed or met

    ; read both ends, normalize letters to uppercase by clearing bit 5
    mov  al, [di]             ; AL = left char
    and  al, 0DFh             ; 'a'..'z' -> 'A'..'Z' (others unchanged)
    mov  ah, [si]             ; AH = right char
    and  ah, 0DFh             ; normalize too
    cmp  al, ah               ; compare equal?
    jne  NotPalindrome        ; mismatch ? not palindrome

    inc  di                   ; move left inward
    dec  si                   ; move right inward
    jmp  PalLoop

IsPalindrome:
    mov  dx, offset MSG_PAL   ; print palindrome message
    mov  ah, 09h
    int  21h
    jmp  DoneAll

NotPalindrome:
    mov  dx, offset MSG_NPAL  ; print not-palindrome message
    mov  ah, 09h
    int  21h

DoneAll:
    mov  ax, 4C00h            ; exit to DOS
    int  21h
