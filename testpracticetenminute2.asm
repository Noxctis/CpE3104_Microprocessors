org 100h

jmp start


MYNAME db 'Chrys Sean T. Sevilla.',0
NAMELEN equ $-MYNAME ;

attr    db 0x9E          ; text attribute 9=light Blue E=Yellow


start:
    ; set DS and CS
    push cs
    pop  ds
    
    mov ax, 0B800h  ;video segment
    mov es, ax      ;extra segment for print

    ; calculate starting column store in DX based on length of name 
    mov al, 80          
    sub al, NAMELEN     
    shr al, 1           
    xor dx, dx          
    mov dl, al         

    ;video offset: calculates which row and column
    mov al, 12         
    xor ah, ah         
    mov bl, 80         
    mul bl              
    add ax, dx          
    shl ax, 1           
    mov di, ax          

    ; pointer to name
    mov si, offset MYNAME

PrintNameLoop:
    mov al, [si]
    cmp al, 0
    je Done
    mov es:[di], al
    mov al, [attr] ;lower byte
    mov es:[di+1], al
    add di, 2
    inc si
    jmp PrintNameLoop

Done:
    ret
    ;mov ax, 4C00h
    ;int 21h