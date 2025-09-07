org 100h                   ; .COM program entry

jmp start:

; -------------------------
; Data
; -------------------------
prompt  db 'Input a string: $'
outhdr  db 13,10,'Output:',13,10,'$'   ; CRLF + "Output:" + CRLF
crlf    db 13,10,'$'

BUFMAX  equ 20
inbuf   db BUFMAX          ; [0] maximum chars to read
        db 0               ; [1] actual count (excludes CR)
        db BUFMAX dup(?)   ; [2..] characters (CR stored by DOS after them)

len     db 0               ; length of the input string

; -------------------------
; Code
; -------------------------
start:
    ; Ensure DS points to our code/data (safe for .COM)
    push cs
    pop  ds

    ; Prompt
    mov  dx, offset prompt
    mov  ah, 09h
    int  21h

    ; Read line (buffered input) - DOS INT 21h / AH=0Ah
    mov  dx, offset inbuf
    mov  ah, 0Ah
    int  21h

    ; Store length
    mov  al, [inbuf+1]
    mov  [len], al

    ; Print header "Output:" + CRLF
    mov  dx, offset outhdr
    mov  ah, 09h
    int  21h

    ; Print the original string once
    call PrintCurrent

    ; If empty string, finish
    mov  cl, [len]
    xor  ch, ch
    jcxz Done

; ---- Perform L rotations (so we end up printing the original again last) ----
RotateLoop:
    push cx

    ; base = inbuf + 2
    lea  di, [inbuf+2]
    mov  cx, 0
    mov  cl, [len]
    add  di, cx              ; di = base + L
    dec  di                  ; di = base + L - 1  (last char)
    mov  al, [di]            ; save last char in AL

    ; Shift right by 1: memmove(base+1, base, L-1) using STD + REP MOVSB
    mov  si, di              ; si = base + L - 1
    dec  si                  ; si = base + L - 2
    mov  cx, 0
    mov  cl, [len]
    dec  cx                  ; cx = L - 1
    std                      ; copy backwards
    rep  movsb               ; move (L-1) bytes one position to the right
    cld

    ; Put saved last char at base[0]
    lea  di, [inbuf+2]
    stosb                    ; [di] = AL; DF=0 so di increments (ok)

    ; Print this rotation
    call PrintCurrent

    pop  cx
    loop RotateLoop

Done:
    mov  ax, 4C00h
    int  21h

; -----------------------------------------------
; PrintCurrent:
;   Writes the current string (len bytes) to STDOUT, then CRLF.
;   Uses DOS INT 21h / AH=40h (Write to file/device).
; -----------------------------------------------
PrintCurrent:
    mov  bx, 1               ; STDOUT handle
    lea  dx, [inbuf+2]       ; pointer to string
    mov  cx, 0
    mov  cl, [len]           ; length
    mov  ah, 40h
    int  21h

    mov  dx, offset crlf     ; print CRLF via AH=09h ($-terminated)
    mov  ah, 09h
    int  21h
    ret
