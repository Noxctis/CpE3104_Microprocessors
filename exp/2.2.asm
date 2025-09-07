org 100h
    
    jmp start:

; -----------------
; Data definitions
; -----------------
msgA  db 'a) AL to UPPER (AND 0DFh): ', '$'
msgB  db 13,10, 'b) BL to lower (OR 20h): ', '$'
msgC  db 13,10, 'c) binary 0..9 -> ASCII (OR 30h): ', '$'
arrow db ' -> $'
crlf  db 13,10, '$'
MSG_STR db 13,10,'Enter a string (max 20): $'
BUFMAX  equ 20
INBUF   db BUFMAX            ; [0] max chars user 
STRLEN  db 0                 ; [1] actual count typed
STRDATA db BUFMAX+1 dup(?)   ; [2..] data bytes             


; -----------------
; Code section
; -----------------
start:
    ; .COM setup: DS = CS
    push cs
    pop  ds

; -------------------------
; a) Convert AL to UPPER
; -------------------------
    mov  dx, offset msgA
    mov  ah, 09h
    int  21h

    mov  ah, 01h                 ; read one character (echoed), AL = char
    int  21h

    ; print " -> " but PROTECT AX so AL doesn't get trashed
    push ax                      ; save AL
    mov  dx, offset arrow
    mov  ah, 09h
    int  21h
    pop  ax                      ; restore AL

    ; uppercase by clearing bit 5
    and  al, 0DFh                ; 'h' (68h) -> 'H' (48h)

    ; print converted
    mov  dl, al
    mov  ah, 02h
    int  21h

    ; newline
    mov  dx, offset crlf
    mov  ah, 09h
    int  21h

; -------------------------
; b) Convert BL to lower
; -------------------------
    mov  dx, offset msgB
    mov  ah, 09h
    int  21h

    mov  ah, 01h                 ; read one character (echoed)
    int  21h                     ; AL = char
    mov  bl, al                  ; BL holds the variable for part (b)

    ; arrow
    mov  dx, offset arrow
    mov  ah, 09h
    int  21h

    ; BL := lowercase by setting bit 5
    or   bl, 20h                 ; set bit 5 ? upper ? lower

    ; print converted
    mov  dl, bl
    mov  ah, 02h
    int  21h

    ; newline
    mov  dx, offset crlf
    mov  ah, 09h
    int  21h

; -------------------------------------------------
; c) Convert binary 0..9 to ASCII digit (OR 30h)
; -------------------------------------------------
    mov  dx, offset msgC
    mov  ah, 09h
    int  21h

    mov al,7
    ;mov  ah, 01h                 ; read one character (echoed)
    ;int  21h                     ; AL = char
    mov  cl, al                  ; BL holds the variable for part (b)
    
    or   al, 30h                 ; force high nibble = 0011b ? ASCII '0'..'9'
    ;add  al, 30h ;same logic                             ; (assumes CL in 0..9; >9 would NOT be a digit)

    ; print the ASCII digit
    mov  dl, al
    mov  ah, 02h
    int  21h

    ; newline
    mov  dx, offset crlf
    mov  ah, 09h
    int  21h

; ---------------------------------------------
; d) Reverse case for a whole string (letters only)
; ---------------------------------------------

    ; prompt for a string
    mov dx, offset MSG_STR      ; "$"-terminated prompt
    mov ah, 09h
    int 21h

    ; read line using AH=0Ah (buffered input)
    mov dx, offset INBUF        ; DS:DX -> [max][len][data...]
    mov ah, 0Ah
    int 21h                     ; STRLEN filled; STRDATA has chars; CR after them

    ; print " -> "
    mov dx, offset ARROW
    mov ah, 09h
    int 21h

    ; toggle case IN-PLACE over STRDATA[0..len-1]
    lea si, [INBUF+2]           ; SI = &STRDATA[0]
    mov cl, [INBUF+1]           ; CL = len
    xor ch, ch

toggle_loop:
    jcxz toggle_done            ; length exhausted?
    lodsb                       ; AL = *SI++, get next byte

    ; classify: letter if (AL AND 0DFh) in 'A'..'Z'
    mov bl, al
    and bl, 0DFh                ; force uppercase for the test
    cmp bl, 'A'
    jb  store_byte              ; below 'A' ? not a letter
    cmp bl, 'Z'
    ja  store_byte              ; above 'Z' ? not a letter
    xor al, 20h                 ; it is a letter ? flip bit 5 (reverse case)

store_byte:
    mov [si-1], al              ; write back at the same position
    loop toggle_loop

toggle_done:
    ; print TOGGLED string (same length)
    mov bx, 1
    lea dx, [INBUF+2]
    mov cl, [INBUF+1]
    xor ch, ch
    mov ah, 40h
    int 21h

    ; newline
    mov dx, offset CRLF
    mov ah, 09h
    int 21h

; exit to DOS
    mov  ax, 4C00h
    int  21h
