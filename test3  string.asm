org 100h

jmp start

HDR       db 'Stored String: ',0
OUTHDR    db 'Output:',0
STR       db 'sad',0
ATTR      db 9Eh
START_ROW db 12
START_COL db 30

ROW       db 0
COL       db 0
LEN       db 0

start:
    push cs
    pop  ds
    mov  ax, 0B800h ; video segment
    mov  es, ax     ; extra segment

    mov al, [START_ROW]
    mov [ROW], al
    mov al, [START_COL]
    mov [COL], al

    lea si, STR
    xor cx, cx
count_len:
    lodsb
    cmp al, 0
    je  len_done
    inc cx
    jmp count_len
len_done:
    mov [LEN], cl

    ; line 1: "Input a string: " + "Hello"
    call SETDI
    lea  si, HDR
    call PRINT_Z
    lea  si, STR
    call PRINT_Z

    ; line 2: "Output:"
    mov al, [ROW]
    inc al
    mov [ROW], al
    call SETDI
    lea  si, OUTHDR
    call PRINT_Z

    xor dx, dx          
rot_lines_loop:
    ; next output row
    mov al, [ROW]
    inc al
    mov [ROW], al
    call SETDI

    lea si, STR
    mov cl, [LEN]
    mov ch, 0
    call PRINT_ROT

    inc dl
    cmp dl, [LEN]
    jbe rot_lines_loop

    ret


SETDI:
    push ax
    push bx
    push dx
    xor ax, ax
    mov al, [ROW]
    mov bl, 80
    mul bl
    xor dx, dx
    mov dl, [COL]
    add ax, dx
    shl ax, 1
    mov di, ax
    pop dx
    pop bx
    pop ax
    ret

; print string
PRINT_Z:
    push ax
pz_loop:
    lodsb
    cmp al, 0
    je  pz_done
    mov es:[di], al
    mov al, [ATTR]
    mov es:[di+1], al
    add di, 2
    jmp pz_loop
pz_done:
    pop ax
    ret


PRINT_ROT:
    push ax
    push dx
    push si

    xor dh, dh            
pr_loop:
    cmp dh, cl
    jae pr_done
    mov al, dl            
    add al, dh            
    cmp al, cl
    jb  no_wrap
    sub al, cl
no_wrap:
    xor bh, bh
    mov bl, al            

    mov al, [bx+si]       
    mov es:[di], al
    mov al, [ATTR]
    mov es:[di+1], al
    add di, 2

    inc dh
    jmp pr_loop

pr_done:
    pop si
    pop dx
    pop ax
    ret
