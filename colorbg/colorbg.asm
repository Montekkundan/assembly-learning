    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code 
    org $F000       ; defines the origin of the ROM at $F000

START:
    ;CLEAN_START     ; Macro to safely clear the memory 

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set background luminosity color to yellow 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    lda #$1E     ; Load color in register A ($1E is NTSC yellow)
    sta COLUBK   ; store A to backgroungcolor Address $09

    jmp START    ; Repeat from START
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    org $FFFC
    .word START     ; Reset vector at $FFFC (where the program starts)
    .word START     ; Interupt vector at $FFFE (unused in VCS)