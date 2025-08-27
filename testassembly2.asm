
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

mov ax,0b800h
mov es,ax
mov di,0 

mov cx,1

disp:
    mov dl, 'A'
    MOV ES:[DI], DL
    inc di
    loop disp
    
int 20h

ret




