org 100h

jmp start


MSG1 db 'Stored string = ',0
attr db 0x01
STORED db 'hello world',0
RESULT db 'The string contains ',0
SUFFIX db ' vowels',0


start:
    push cs
    pop ds
    mov ax, 0B800h  
    mov es, ax      

    
    xor dx, dx
    mov dl, 0
    mov al, 0
    xor ah, ah
    mov bl, 80
    mul bl
    add ax, dx
    shl ax, 1
    mov di, ax
    mov si, offset MSG1
PrintHeader:
    mov al, [si]
    cmp al, 0
    je AfterHeader
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp PrintHeader
AfterHeader:

    ; print STORED on same row after MSG1
    mov si, offset STORED
PrintStoredString:
    mov al, [si]
    cmp al, 0
    je CountVowels
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp PrintStoredString

CountVowels:
    lea si, STORED
    xor cx, cx        ; vowel count
VowelLoop:
    mov al, [si]
    cmp al, 0
    je PrintResultLine
    and al, 0DFh
    cmp al, 'A'
    je VowelInc
    cmp al, 'E'
    je VowelInc
    cmp al, 'I'
    je VowelInc
    cmp al, 'O'
    je VowelInc
    cmp al, 'U'
    je VowelInc
    jmp VowelSkip
VowelInc:
    inc cx
VowelSkip:
    inc si
    jmp VowelLoop

PrintResultLine:
    ; move to next line row 13, column 30
    mov al, 1
    mov dl, 0
    xor ah, ah
    mov bl, 80
    mul bl
    add ax, dx
    shl ax, 1
    mov di, ax

    ; print RESULT string
    mov si, offset RESULT
PrintResultLoop:
    mov al, [si]
    cmp al, 0
    je WriteVowelCount
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp PrintResultLoop

WriteVowelCount:
    mov al, cl
    add al, '0'
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al

    ; print suffix ' vowels'
    add di, 2
    mov si, offset SUFFIX
WriteSuffix:
    mov al, [si]
    cmp al, 0
    je ExitProg
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp WriteSuffix

ExitProg:
    ret
    ;mov ax, 4C00h
    ;int 21h
