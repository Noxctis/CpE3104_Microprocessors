org 100h

jmp start


MSG1 db 'Enter a digit (0-9): ',0
EVEN_MSG db 'The number is EVEN.',0
ODD_MSG  db 'The number is ODD.',0
attr db 0x9E


start:
    push cs
    pop ds
    mov ax, 0B800h  ;video segment
    mov es, ax      ;extra segment

    ;row 12, column 30
    xor dx, dx
    mov dl, 30
    mov al, 12
    xor ah, ah
    mov bl, 80
    mul bl
    add ax, dx
    shl ax, 1
    mov di, ax
    mov si, offset MSG1
    
.PrintPrompt:
    mov al, [si]
    cmp al, 0
    je .AfterPrompt
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp .PrintPrompt
                            
.AfterPrompt:

    ; Simulate ASCII input '4', echo it, then convert to numeric
    mov al, '5'      ; ASCII input
    mov bl, al       ; save ASCII in BL
    mov al, bl
    mov es:[di], al  ; echo character
    mov al, [attr]
    mov es:[di+1], al
    add di, 2

    ;
    sub bl, '0' ;ascii for 0  is 30 so minus 30 make it decimal
    test bl, 1 ;if lsb is 1 or 0 makes it odd or even
    jz .Even
    jmp .Odd

.Even:
    ; Display EVEN_MSG at row 13, column 30
    xor dx, dx
    mov dl, 30
    mov al, 13
    xor ah, ah
    mov bl, 80
    mul bl
    add ax, dx
    shl ax, 1
    mov di, ax
    mov si, offset EVEN_MSG

.PrintEven:
    mov al, [si]
    cmp al, 0
    je .Done
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp .PrintEven

.Odd:
    ; Display ODD_MSG at row 13, column 20
    xor dx, dx
    mov dl, 30
    mov al, 13
    xor ah, ah
    mov bl, 80
    mul bl
    add ax, dx
    shl ax, 1
    mov di, ax
    mov si, offset ODD_MSG

.PrintOdd:
    mov al, [si]
    cmp al, 0
    je .Done
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp .PrintOdd

.Done:
    ret
    ;mov ax, 4C00h
    ;int 21h
