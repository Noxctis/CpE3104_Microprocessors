org 100h

jmp start

; -----------------
; Data
; -----------------
HDR       db 'Input a string: ',0
OUTHDR    db 'Output:',0
STR       db 'Hello',0
ATTR      db 9Eh
START_ROW db 12
START_COL db 30

ROW       db 0
COL       db 0
LEN       db 0

; -----------------
; Code
; -----------------
start:
    push cs
    pop  ds
    mov  ax, 0B800h
    mov  es, ax

    ; init row/col
    mov al, [START_ROW]
    mov [ROW], al
    mov al, [START_COL]
    mov [COL], al

    ; compute LEN of STR
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
    call SET_POS
    lea  si, HDR
    call PRINT_Z
    lea  si, STR
    call PRINT_Z

    ; line 2: "Output:"
    mov al, [ROW]
    inc al
    mov [ROW], al
    call SET_POS
    lea  si, OUTHDR
    call PRINT_Z

    ; rotations: r = 0..LEN  (LEN+1 lines, ending with original)
    xor dx, dx          ; DL = r = 0, DH free
rot_lines_loop:
    ; next output row
    mov al, [ROW]
    inc al
    mov [ROW], al
    call SET_POS

    ; SI = STR, CX = LEN, DL = r
    lea si, STR
    mov cl, [LEN]
    mov ch, 0
    call PRINT_ROT

    inc dl
    cmp dl, [LEN]
    jbe rot_lines_loop

    ret

; -----------------
; Subroutines
; -----------------

; DI = ((ROW*80)+COL)*2
SET_POS:
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

; print zero-terminated string at ES:DI with ATTR
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

; PRINT_ROT
;  SI = &STR, CX = LEN, DL = r (0..LEN)
;  Prints exactly CX chars of rotation r
PRINT_ROT:
    push ax
    push dx
    push si

    xor dh, dh            ; i = 0
pr_loop:
    cmp dh, cl
    jae pr_done

    ; index = (r + i) mod LEN  -> in BL (with BH=0)
    mov al, dl            ; AL = r
    add al, dh            ; AL = r + i
    cmp al, cl
    jb  no_wrap
    sub al, cl
no_wrap:
    xor bh, bh
    mov bl, al            ; BX = index (0..LEN-1)

    mov al, [bx+si]       ; <- VALID addressing form
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
