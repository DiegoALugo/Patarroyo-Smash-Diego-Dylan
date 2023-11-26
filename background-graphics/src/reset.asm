.include "constants.inc"

.segment "ZEROPAGE"
.importzp player1_x, player1_y, player2_x, player2_y

.segment "CODE"
.import main
.export reset_handler
.proc reset_handler
  SEI
  CLD
  LDX #$00
  STX PPUCTRL
  STX PPUMASK

vblankwait:
  BIT PPUSTATUS
  BPL vblankwait

	LDX #$00
	LDA #$ff
clear_oam:
	STA $0200,X ; set sprite y-positions off the screen
	INX
	INX
	INX
	INX
	BNE clear_oam

vblankwait2:
	BIT PPUSTATUS
	BPL vblankwait2

	; initialize zero-page values
  ; PLAYER 1 position
  LDA #$20
  STA player1_x
  LDA #$b7
  STA player1_y

  ; PLAYER 2 position
  LDA #$d0
  STA player2_x
  LDA #$b7
  STA player2_y
  
  JMP main
.endproc
