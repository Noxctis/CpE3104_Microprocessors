
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; add your code here

mov ah,2
mov dl,'A' 
int 21h


mov ah,2
mov dl,'B' 
int 21h
     
     
int 20h     
ret




