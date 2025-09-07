
; You may customize this and other start-up templates; 
; The location of this template is c:\emu8086\inc\0_com_template.txt

org 100h

; ES -> video RAM, DS -> data segment
mov  ax, 0B800h
mov  es, ax

lea  si, [inbuf+2]        ; source: user data
mov  cl, [inbuf+1]        ; CL = length
xor  ch, ch               ; CX = length
xor  di, di               ; top-left cell
mov  ah, 07h              ; attribute (light gray on black)
cld

print_char:
    jcxz done             ; if length==0, stop
    lodsb                 ; AL = *SI++, next char
    stosw                 ; [ES:DI] = AX (char+attr), DI+=2
    loop print_char       ; CX--, repeat
done:

ret




