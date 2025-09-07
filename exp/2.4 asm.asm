org 100h

start:
    push cs
    pop  ds
    mov  ax, 0003h          ; 80x25 text mode
    int  10h
    jmp  MAIN_PANEL

; -------------------------------------------------
MAIN_PANEL:
    call CLEAR_SCREEN
    call DISP_MESS

INPUT_LOOP:
    ; Read ONE key WITH ECHO at current cursor (DOS)
    mov  ah, 01h
    int  21h                ; AL = ASCII, echoed

    ; Uppercase ONLY letters (don't touch digits)
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

    ; invalid key: erase echo (BS, space, BS) and retry
    mov  ah, 02h
    mov  dl, 08h            ; backspace
    int  21h
    mov  dl, ' '            ; overwrite
    int  21h
    mov  dl, 08h            ; backspace again
    int  21h
    jmp  INPUT_LOOP

; -------------------------------------------------
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

; -------------------------------------------------
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

    ; "ENTER CHOICE: " at (14,15) — leave cursor right after it
    mov  ah, 02h
    mov  dh, 14
    mov  dl, 15h
    int  10h
    mov  ah, 09h
    mov  dx, OFFSET CHOICE_MSG   ; DOS leaves cursor at end of this string
    int  21h
    ret

; -------------------------------------------------
; HORIZONTAL STRIPES (4×6 rows; row 24 painted to match)
; -------------------------------------------------
HORIZONTAL:
    call CLEAR_SCREEN

    ; rows 0..5  (white on black, 0Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 0Fh
    mov  cx, 0000h
    mov  dx, 054Fh
    int  10h

    ; rows 6..11 (white on magenta, 5Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 5Fh
    mov  cx, 0600h
    mov  dx, 0B4Fh
    int  10h

    ; rows 12..17 (white on brown˜yellow, 6Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 6Fh
    mov  cx, 0C00h
    mov  dx, 114Fh
    int  10h

    ; rows 18..23 (white on blue, 1Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 1Fh
    mov  cx, 1200h
    mov  dx, 174Fh
    int  10h

    ; row 24 also blue
    mov  ah, 06h
    xor  al, al
    mov  bh, 1Fh
    mov  cx, 1800h
    mov  dx, 184Fh
    int  10h

    ; ---- HARD-CODED position: centered in blue band (row 21, col 27) ----
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 21                ; row inside the blue stripe
    mov  dl, 27                ; (80 - 26)/2 = 27 for "Press any key to continue."
    int  10h
    mov  ah, 09h               ; DOS print $-string (uses current attr)
    mov  dx, OFFSET KEY_PROMPT
    int  21h

    ; wait key and return
    mov  ah, 00h
    int  16h
    jmp  MAIN_PANEL

; -------------------------------------------------
; VERTICAL STRIPES (4×20 cols)
; -------------------------------------------------
VERTICAL:
    call CLEAR_SCREEN

    ; cols 0..19 (0Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 0Fh
    mov  cx, 0000h
    mov  dx, 1813h
    int  10h

    ; cols 20..39 (5Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 5Fh
    mov  cx, 0014h
    mov  dx, 1827h
    int  10h

    ; cols 40..59 (6Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 6Fh
    mov  cx, 0028h
    mov  dx, 183Bh
    int  10h

    ; cols 60..79 (1Fh)
    mov  ah, 06h
    xor  al, al
    mov  bh, 1Fh
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

; -------------------------------------------------
QUIT:
    mov  ax, 4C00h
    int  21h

; -------------------------------------------------
; STRINGS
; -------------------------------------------------
MENU_TEXT     db 'MENU', '$'
FIRST_CHOICE  db '1 - HORIZONTAL STRIPES', '$'
SECOND_CHOICE db '2 - VERTICAL STRIPES', '$'
QUIT_MSG      db 'Q - QUIT', '$'
CHOICE_MSG    db 'ENTER CHOICE: ', '$'   ; (note trailing space)
KEY_PROMPT    db 'Press any key to continue.', '$'
