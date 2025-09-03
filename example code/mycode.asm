org 100h

start:
    ; point DS to text video memory
    mov ax, 0B800h
    mov ds, ax

    ; attribute (bright yellow on black)
    mov dh, 00001110b

    ; =====================================================
    ; 1) TOP-LEFT: draw at (row=0, col=0)
    ; =====================================================
    mov di, (0*80 + 0)*2
    call draw_css

    ; =====================================================
    ; 2) MOVE RIGHT along top to TOP-RIGHT
    ;    3 chars wide => last start col = 77 ? 77 steps
    ; =====================================================
    mov cx, 77
right_top:
    call erase_css
    add  di, 2              ; move right 1 col
    call draw_css
    loop right_top
    ; Now at (row 0, col 77)

    ; =====================================================
    ; 3) MOVE DOWN right edge to BOTTOM-RIGHT
    ;    rows 0 -> 24 ? 24 steps
    ; =====================================================
    mov cx, 24
down_right:
    call erase_css
    add  di, 160            ; next row (80*2 bytes)
    call draw_css
    loop down_right
    ; Now at (row 24, col 77)

    ; =====================================================
    ; 4) MOVE LEFT along bottom to BOTTOM-LEFT
    ;    77 steps back to col 0
    ; =====================================================
    mov cx, 77
left_bottom:
    call erase_css
    sub  di, 2
    call draw_css
    loop left_bottom
    ; Now at (row 24, col 0)

    ; =====================================================
    ; 5) MOVE UP left edge to TOP-LEFT
    ;    24 steps back to row 0
    ; =====================================================
    mov cx, 24
up_left:
    call erase_css
    sub  di, 160
    call draw_css
    loop up_left
    ; Now at (row 0, col 0)

    ; =====================================================
    ; 6) MOVE to CENTER horizontally: col 0 -> 39 (39 steps)
    ;    (CSS spans cols 39..41)
    ; =====================================================
    mov cx, 39
to_center_right:
    call erase_css
    add  di, 2
    call draw_css
    loop to_center_right
    ; Now at (row 0, col 39)

    ; =====================================================
    ; 7) MOVE DOWN to row 12 (center-ish): 12 steps
    ; =====================================================
    mov cx, 12
to_center_down:
    call erase_css
    add  di, 160
    call draw_css
    loop to_center_down
    ; Now at (row 12, col 39)

    ; =====================================================
    ; 8) FINAL DOWN to bottom center: 12 steps
    ; =====================================================
    mov cx, 12
final_down:
    call erase_css
    add  di, 160
    call draw_css
    loop final_down

    ; exit to DOS
    mov ax, 4C00h
    int 21h


; ==============================
; Draw "CSS" at DS:DI
; DL = char, DH = attribute
; ==============================
draw_css:
    push ax
    push di
    mov dl, 'C'
    mov [di], dx
    add di, 2
    mov dl, 'S'
    mov [di], dx
    add di, 2
    mov [di], dx            ; second 'S'
    pop  di
    pop  ax
    ret

; ==============================
; Erase 3 cells at DS:DI
; (write spaces with same attr)
; ==============================
erase_css:
    push ax
    push di
    mov dl, ' '
    mov [di], dx
    add di, 2
    mov [di], dx
    add di, 2
    mov [di], dx
    pop  di
    pop  ax
    ret
