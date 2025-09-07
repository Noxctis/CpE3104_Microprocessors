org 100h                    
    
    jmp start:                   

; -----------------
; Data definitions
; -----------------
msgC   db 'C = ((B*D) + (A/B) - (A - B + E)) = $'
msgX   db 13,10,'X = (Y + Z*W) / 100 = $'
crlf   db 13,10,'$'

; -----------------
; Code section
; -----------------
start:
    ; DS = CS (tiny model setup)
    push cs
    pop  ds

    ; ================================================================
    ; Registers as variables (pick any initial values you want)
    ; Chosen so C = 2 and X = 2:
    ; A=20, B=5, D=3, E=2  -> C = 2
    ; Y=50, Z=10, W=15     -> X = 2
    ; ================================================================
    mov  si, 20             ; SI = A
    mov  bx, 5              ; BX = B
    mov  di, 3              ; DI = D
    mov  bp, 2              ; BP = E

    ; ============================
    ; C = (B*D) + (A/B) - (A - B + E)
    ; ============================

    ; term1 = B*D
    mov  ax, bx             ; AX = B
    mul  di                 ; DX:AX = AX * D
    mov  cx, ax             ; CX = term1 (fits low word with these values)

    ; term2 = A/B  (unsigned divide)
    mov  ax, si             ; AX = A
    xor  dx, dx             ; DX:AX = A
    div  bx                 ; AX = A / B
    add  cx, ax             ; CX += term2

    ; term3 = (A - B + E)
    mov  ax, si             ; AX = A
    sub  ax, bx             ; AX = A - B
    add  ax, bp             ; AX = A - B + E

    ; C = term1 + term2 - term3
    sub  cx, ax             ; CX = C

    ; ---- Print "C = " then C (preserve AX across INT 21h) ----
    mov  dx, offset msgC
    mov  ah, 09h
    int  21h

    mov  ax, cx             ; AX = C
    call print_ax_dec       ; print C in decimal

    mov  dx, offset crlf
    mov  ah, 09h
    int  21h

    ; ============================
    ; X = (Y + Z*W) / 100
    ; Reuse registers as new variables
    ; ============================
    mov  si, 50             ; SI = Y
    mov  bx, 30             ; BX = Z
    mov  di, 15             ; DI = W

    ; numerator = Y + Z*W
    mov  ax, bx             ; AX = Z
    mul  di                 ; DX:AX = Z * W
    add  ax, si             ; AX = Y + (Z*W)   (fits 16-bit here)
    xor  dx, dx             ; prepare DX:AX for 16-bit DIV

    mov  cx, 100            ; divisor
    div  cx                 ; AX = (Y + Z*W) / 100  -> this is X

    ; ---- Print "X = " then X (save AX before INT 21h) ----
    push ax                 ; save X
    mov  dx, offset msgX
    mov  ah, 09h
    int  21h
    pop  ax                 ; restore X
    call print_ax_dec

    mov  dx, offset crlf
    mov  ah, 09h
    int  21h

    ; ---- Exit ----
    mov  ax, 4C00h
    int  21h

; -----------------------------------------
; print_ax_dec
; Prints AX as unsigned decimal (0..65535)
; Uses INT 21h / AH=02h to emit digits
; Clobbers: AX,BX,CX,DX (preserved via stack)
; -----------------------------------------
print_ax_dec:
    push bx
    push cx
    push dx

    cmp  ax, 0
    jne  conv
    mov  dl, '0'
    mov  ah, 02h
    int  21h
    jmp  done_print

conv:
    mov  bx, 10
    xor  cx, cx            ; digit count = 0

push_digits:
    xor  dx, dx
    div  bx                ; AX = AX/10, DX = remainder (0..9)
    push dx                ; save digit
    inc  cx
    test ax, ax
    jnz  push_digits

print_digits:
    pop  dx
    add  dl, '0'
    mov  ah, 02h
    int  21h
    loop print_digits

done_print:
    pop  dx
    pop  cx
    pop  bx
    ret
