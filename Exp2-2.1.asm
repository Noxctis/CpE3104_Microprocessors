; ============
; COM template
; ============
; In a .COM program, code and data share the same segment.
; Execution starts at offset 0100h, so we put a jump to skip
; over our data area and land on the code.

org 100h

    jmp _START                ; jump over data to the code

; -----------------
; Data definitions
; -----------------
DATA1 dw 0000H                ; destination word (will get 1234h)
DATA2 dw 0000H                ; destination word (will get 4567h)
DATA3 dw 1234H                ; source word #1
DATA4 dw 4567H                ; source word #2

; -----------------
; Code section
; -----------------
_START:
    ; make DS = CS (for .COM programs)
    push cs
    pop  ds

    mov bx, 0                 ; base register = 0
    mov si, 0000h             ; index = 0

    ; ---- copy first source word into DATA1 ----
    mov ax, [bx + si + DATA3] ; load word at DATA4 (1234h) into AX
    mov [bx + si + DATA1], ax ; store into DATA1

    ; ---- copy second source word into DATA2 ----
    ADD si, 0002h             ; index = 2
    mov ax, [bx + si + DATA3] ; load word at DATA4+2 (4567h)
    mov [bx + si + DATA1], ax ; store into DATA1+2 = DATA2

    ; ---- program exit ----
    mov ax, 4C00h
    int 21h
