; ============
; COM template
; ============
; In a .COM program, code and data share the same segment.
; Execution starts at offset 0100h, so we put a jump to skip
; over our data section and land on the code.

org 100h                 ; COM programs always start at 100h in memory

    jmp start             ; jump over the data area to the code

; -----------------
; Data definitions
; -----------------
DATA1 db 25h              ; define 1 byte with hex 25 (decimal 37)
DATA2 dw 1234h             ; define a 16-bit word = 1234h (low byte 34h, high byte 12h)
DATA3 db 0                 ; reserve 1 byte, initial value 0
DATA4 dw 0                 ; reserve 1 word (2 bytes), initial value 0000h
DATA5 dw 2345h, 6789h       ; define two words: 2345h (at offset DATA5), 6789h (at DATA5+2)

; ------------
; Code section
; ------------
start:
    ; In a .COM file, CS = DS at program start, but emu8086 sometimes
    ; requires you to set DS explicitly, so do it here:
    push cs                ; copy code segment value to stack
    pop  ds                ; pop it into DS ? DS = CS = segment at 100h

    ; ---- Basic register loads ----
    mov  al,25h            ; AL = 25h (decimal 37)
    mov  ax,2345h          ; AX = 2345h (AL=45h, AH=23h)
    mov  bx,ax              ; copy full 16-bit AX into BX, so BX = 2345h
    mov  cl,al              ; copy AL (45h) into CL

    ; ---- Accessing memory variables ----
    mov  al, [DATA1]        ; load byte at address DATA1 (25h) into AL
    mov  ax, [DATA2]        ; load word at address DATA2 (1234h) into AX
    mov  [DATA3], al        ; store AL (25h) into DATA3
    mov  [DATA4], ax        ; store AX (1234h) into DATA4

    ; ---- Address arithmetic with OFFSET ----
    mov  bx, offset DATA5   ; load the address of DATA5 into BX
    mov  ax, [bx]           ; read word at address DATA5 ? 2345h
    mov  di, 02h            ; DI = 2
    mov  ax, [bx+di]        ; read word at DATA5+2 ? 6789h
    mov  ax, [bx+0002h]     ; same as above, redundant
    mov  al, [di+2]         ; read a byte from DS:(DI+2)

; ---- Exit program back to DOS ----
    mov  ah,4Ch
    int  21h                ; terminate program with return code in AL
