    processor 6502

    include "vcs.h"
    include "macro.h"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set an uninitialized segment at $80 for variable declaration
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    seg.u Variables
    org $80
P0Height ds 1       ;defines one byte for player 0 height
P1Height ds 1       ;defines one byte for player 1 height

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start our ROM code segment
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    seg code
    org $F000

RESET:
    CLEAN_START     ; macro to safely clear memory and TIA

    ldx #$80        ; blue background color 
    stx COLUBK

    lda #%1111      ; white playfield color
    sta COLUPF

    lda #10         ; A = 10
    sta P0Height    ; P0Height = 10
    sta P1Height    ; P1Height = 10

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; We set the TIA registers for the color of P0 and P1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    lda #$48        ; player 0 color light red 
    sta COLUP0

    lda #$C6        ; player 1 color light green
    sta COLUP1

    ldy #%00000010
    sty CTRLPF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

STARTFRAME:
    lda #02      ; same as binary value %00000010
    sta VBLANK  ; turn on VBLANK
    sta VSYNC   ; turn on VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    REPEAT 3
        sta WSYNC
    REPEND
    lda #0
    sta VSYNC   ;turn of VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let the TIA output the recommened 37 scnalins of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    REPEAT 37
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK   ;turn of VBLANK


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw 192 visible scanlines (kernal)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
VisibleScanlines:
    REPEAT 10
        sta WSYNC   ; draw 10 empty scanlines at the top of the frame
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display 10 scanlines for the scoreboard number 
; Pulls data from array of bytes defined in NumberBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    ldy #0
ScoreboardLoop:
    lda NumberBitmap,y
    sta PF1
    sta WSYNC
    iny
    cpy #10
    bne ScoreboardLoop

    lda #0
    sta PF1     ; disable playfield

    ; draw 50 empty scanlines between player and scoreboard
    REPEAT 50 
        sta WSYNC
    REPEND

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display 10 scanlins for player 0 graphics
; Pulls data from array of bytes defined in PlayerBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    ldy #0
Player0Loop:
    lda PlayerBitmap,y
    sta GRP0
    sta WSYNC
    iny
    cpy P0Height
    bne Player0Loop

    lda #0
    sta GRP0     ; disable player 0 graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Display 10 scanlins for player 1 graphics
; Pulls data from array of bytes defined in PlayerBitmap
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    ldy #0
Player1Loop:
    lda PlayerBitmap,y
    sta GRP1
    sta WSYNC
    iny
    cpy P1Height
    bne Player1Loop

    lda #0
    sta GRP1     ; disable player 1 graphics

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; draw reminaing 102 scanlines (192-90), since we 
; already used 10+10+50+10+10 = 90 scanlines in the current frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    REPEAT 102
        sta WSYNC
    REPEND


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Output 30 more VBLANK lines (overscan) to complete our frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    lda #2      ; hit and turn VBLANK again
    sta VBLANK  ; turn on VBLANK
    REPEAT 30
        sta WSYNC
    REPEND
    lda #0
    sta VBLANK

    jmp STARTFRAME

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define an array of bytes to draw player.
; We add these bytes in the final ROM addresses.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    org $FFE8
PlayerBitmap:
    .byte #%01111110    ;  ######
    .byte #%11111111    ; ########
    .byte #%10011001    ; # #### #
    .byte #%11111111    ; ########
    .byte #%11111111    ; ########
    .byte #%11111111    ; ########
    .byte #%10111101    ; # #### #
    .byte #%11000011    ; ##    ##
    .byte #%11111111    ; ########
    .byte #%01111110    ;  ######

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Define an array of bytes to draw scoreboard number.
; We add these bytes in the final ROM addresses.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    org $FFF2
NumberBitmap:
    .byte #%00001110    ;########
    .byte #%00001110    ;########
    .byte #%00000010    ;     ###
    .byte #%00000010    ;     ###
    .byte #%00001110    ;########
    .byte #%00001110    ;########
    .byte #%00001000    ;####
    .byte #%00001000    ;####
    .byte #%00001110    ;########
    .byte #%00001110    ;########

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    org $FFFC
    .word RESET     ; Reset vector at $FFFC (where the program starts)
    .word RESET     ; Interupt vector at $FFFE (unused in VCS)


