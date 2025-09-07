; ============
; COM template
; ============
org 100h                   

    jmp start:

; -----------------
; Data definitions
; -----------------
prompt  db 'Input a string: $'
outhdr  db 13,10,'Output:',13,10,'$'   ; Carraige Return New Line + "Output:" + Carraige Return New Line
crlf    db 13,10,'$'

BUFMAX  equ 20
inbuf   db BUFMAX          ; [0] maximum length (20 trying variable) + 1
LENG    db ?               ; [1] actual number of characters read
DATAIN  db BUFMAX+1 dup(?)   ; [2] rest of bytes + Carraige Return

len     db 0               ; length of the input string

; -----------------
; Code section
; -----------------
start:
; setup DS
    push cs
    pop  ds

    ; prompt user
    mov  dx, offset prompt
    mov  ah, 09h
    int  21h

    ; read string using interrupt 0Ah - input of a string to DS:DX, first byte is buffer size, second byte is number of chars actually read. this function does not add '$' in the end of string.
    mov  dx, offset inbuf
    mov  ah, 0Ah
    int  21h

    ; store length into len since using int21h next byte is number of characters read
    mov  al, [LENG]
    mov  [len], al

    ; print header "Output:" + CRLF
    mov  dx, offset outhdr
    mov  ah, 09h
    int  21h

    ; print the original string once
    call PrintCurrent

    ; if empty string, finish
    mov  cl, [len]
    mov  ch, 0
    jcxz Done   ;Short Jump if CX register is 0.

; ---- Perform L right-rotations by 1 (so we end up back at the original) ----
RotateLoop:
    push cx                                          ; save remaining-rotations counter to stack

    ; base = inbuf + 2  (first data byte)
    lea  di, DATAIN
    mov  cx, 0
    mov  cl, [len]
    add  di, cx                                      ; di = base + L
    dec  di                                          ; di = base + L - 1  ? points at last char
    mov  al, [di]                                    ; save last char (we move it to front)

    ; Shift right by 1: copy bytes backward: memmove(base+1, base, L-1)
    mov  si, di                                      ; si = base + L - 1
    dec  si                                          ; si = base + L - 2  (source starts at old last-1)
    mov  cx, 0
    mov  cl, [len]
    dec  cx                                          ; cx = L - 1  (number of bytes to move)
    std                                              ; DF=1 so MOVSB goes backward (si--, di--)
    rep  movsb                                       ; copy (L-1) bytes from [si]?[di] shifting right by 1
    cld                                              ; DF=0 again (good practice for string ops?)

    ; Put saved last char at base[0]
    lea  di, DATAIN                               ; di = base (destination)
    ; ensure ES=DS for STOSB to hit our data segment
    
    push ds 
    pop es
    
    stosb                                              ; store AL at ES:DI (AL = saved last char), DI++

    ; print this rotation
    call PrintCurrent

    pop  cx                                          ; restore rotation counter
    loop RotateLoop                                  ; do this L times total

Done:
    mov  ax, 4C00h
    int  21h                                         ; exit to DOS (AL=0 status)

; -----------------------------------------------
; PrintCurrent:
;   Writes the current string (len bytes) to STDOUT, then Carraige return New line.
;   Uses DOS INT 21h / AH=40h (Write to file/device).
; -----------------------------------------------
PrintCurrent:
    mov  bx, 1                                       ; handle 1 = STDOUT
    lea  dx, DATAIN                                  ; DX = pointer to current string
    mov  cx, 0
    mov  cl, [len]                                   ; CX = length to write
    mov  ah, 40h
    int  21h                                         ; write CX bytes from DS:DX to STDOUT(SCREEN)

    mov  dx, offset crlf
    mov  ah, 09h
    int  21h                                         ; print CRLF via $-terminated string
    ret                                              ; back to caller