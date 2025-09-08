org 100h

jmp start


MSG1 db 'Stored string = ',0
EVEN_MSG db 'The number is EVEN.',0
ODD_MSG  db 'The number is ODD.',0
VALUE db '7',?
attr db 0x9E
STORED db 'power of the people',0
RESULT db 'The string contains ',0
SUFFIX db ' vowels',0


start:
    push cs
    pop ds
    mov ax, 0B800h  ;video segment
    mov es, ax      ;extra segment

    ;row 12, column 30 - print MSG1
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
.PrintMsg1:
    mov al, [si]
    cmp al, 0
    je .AfterMsg1
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp .PrintMsg1
.AfterMsg1:

    ; print STORED on same row after MSG1
    mov si, offset STORED
.PrintStored:
    mov al, [si]
    cmp al, 0
    je .CountVowels
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp .PrintStored

.CountVowels:
    lea si, STORED
    xor cx, cx        ;
.VLoop: 
    mov al, [si]
    cmp al, 0
    je .PrintResult
    ;and al, 0DFh 
    cmp al, 'a'
    je .IncV
    cmp al, 'e'
    je .IncV
    cmp al, 'i'
    je .IncV
    cmp al, 'o'
    je .IncV
    cmp al, 'u'
    je .IncV
    jmp .SkipV
    
.IncV:
    inc cx
.SkipV:
    inc si
    jmp .VLoop

.PrintResult:
    ; move to next line row 13, column 30
    mov al, 13
    mov dl, 30
    xor ah, ah
    mov bl, 80
    mul bl
    add ax, dx
    shl ax, 1
    mov di, ax

    ; print RESULT string
    mov si, offset RESULT
.PResLoop:
    mov al, [si]
    cmp al, 0
    je .WriteCount
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp .PResLoop

.WriteCount:
    mov al, cl
    add al, '0'
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al

    ; print suffix ' vowels'
    add di, 2
    mov si, offset SUFFIX
.WriteSuffix:
    mov al, [si]
    cmp al, 0
    je .Done
    mov es:[di], al
    mov al, [attr]
    mov es:[di+1], al
    add di, 2
    inc si
    jmp .WriteSuffix

.Done:
    ret
    ;mov ax, 4C00h
    ;int 21h
