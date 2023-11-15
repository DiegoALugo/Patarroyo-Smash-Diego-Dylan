.include "constants.inc"
.include "header.inc"
.import read_controller1

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
scroll: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
.exportzp player_x, player_y, pad1

.segment "CODE"
.proc irq_handler
  RTI
.endproc

.proc nmi_handler
  LDA #$00
  STA OAMADDR
  LDA #$02
  STA OAMDMA

	JSR read_controller1
	JSR update_player
    JSR draw_player
	
	LDA #$00
	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler

.export main
.proc main
  ; write a palette
  LDX PPUSTATUS
  LDX #$3f
  STX PPUADDR
  LDX #$00
  STX PPUADDR
load_palettes:
  LDA palettes,X
  STA PPUDATA
  INX
  CPX #$20
  BNE load_palettes


	; write nametables

; Placing first cloud line
	LDY  #$00

	first_line:
		LDA PPUSTATUS
		LDA #$20
		STA PPUADDR
		STY PPUADDR
		LDX #$3e
		STX PPUDATA
		INY
		CPY #$20
		BNE first_line

	; Placing second cloud line (first tile)

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$20
	STA PPUADDR
	LDX #$2e
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$22
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$24
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$26
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$28
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$2A
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$2C
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$2E
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$30
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$32
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$34
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$36
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$38
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$3A
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$3C
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$3E
	STA PPUADDR
	STX PPUDATA

	; Placing cloud line (second tile)
	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$21
	STA PPUADDR
	LDX #$2f
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$23
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$25
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$27
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$29
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$2b
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$2d
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$2f
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$31
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$33
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$35
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$37
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$39
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$3b
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$3d
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$3f
	STA PPUADDR
	STX PPUDATA

	; Ash tiles (two dots)

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$8e
	STA PPUADDR
	LDX #$3b
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$c3
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$f0
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$db
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$6f
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$a4
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$ab
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$94
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$db
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$42
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$ee
	STA PPUADDR
	STX PPUDATA

	; Ash tiles (1 dot)

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$ca
	STA PPUADDR
	LDX #$3c
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$93
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$20
	STA PPUADDR
	LDA #$f6
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$98
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$3b
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$f0
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$f6
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$21
	STA PPUADDR
	LDA #$bf
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$5f
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$a2
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$c7
	STA PPUADDR
	STX PPUDATA
	
	; platform

	LDY  #$67

	platform:
		LDA PPUSTATUS
		LDA #$22
		STA PPUADDR
		STY PPUADDR
		LDX #$2b
		STX PPUDATA
		INY
		CPY #$72
		BNE platform
	
	; platform edges

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$66
	STA PPUADDR
	LDX #$2c
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$72
	STA PPUADDR
	LDX #$2d
	STX PPUDATA

	; volcano (mouth)

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$77
	STA PPUADDR
	LDX #$30
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$78
	STA PPUADDR
	LDX #$31
	STX PPUDATA

	; volcano (left slope)

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$96
	STA PPUADDR
	LDX #$33
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$f3
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$b5
	STA PPUADDR
	LDX #$36
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$d4
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$12
	STA PPUADDR
	STX PPUDATA

	; volcano (right slope)

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$99
	STA PPUADDR
	LDX #$35
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$1d
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$ba
	STA PPUADDR
	LDX #$39
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$db
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$fc
	STA PPUADDR
	STX PPUDATA

	; volcano body

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$97
	STA PPUADDR
	LDX #$32
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$98
	STA PPUADDR
	LDX #$34
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$13
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$b6
	STA PPUADDR
	LDX #$37
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$b8
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$d5
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$d7
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$d9
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$f4
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$f7
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$fa
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$b7
	STA PPUADDR
	LDX #$38
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$b9
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$da
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$d6
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$f5
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$14
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$17
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$1c
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$d8
	STA PPUADDR
	LDX #$3a
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$f6
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$f9
	STA PPUADDR
	STX PPUDATA
	
	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$fb
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$19
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$22
	STA PPUADDR
	LDA #$f8
	STA PPUADDR
	LDX #$01
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$15
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$16
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$18
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$1a
	STA PPUADDR
	STX PPUDATA

	LDA PPUSTATUS
	LDA #$23
	STA PPUADDR
	LDA #$1b
	STA PPUADDR
	STX PPUDATA

	; floor

	LDY  #$20

	floor:
		LDA PPUSTATUS
		LDA #$23
		STA PPUADDR
		STY PPUADDR
		LDX #$2a
		STX PPUDATA
		INY
		CPY #$40
		BNE floor

	; underground

	LDY  #$40

	underground:
		LDA PPUSTATUS
		LDA #$23
		STA PPUADDR
		STY PPUADDR
		LDX #$29
		STX PPUDATA
		INY
		CPY #$c0
		BNE underground

	; finally, attribute table
	;  cloud_colors
	LDY #$c0

	cloud_colors:
		LDA PPUSTATUS
		LDA #$23
		STA PPUADDR
		STY PPUADDR
		LDX #%01010101
		STX PPUDATA
		INY
		CPY #$c8
		BNE cloud_colors

	;  platform colors

	LDY #$e1

	platform_colors:
		LDA PPUSTATUS
		LDA #$23
		STA PPUADDR
		STY PPUADDR
		LDX #%10100000
		STX PPUDATA
		INY
		CPY #$e5
		BNE platform_colors
	
	; volcano mouth color

	LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$e5
    STA PPUADDR
    LDA #%11000000
    STA PPUDATA

	LDA PPUSTATUS
    LDA #$23
    STA PPUADDR
    LDA #$e6
    STA PPUADDR
    LDA #%00110000
    STA PPUDATA


vblankwait:       ; wait for another vblank before continuing
  BIT PPUSTATUS
  BPL vblankwait

  LDA #%10010000  ; turn on NMIs, sprites use first pattern table
  STA PPUCTRL
  LDA #%00011110  ; turn on screen
  STA PPUMASK

forever:
  JMP forever
.endproc

; Define constants for animation
ANIM_SPD = 4
NUM_FRAMES = 2

.segment "DATA"
frame_counter: .byte 0   ; Initialize frame_counter to zero
frame_index:   .byte 0   ; Declare frame_index


.proc draw_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

; Calculate animation frame based on frame counter
  LDA frame_counter
  AND #$07           ; Mask to keep only the lower 3 bits (0-7)
  STA frame_index    ; Store the result in frame_index

  ; Write player ship tile numbers based on animation frame
  LDA frame_index
  ASL A              ; Multiply frame_index by 2 (assuming each sprite is 2 tiles wide)
  STA $0201
  CLC
  ADC #$06
  STA $0205
  CLC
  ADC #$06
  STA $0209
  CLC
  ADC #$06
  STA $020D

  ASL A              ; Multiply frame_index by 2 (assuming each sprite is 2 tiles wide)
  STA $0211
  CLC
  ADC #$06
  STA $0215
  CLC
  ADC #$06
  STA $0219
  CLC
  ADC #$06
  STA $021D

  ; Increment animation frame counter
  LDA frame_counter
  CLC
  ADC #ANIM_SPD
  STA frame_counter

  ; write player ship tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; top left tile:
  LDA player_y
  STA $0200
  LDA player_x
  STA $0203

  ; top right tile (x + 8):
  LDA player_y
  STA $0204
  LDA player_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player_y
  CLC
  ADC #$08
  STA $0208
  LDA player_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player_y
  CLC
  ADC #$08
  STA $020c
  LDA player_x
  CLC
  ADC #$08
  STA $020f

  ; restore registers and return
  PLA
  TAY
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.proc update_player
  PHP  ; Start by saving registers,
  PHA  ; as usual.
  TXA
  PHA
  TYA
  PHA

  ; Load button presses
  LDA pad1

  ; Check Left button
  AND #BTN_LEFT
  BEQ check_right ; If result is zero, left not pressed
  ; Check if moving left would not go beyond the left screen edge
  LDA player_x
  CMP #MIN_X_POSITION
  BEQ done_checking_left
  DEC player_x
done_checking_left:

check_right:
  ; Check Right button
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_up
  ; Check if moving right would not go beyond the right screen edge
  LDA player_x
  CMP #MAX_X_POSITION
  BEQ done_checking_right
  INC player_x
done_checking_right:

check_up:
  ; Check Up button
  LDA pad1
  AND #BTN_UP
  BEQ check_down
  ; Check if moving up would not go beyond the top screen edge
  LDA player_y
  CMP #MIN_Y_POSITION
  BEQ done_checking_up
  DEC player_y
done_checking_up:

check_down:
  ; Check Down button
  LDA pad1
  AND #BTN_DOWN
  BEQ done_checking

  ; Check if moving down would not go beyond the bottom screen edge
  LDA player_y
  CMP #MAX_Y_POSITION
  BEQ done_checking_down
  INC player_y
done_checking_down:

done_checking:
  ; Additional collision detection logic can be added here
  ; For example, check if the player collides with the floor or platforms
  ; Compare player_x, player_y with floor and platform positions and sizes
  ; Adjust player position accordingly

  PLA ; Done with updates, restore registers
  TAY ; and return to where we called this
  PLA
  TAX
  PLA
  PLP
  RTS
.endproc

.segment "VECTORS"
.addr nmi_handler, reset_handler, irq_handler

.segment "RODATA"
palettes:
.byte $10, $07, $20, $16
.byte $10, $2d, $27, $0f
.byte $10, $0f, $1c, $0c
.byte $10, $07, $36, $16

.byte $10, $09, $19, $20
.byte $10, $01, $21, $31
.byte $10, 06, $16, $26
.byte $10, $09, $19, $20


.segment "CHR"
.incbin "lava_background.chr"

;ca65 src/backgrounds.asm
;ca65 src/controllers.asm
;ca65 src/reset.asm
;ld65 src/reset.o src/backgrounds.o src/controllers.o -C nes.cfg -o backgrounds.nes



