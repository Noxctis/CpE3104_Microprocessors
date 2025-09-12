org 100h

start:
    push cs
    pop  ds
    mov  ax, 0003h          ; 80x25 text mode
    int  10h
    jmp  MAIN_PANEL


MAIN_PANEL:
    call CLEAR_SCREEN
    call DISP_MESS

INPUT_LOOP:

    mov  ah, 01h
    int  21h                


    cmp  al, 'a'
    jb   not_letter
    cmp  al, 'z'
    ja   not_letter
    and  al, 0DFh
not_letter:

    cmp  al, '1'
    je   HORIZONTAL
    cmp  al, '2'
    je   VERTICAL
    cmp  al, 'Q'
    je   QUIT

    mov  ah, 02h
    mov  dl, 08h            
    int  21h
    mov  dl, ' '            
    int  21h
    mov  dl, 08h            
    int  21h
    jmp  INPUT_LOOP


CLEAR_SCREEN:
    mov  ah, 06h
    mov  al, 00h            ; clear window
    mov  bh, 1Eh            ; attr: blue bg (1), yellow fg (E)
    mov  cx, 0000h          ; (row 0, col 0)
    mov  dx, 184Fh          ; (row 24, col 79)
    int  10h
    ; home cursor
    mov  ah, 02h
    xor  bx, bx
    xor  dx, dx
    int  10h
    ret

DISP_MESS:
    ; "MENU" at (3,25)
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 03h
    mov  dl, 25h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET MENU_TEXT
    int  21h

    ; 1 - HORIZONTAL STRIPES at (6,0)
    mov  ah, 02h
    mov  dh, 06h
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET FIRST_CHOICE
    int  21h

    ; 2 - VERTICAL STRIPES at (7,0)
    mov  ah, 02h
    mov  dh, 07h
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET SECOND_CHOICE
    int  21h

    ; Q - QUIT at (10,0)
    mov  ah, 02h
    mov  dh, 10
    mov  dl, 00h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET QUIT_MSG
    int  21h

    mov  ah, 02h
    mov  dh, 14
    mov  dl, 15h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET CHOICE_MSG   
    int  21h
    ret

HORIZONTAL:
    call CLEAR_SCREEN

    ; rows 0..5  (white on black, 0Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 0Fh
    mov  cx, 0000h   ; TOP ROW = 0 LEFT COL = 0
    mov  dx, 054Fh   ; BOTTOM ROW = 5 COLUMN = 79 
    int  10h

    ; rows 6..11 (white on magenta, 5Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 0DFh
    mov  cx, 0600h    
    mov  dx, 0B4Fh    
    int  10h

    ; rows 12..17 (white on yellow, 6Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 0EFh ; 6F for dark yellow
    mov  cx, 0C00h
    mov  dx, 114Fh
    int  10h

    ; rows 18..23 (white on blue, 1Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 90h  ;10 for dark white on blue text
    mov  cx, 1200h
    mov  dx, 174Fh
    int  10h

    ; row 24 also blue
    mov  ah, 06h
    xor  al, al
    mov  bh, 90h; white on blue text
    mov  cx, 1800h
    mov  dx, 184Fh
    int  10h

    
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 21                
    mov  dl, 27                
    int  10h
    mov  ah, 09h               
    mov  dx, OFFSET KEY_PROMPT
    int  21h


    mov  ah, 00h
    int  16h
    jmp  MAIN_PANEL

VERTICAL:
    call CLEAR_SCREEN

    ; cols 0..19 (0Fh)  black
    mov  ah, 06h
    xor  al, al
    mov  bh, 0Fh
    mov  cx, 0000h
    mov  dx, 1813h
    int  10h

    ; cols 20..39 (5Fh)  magenta
    mov  ah, 06h
    xor  al, al
    mov  bh, 0D0h ;5DF for dark magenta on white
    mov  cx, 0014h
    mov  dx, 1827h
    int  10h
                           
    ; cols 40..59 (6Fh)    yellow
    mov  ah, 06h
    xor  al, al
    mov  bh, 0E0h  ;E for yellow 0 for black / F for white
    mov  cx, 0028h
    mov  dx, 183Bh
    int  10h

    ; cols 60..79 (1Fh)     blue
    mov  ah, 06h
    xor  al, al
    mov  bh, 9Fh ;1F for dark blue
    mov  cx, 003Ch
    mov  dx, 184Fh
    int  10h

    ; place message at (12,27) for nice centering in vertical view
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 12
    mov  dl, 27
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET KEY_PROMPT
    int  21h

    mov  ah, 00h
    int  16h
    jmp  MAIN_PANEL


QUIT:
    mov  ax, 4C00h
    int  21h


MENU_TEXT     db 'MENU', '$'
FIRST_CHOICE  db '1 - HORIZONTAL STRIPES', '$'
SECOND_CHOICE db '2 - VERTICAL STRIPES', '$'
QUIT_MSG      db 'Q - QUIT', '$'
CHOICE_MSG    db 'ENTER CHOICE: ', '$'   
KEY_PROMPT    db 'Press any key to continue.', '$'
