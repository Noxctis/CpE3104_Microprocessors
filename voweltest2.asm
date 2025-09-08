org 100h

jmp start

; three db style: stored string, result message, attribute
STORED_STR db 'hello world',0
MSG_HDR    db 13,10,'String contains ',0
ATTR       db 0x0F

start:
    push cs
    pop ds
    ; set ES to video memory
    mov ax,0B800h
    mov es,ax

    ; print stored string at row 10, col 10
    mov al,10
    mov dl,10
    call CalcDI
    lea si, STORED_STR
.PrintStored:
    mov al,[si]
    cmp al,0
    je .AfterStored
    mov es:[di],al
    mov al,[ATTR]
    mov es:[di+1],al
    add di,2
    inc si
    jmp .PrintStored
.AfterStored:

    ; count vowels in STORED_STR
    lea si, STORED_STR
    xor cx,cx        ; vowel count
CountLoop:
    mov al,[si]
    cmp al,0
    je CountDone
    and al,0DFh
    cmp al,'A'
    je IncV
    cmp al,'E'
    je IncV
    cmp al,'I'
    je IncV
    cmp al,'O'
    je IncV
    cmp al,'U'
    je IncV
    jmp Skip
IncV:
    inc cx
Skip:
    inc si
    jmp CountLoop
CountDone:

    ; print header and count at row 12, col 10
    mov al,12
    mov dl,10
    call CalcDI
    lea si, MSG_HDR
.PrintHdr:
    mov al,[si]
    cmp al,0
    je .PrintCount
    mov es:[di],al
    mov al,[ATTR]
    mov es:[di+1],al
    add di,2
    inc si
    jmp .PrintHdr
.PrintCount:
    mov al, cl
    add al,'0'
    mov es:[di],al
    mov al,[ATTR]
    mov es:[di+1],al

    ; hang
    jmp $

; helper: CalcDI (AL=row, DL=col) -> DI byte offset in ES
CalcDI:
    push bx
    mov ah,0
    mov bl,80
    mul bl
    add ax,dx
    shl ax,1
    mov di,ax
    pop bx
    ret
