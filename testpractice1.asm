org 100h

jmp start

; --- Data ---
MYNAME db 'Chrys Sean T. Sevilla.',0
NAMELEN equ $-MYNAME

attr    db 0x0F          ; text attribute (white on black)

; --- Code ---
start:
    ; set DS and ES
    push cs
    pop  ds
    mov ax, 0B800h
    mov es, ax

    ; Calculate starting column = (80 - NAMELEN) / 2  -> store in DX (low byte)
    mov al, 80
    sub al, NAMELEN
    shr al, 1
    xor dx, dx
    mov dl, al         ; DX = column

    ; Calculate video offset: ((row * 80) + column) * 2
    mov al, 14         ; choose row 14 for the centered name
    xor ah, ah
    mov bl, 80
    mul bl              ; AX = row * 80
    add ax, dx          ; AX = row*80 + column
    shl ax, 1           ; AX = byte offset
    mov di, ax          ; DI = starting video offset for name

    ; Source pointer to name
    mov si, offset MYNAME

.PrintNameLoop:
    mov al, [si]
    cmp al, 0
    je .Done
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp .PrintNameLoop

.Done:
    mov ax, 4C00h
    int 21h