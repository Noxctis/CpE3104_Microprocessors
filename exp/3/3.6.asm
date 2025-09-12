ORG 100h

start:
    ; make DS point to our data
    push cs
    pop  ds

    ; print original
    lea  dx, STRING
    mov  ah, 09h
    int  21h

    ; newline (optional)
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

    ; exit
    mov  ax, 4C00h
    int  21h


; Reverse STRING in place (STRING is '$'-terminated)
REVERSE:
    lea  si, STRING
    xor  cx, cx           ; CX = count

ScanPush:
    mov  al, [si]
    cmp  al, '$'
    je   PopBack
    push ax               ; push char (AL), AH don't care
    inc  si
    inc  cx
    jmp  ScanPush

PopBack:
    lea  si, STRING       ; write from start
WriteLoop:
    pop  dx               ; DL = char
    mov  [si], dl
    inc  si
    loop WriteLoop

    mov  byte ptr [si], '$' ; restore terminator
    ret

STRING db 'THIS IS A SAMPLE STRING$'
