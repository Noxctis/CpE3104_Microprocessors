org 100h
jmp start

attr       db 09Eh

string     db 'hello',0
strlen     equ $ - string - 1 ;minus 1 because of the null terminator

hdr1       db 'The strong string is: ',0
hdr2       db 'Output:',0

START_ROW  db 12
START_COL  db 30

ROW        db 0
COL        db 0

start:
    push cs
    pop  ds
    mov  ax, 0B800h
    mov  es, ax
    cld

    mov  al, [START_ROW]
    mov  [ROW], al
    mov  al, [START_COL]
    mov  [COL], al
    
    ;header + string
    call PrintResultLine
    lea  si, hdr1
    call PRINT_Z
    lea  si, string
    call PRINT_Z

    
    inc [ROW]

    ;output
    call PrintResultLine
    lea  si, hdr2
    call PRINT_Z

    
    inc [ROW]

    
    mov  cx, strlen+1

next_line:
    call PrintResultLine
    lea  si, string
    call PRINT_Z

    
    lea  si, string
    mov  bx, si
    add  bx, strlen-1
    mov  al, [bx]           
rshift:
    cmp  bx, si
    je   rot_done
    mov  dl, [bx-1]
    mov  [bx], dl
    dec  bx
    jmp  rshift
rot_done:
    mov  [si], al

    inc [ROW]         
    loop next_line
    
    ret


PRINT_Z:
    mov  ah, [attr]
pz_loop:
    lodsb         ;Load byte at DS:[SI] into AL. Update SI.
    cmp al, 0
    je   pz_done
    stosw         ;Store word in AX into ES:[DI]. Update DI.
    jmp  pz_loop
pz_done:
    ret


PrintResultLine:   ;Calculate DI Location
    mov  al, [ROW]          
    xor  dx, dx         
    mov  dl, [COL]          
    mov  ah, 0
    mov  bl, 80
    mul  bl                 
    add  ax, dx             
    shl  ax, 1              
    mov  di, ax
    ret
