    processor 6502

    include "vcs.h"
    include "macro.h"

    seg code
    org $F000

START:
    CLEAN_START     ; macro to safely clear memory and TIA

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Start a new frame by turning on VBLANK and VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

NEXTFRAME:
    lda #2      ; same as binary value %00000010
    sta VBLANK  ; turn on VBLANK
    sta VSYNC   ; turn on VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Generate the three lines of VSYNC
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    sta WSYNC   ; fisrt scanline
    sta WSYNC   ; second scanline
    sta WSYNC   ; third scanline

    lda #0
    sta VSYNC   ; turn of VSYNC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Let the TIA output the recommened 37 scnalins of VBLANK
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ldx #37     ; X = 37 (to count 37 scanlines)
LoopVBLANK:
    sta WSYNC   ;hit scanline and wait for next scanline
    dex         ; X--
    bne LoopVBLANK  ; loop while X != 0

    lda #0
    sta VBLANK  ; turn of VBLANK

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Draw 192 visible scanlines (kernal)
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    ldx #192    ; counter for 192 visible scanlines
LoopScanline:
    stx COLUBK  ; set the background color 
    sta WSYNC   ; wait for next scanline
    dex         ; X--
    bne LoopScanline    ; loop while X != 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Output 30 more VBLANK lines (overscan) to complete our frame
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
    lda #2      ; hit and turn VBLANK again
    sta VBLANK  ; turn on VBLANK

    lda #30     ; counter for 30 scanlines
LoopOverscan:
    sta WSYNC   ; wait for next scanline
    dex         ; X--
    bne LoopOverscan    ; loop while X != 0

    jmp NEXTFRAME

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    org $FFFC
    .word START     ; Reset vector at $FFFC (where the program starts)
    .word START     ; Interupt vector at $FFFE (unused in VCS)