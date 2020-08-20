PPUCTL    = $2000
PPUMASK   = $2001
PPUSTATUS = $2002
OAMADDR   = $2003
PPUADDR   = $2006
PPUDATA   = $2007
OAMDMA    = $4014

.segment "HEADER"
.byte 'N', 'E', 'S', $1A ; magic
.byte $02 ; 32KiB PRG
.byte $01 ; 8KiB CHR
.byte $01 ; vertical scrolling, mapper 0
.byte $00 ;
.byte $0, $0, $0, $0, $0, $0, $0, $0 ; padding

.segment "TILES"
.incbin "font.chr"

.segment "VECTORS"
.word nmi
.word reset
.word irq

.segment "CODE"
reset:
    sei          ; disable IRQs
    cld          ; disable decimal mode
    ldx #$40
    stx $4017    ; disable APU frame IRQ
    ldx #$ff
    txs          ; Set up stack
    inx          ; X = 0
    stx PPUCTL   ; disable NMI
    stx PPUMASK  ; disable rendering
    stx $4015    ; disable APU
    stx $4010    ; disable DMC IRQs

    ; 1st VBLANK
    bit PPUSTATUS
    :
        bit PPUSTATUS
        bpl :-

    ; clear RAM
    :
        txa ; A = X = 0
        sta $0000, X
        sta $0100, X
        sta $0300, X
        sta $0400, X
        sta $0500, X
        sta $0600, X
        sta $0700, X
        inx
        bne :-

    ; 2nd VBLANK
    :
        bit PPUSTATUS
        bpl :-

; Load the palettes to $3f00
; Load the address $3f00
    lda PPUSTATUS
    lda #$3f
    sta PPUADDR
    lda #$00
    sta PPUADDR

; Load the data
    ldx #$00
loadPalettes:
    lda palettes, X
    sta PPUDATA
    inx
    cpx #32
    bne loadPalettes

    ldx #$00
loadSprites:
    lda sprites, x
    sta $0200, x
    inx
    cpx #48 ; sprites array: 4 * 12 = 48 bytes
    bne loadSprites

    lda #%10000000
    sta PPUCTL

    lda #%00010000
    sta PPUMASK

; Loop infinitely
loop:
    jmp loop

nmi:
    lda #$02
    sta OAMDMA ; load $0200-$02FF to the internal PPU OAM
    rti

irq:
    rti

palettes:
    .byte $0f,$20,$20,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; background palette
    .byte $0f,$20,$20,$20,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00 ; sprite palette

sprites:
    ;     vert tile attr horiz
    .byte $78, $07, $00, $70
    .byte $78, $04, $00, $78
    .byte $78, $0b, $00, $80
    .byte $78, $0b, $00, $88
    .byte $78, $0e, $00, $90
    .byte $78, $1b, $00, $98
    .byte $80, $16, $00, $70
    .byte $80, $0e, $00, $78
    .byte $80, $11, $00, $80
    .byte $80, $0b, $00, $88
    .byte $80, $03, $00, $90
    .byte $80, $1c, $00, $98
