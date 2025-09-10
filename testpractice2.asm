org 100h

jmp start

MYNAME db 'Chrys Sean T. Sevilla.',0
NAMELEN equ $-MYNAME

attr    db 0x0F          ; text attribute (white on black)

start:

    push cs
    pop  ds
    mov ax, 0B800h
    mov es, ax

    
    mov al, 80
    sub al, NAMELEN
    shr al, 1
    mov cl, al
    xor ch, ch          

    
    mov dh, 12          

RowLoop:

    mov al, dh          
    xor ah, ah
    mov bl, 80
    mul bl              
    add ax, cx          
    shl ax, 1           
    mov di, ax

    mov si, offset MYNAME
PrintNameLoop:
    mov al, [si]
    cmp al, 0
    je NextRow
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp PrintNameLoop

NextRow:
    inc dh              
    cmp dh, 25          
    jb  RowLoop

    mov ax, 4C00h
    int 21h