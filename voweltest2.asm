org 100h

jmp start

PROMPT    db 'String contains:',0
STORED    db 'hello world',0
RESULT    db 'The number of vowels is ',0
ATTR       db 0x9E

start:
    push cs
    pop ds
    mov ax,0B800h
    mov es,ax    ;extra segment video buffer
                          
    ; print prompt at row 12, col 30
    mov al,12
    mov dl,30
    call CalcDI
    lea si, PROMPT

.PrintPrompt:
    mov al,[si]
    cmp al,0
    je .AfterPrompt
    mov es:[di],al
    mov al,[ATTR]
    mov es:[di+1],al
    add di,2
    inc si
    jmp .PrintPrompt

.AfterPrompt:

    ; print stored string at row 12, col 47
    mov al,12
    mov dl,47
    call CalcDI
    lea si, STORED
        ; print STORED at DI
     .PrintStored:
         mov al,[si]
         cmp al,0
         je .AfterStoredPrint
         mov es:[di],al
         mov al,[ATTR]
         mov es:[di+1],al
         add di,2
         inc si
         jmp .PrintStored
     .AfterStoredPrint:

    ; count vowels in STORED
    lea si, STORED
    xor cx,cx        ; vowel count reset

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
    ; print RESULT at row 13, col 10
    mov al,13
    mov dl,30
    call CalcDI
    lea si, RESULT

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

    ret

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
