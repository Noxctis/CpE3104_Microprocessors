ORG 100h

start:
    push cs
    pop  ds

    lea  dx, STRING
    mov  ah, 09h
    int  21h

    ; newline
    mov  dl, 13
    mov  ah, 02h
    int  21h
    mov  dl, 10
    mov  ah, 02h
    int  21h

    call REVERSE

    ; print reversed
    lea  dx, STRING
    mov  ah, 09h
    int  21h

    mov  ax, 4C00h
    int  21h

REVERSE:
    lea  si, STRING
    xor  cx, cx           ; CX = count

ScanPush:
    mov  al, [si]
    cmp  al, '$'
    je   PopBack
    push ax               
    inc  si
    inc  cx
    jmp  ScanPush

PopBack:
    lea  si, STRING       
WriteLoop:
    pop  dx               
    mov  [si], dl
    inc  si
    loop WriteLoop

    mov  byte ptr [si], '$' 
    ret

STRING db 'THIS IS A SAMPLE STRING$'
