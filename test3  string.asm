; ============
; COM template
; ============
org 100h                   

    jmp start:

; -----------------
; Data definitions
; -----------------
; no interrupts version: hardcoded input copied into DATAIN
BUFMAX  equ 80
inbuf   db BUFMAX          ; keep layout for compatibility
LENG    db 0               ; will hold actual length
DATAIN  db BUFMAX dup(0)   ; storage for working string
len     db 0               ; length of the input string
; hardcoded source string
SOURCE  db 'hello world',0
SRCLEN  equ $-SOURCE
; printing column and starting row
PRINT_COL db 10
PRINT_ROW db 10

; -----------------
; Code section
; -----------------
start:
; setup DS
    push cs
    pop  ds

    ; copy hardcoded SOURCE into DATAIN and set length
    lea si, SOURCE
    lea di, DATAIN
    mov cx, SRCLEN
    rep movsb
    mov [LENG], cl
    mov [len], cl

    ; set video segment for printing
    mov ax, 0B800h
    mov es, ax

    ; print the original string once
    mov al, [PRINT_ROW]
    mov dl, [PRINT_COL]
    call PrintCurrent

    ; if empty string, finish
    mov  cl, [len]
    mov  ch, 0
    jcxz Done

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
    mov [di], al

    ; advance print row for next rotation
    inc byte [PRINT_ROW]

    ; print this rotation (uses ES already)
    mov al, [PRINT_ROW]
    mov dl, [PRINT_COL]
    call PrintCurrent

    pop  cx                                          ; restore rotation counter
    loop RotateLoop                                  ; do this L times total

Done:
    ; exit by hanging (no interrupts)
    jmp $

; -----------------------------------------------
; PrintCurrent:
;   Writes the current string (len bytes) to STDOUT, then Carraige return New line.
;   Uses DOS INT 21h / AH=40h (Write to file/device).
; -----------------------------------------------
; PrintCurrent: write DATAIN (len bytes) to video memory at row=row (AL), col=DL
PrintCurrent:
    push ax
    push bx
    push si
    push di
    ; row in AL, col in DL
    mov ah, 0
    ; calculate DI in ES
    mov bl, 80
    mul bl        ; AX = row * 80
    add ax, dx    ; AX = row*80 + col
    shl ax, 1
    mov di, ax
    ; SI = DATAIN
    lea si, DATAIN
    mov cx, 0
    mov cl, [len]
PrintLoop:
    cmp cx, 0
    je PrintDone
    mov al, [si]
    mov es:[di], al
    mov al, [ATTR]
    mov es:[di+1], al
    add si, 1
    add di, 2
    dec cx
    jmp PrintLoop
PrintDone:
    pop di
    pop si
    pop bx
    pop ax
    ret