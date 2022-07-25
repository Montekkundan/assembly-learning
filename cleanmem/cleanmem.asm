    processor 6502

    seg code 
    org $F000

Start:
    sei         ; disable interrupts
    cld         ; disable the BCD decimal math mode
    ldx #$FF
    txs

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Clear the Page Zero region($00 to $FF)
; Meaning the entire RAM and also the entire TIA registers
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    lda #0      ; A = 0
    ldx #$FF    ; X = #$FF
    sta $FF     ; make sure  $FF is zeroed before the loop starts

MemLoop:
    dex         ; x--
    sta $0,X    ; Store the value of A inside memory address $0 + X
    bne MemLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Fill the ROM size to exactly 4KB
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 

    org $FFFC
    .word Start     ; Reset vector at $FFFC (where the program starts)
    .word Start     ; Interupt vector at $FFFE (unused in VCS)