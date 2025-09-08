org 100h

jmp start

; --- Data ---
MSG1 db 'Enter a digit (0-9):',0
EVEN_MSG db 'The number is EVEN.',0
ODD_MSG  db 'The number is ODD.',0
attr db 0x9E

; --- Code ---
start:
    push cs
    pop ds
    mov ax, 0B800h
    mov es, ax

    ; print prompt at row 10, col 30
    mov al, 10
    mov dl, 30
    call CalcDI
    mov si, offset MSG1
    call PrintString

    ; simulate ASCII input '5', echo it
    mov al, '5'
    mov bl, al         ; save ASCII in BL
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2

    ; convert ASCII to numeric and test
    sub bl, '0'
    test bl, 1
    jz .Even
    jmp .Odd

.Even:
    mov al, 12
    mov dl, 30
    call CalcDI
    mov si, offset EVEN_MSG
    call PrintString
    jmp .Done

.Odd:
    mov al, 12
    mov dl, 30
    call CalcDI
    mov si, offset ODD_MSG
    call PrintString

.Done:
    mov ax, 4C00h
    int 21h

; -----------------------
; Helpers
; -----------------------
; CalcDI: inputs AL=row, DL=col -> returns DI = ((row*80)+col)*2
CalcDI:
    xor ah, ah
    mov bl, 80
    mul bl        ; AX = row * 80
    add ax, dx    ; AX = row*80 + column
    shl ax, 1     ; *2 for bytes
    mov di, ax
    ret

; PrintString: copies zero-terminated string at SI to ES:DI (char+attr)
PrintString:
    mov al, [si]
    cmp al, 0
    je .PS_done
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp PrintString
.PS_done:
    ret
