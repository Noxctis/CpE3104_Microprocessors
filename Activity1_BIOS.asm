org 100h                          ; .COM program

start:
    push cs
    pop  ds

    mov  ax, 0003h                ; set 80x25 text mode
    int  10h

    jmp  MAIN_PANEL

; -------------------------------------------------
; MAIN PANEL / MENU
; -------------------------------------------------
MAIN_PANEL:
    call CLEAR_SCREEN
    call INIT_MOUSE

    ; print menu lines using DISP_MESS (DX = OFFSET string)
    ; "University..." and lab heading near top
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 01    ; row 1
    mov  dl, 10    ; column 10 (adjust for aesthetics)
    int  10h

    mov  ah, 02h
    mov  bh, 0
    mov  dh, 02    ; row 2
    mov  dl, 02
    int  10h

    ; menu choices
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 06
    mov  dl, 00
    int  10h
    mov  dx, OFFSET FIRST_CHOICE
    call DISP_MESS

    mov  ah, 02h
    mov  bh, 0
    mov  dh, 07
    mov  dl, 00
    int  10h
    mov  dx, OFFSET SECOND_CHOICE
    call DISP_MESS

    mov  ah, 02h
    mov  bh, 0
    mov  dh, 08
    mov  dl, 00
    int  10h
    mov  dx, OFFSET THIRD_CHOICE
    call DISP_MESS

    mov  ah, 02h
    mov  bh, 0
    mov  dh, 10
    mov  dl, 00
    int  10h
    mov  dx, OFFSET QUIT_MSG
    call DISP_MESS

    ; "ENTER CHOICE:" prompt
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 14
    mov  dl, 15
    int  10h
    mov  dx, OFFSET CHOICE_MSG
    call DISP_MESS

; -------------------------------------------------
INPUT_LOOP:
    ; check keyboard first (BIOS)
    mov  ah, 01h
    int  16h
    jz   CHECK_MOUSE        ; no key -> check mouse

    mov  ah, 00h
    int  16h                ; read key
    cmp  al, '1'
    je   HORIZONTAL
    cmp  al, '2'
    je   VERTICAL
    cmp  al, '3'
    je   CHECKERED
    cmp  al, 'q'
    je   QUIT
    cmp  al, 'Q'
    je   QUIT
    jmp  INPUT_LOOP

CHECK_MOUSE:
    ; poll mouse (requires driver): INT 33h fn=03h
    mov  ax, 0003h
    int  33h                 ; BX=buttons, CX=Xpx, DX=Ypx
    test bx, 0001b
    jz   INPUT_LOOP          ; no left button -> re-poll

    ; convert pixels to text cell (divide by 8)
    mov  ax, cx
    shr  ax, 1
    shr  ax, 1
    shr  ax, 1               ; AX = col 0..79 (unused, but kept)
    mov  ax, dx
    shr  ax, 1
    shr  ax, 1
    shr  ax, 1               ; AX = row 0..24
    ; hit-test rows where items are printed
    cmp  ax, 6
    je   HORIZONTAL
    cmp  ax, 7
    je   VERTICAL
    cmp  ax, 8
    je   CHECKERED
    cmp  ax, 10
    je   QUIT
    jmp  INPUT_LOOP

; -------------------------------------------------
; CLEAR_SCREEN - clear whole screen with blue bg and yellow fg
; Input: none
; Uses BIOS INT 10h AH=06 (scroll window)
; -------------------------------------------------
CLEAR_SCREEN:
    mov  ah, 06h                  ; scroll/window
    mov  al, 00h                  ; clear entire window
    mov  bh, 1Eh                  ; attribute: blue bg (1), bright yellow fg (E)
    mov  cx, 0000h                ; top-left (row=0,col=0)
    mov  dx, 184Fh                ; bottom-right (row=24,col=79)
    int  10h

    ; home cursor
    mov  ah, 02h
    xor  bx, bx
    xor  dx, dx
    int  10h
    ret

; -------------------------------------------------
; DISP_MESS - display a '$'-terminated string at current cursor
; Input: DX = OFFSET message (caller should set cursor beforehand)
; Uses DOS INT 21h AH=09 (prints $-terminated string)
; -------------------------------------------------
DISP_MESS:
    mov  ah, 09h
    int  21h
    ret

; -------------------------------------------------
; HORIZONTAL - draw four horizontal colored bands and show message
; -------------------------------------------------
HORIZONTAL:
    call CLEAR_SCREEN

    ; band 0: rows 0..5 (black background)
    mov  ah, 06h
    xor  al, al
    mov  bh, 0Fh                 ; white on black
    mov  cx, 0000h
    mov  dx, 054Fh
    int  10h

    ; band 1: rows 6..11 (magenta)
    mov  ah, 06h
    xor  al, al
    mov  bh, 5Fh                 ; white on magenta
    mov  cx, 0600h
    mov  dx, 0B4Fh
    int  10h

    ; band 2: rows 12..17 (brown/yellow)
    mov  ah, 06h
    xor  al, al
    mov  bh, 6Fh                 ; white on yellow
    mov  cx, 0C00h
    mov  dx, 114Fh
    int  10h

    ; band 3: rows 18..24 (blue)
    mov  ah, 06h
    xor  al, al
    mov  bh, 1Fh                 ; white on blue
    mov  cx, 1200h
    mov  dx, 184Fh
    int  10h

    ; place "Press any key to continue." at row 21, col 27
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 21
    mov  dl, 27
    int  10h
    mov  dx, OFFSET KEY_PROMPT
    call DISP_MESS

    ; wait for any key
    mov  ah, 00h
    int  16h
    jmp MAIN_PANEL

; -------------------------------------------------
; VERTICAL - draw four vertical colored bands (20 cols each)
; -------------------------------------------------
VERTICAL:
    call CLEAR_SCREEN

    ; cols 0..19
    mov  ah, 06h
    xor  al, al
    mov  bh, 0Fh
    mov  cx, 0000h
    mov  dx, 1813h
    int  10h

    ; cols 20..39
    mov  ah, 06h
    xor  al, al
    mov  bh, 5Fh
    mov  cx, 0014h
    mov  dx, 1827h
    int  10h

    ; cols 40..59
    mov  ah, 06h
    xor  al, al
    mov  bh, 6Fh
    mov  cx, 0028h
    mov  dx, 183Bh
    int  10h

    ; cols 60..79
    mov  ah, 06h
    xor  al, al
    mov  bh, 1Fh
    mov  cx, 003Ch
    mov  dx, 184Fh
    int  10h

    ; place prompt at (12,27)
    mov  ah, 02h
    mov  bh, 0
    mov  dh, 12
    mov  dl, 27
    int  10h
    mov  dx, OFFSET KEY_PROMPT
    call DISP_MESS

    mov  ah, 00h
    int  16h
    jmp MAIN_PANEL

; -------------------------------------------------
; CHECKERED - corrected 4x4 blocks using the 4 colors
; -------------------------------------------------
CHECKERED:
    call CLEAR_SCREEN

    ; rows 0..5
    mov  ah, 06h
    xor  al, al
    mov  bh, 0Fh
    mov  cx, 0000h
    mov  dx, 0513h
    int  10h
    mov  bh, 5Fh
    mov  cx, 0014h
    mov  dx, 0527h
    int  10h
    mov  bh, 6Fh
    mov  cx, 0028h
    mov  dx, 053Bh
    int  10h
    mov  bh, 1Fh
    mov  cx, 003Ch
    mov  dx, 054Fh
    int  10h

    ; rows 6..11
    mov  ah, 06h
    xor  al, al
    mov  bh, 1Fh
    mov  cx, 0600h
    mov  dx, 0B13h
    int  10h
    mov  bh, 0Fh
    mov  cx, 0614h
    mov  dx, 0B27h
    int  10h
    mov  bh, 5Fh
    mov  cx, 0628h
    mov  dx, 0B3Bh
    int  10h
    mov  bh, 6Fh
    mov  cx, 063Ch
    mov  dx, 0B4Fh
    int  10h

    ; rows 12..17 (correct DX cols)
    mov  ah, 06h
    xor  al, al
    mov  bh, 6Fh
    mov  cx, 0C00h
    mov  dx, 1113h
    int  10h
    mov  bh, 1Fh
    mov  cx, 0C14h
    mov  dx, 1127h
    int  10h
    mov  bh, 0Fh
    mov  cx, 0C28h
    mov  dx, 113Bh
    int  10h
    mov  bh, 5Fh
    mov  cx, 0C3Ch
    mov  dx, 114Fh
    int  10h

    ; rows 18..24 (correct DX cols)
    mov  ah, 06h
    xor  al, al
    mov  bh, 5Fh
    mov  cx, 1200h
    mov  dx, 1813h
    int  10h
    mov  bh, 6Fh
    mov  cx, 1214h
    mov  dx, 1827h
    int  10h
    mov  bh, 1Fh
    mov  cx, 1228h
    mov  dx, 183Bh
    int  10h
    mov  bh, 0Fh
    mov  cx, 123Ch
    mov  dx, 184Fh
    int  10h

    mov  ah, 02h
    mov  bh, 0
    mov  dh, 22
    mov  dl, 27
    int  10h
    mov  dx, OFFSET KEY_PROMPT
    call DISP_MESS

    mov  ah, 00h
    int  16h
    jmp  MAIN_PANEL

; -------------------------------------------------
QUIT:
    mov  ax, 4C00h
    int  21h

; -------------------------------------------------
; INIT_MOUSE - reset and show mouse pointer
; -------------------------------------------------
INIT_MOUSE:
    mov  ax, 0001h
    int  33h
    mov  ax, 0002h
    int  33h
    ret

; -------------------------------------------------
; STRINGS (all $-terminated for INT 21h / AH=09h)
; -------------------------------------------------
FIRST_CHOICE  db '1 - HORIZONTAL STRIPES', '$'
SECOND_CHOICE db '2 - VERTICAL STRIPES', '$'
THIRD_CHOICE  db '3 - CHECKERED PATTERN', '$'
QUIT_MSG      db 'Q - QUIT', '$'
CHOICE_MSG    db 'ENTER CHOICE: ', '$'
KEY_PROMPT    db 'Press any key to continue.', '$'

; end of file
