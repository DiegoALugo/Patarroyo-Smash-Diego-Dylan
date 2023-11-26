.include "constants.inc"
.include "header.inc"
.import read_controller1

.segment "ZEROPAGE"
player_x: .res 1
player_y: .res 1
scroll: .res 1
ppuctrl_settings: .res 1
pad1: .res 1
jumpCounter: .res 1
jumpSpriteFlag: .res 1
onPlatform: .byte 0
inPlatformRange: .byte 0
spriteJump: .byte 0
spriteFall: .byte 0
walkCounter: .res 1
walkAnimation: .res 1
.exportzp player_x, player_y, pad1, jumpCounter, jumpSpriteFlag, spriteJump, spriteFall

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
  JSR draw_player
	JSR update_player

	LDA #$00
	STA $2005
	STA $2005
  RTI
.endproc

.import reset_handler
.import draw_background

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

 JSR draw_background

 ; initializing walk and animation variables
  LDA #$00
  STA walkCounter
  LDA #$00
  STA walkAnimation

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

.proc draw_player
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA spriteJump
  BNE jump_sprite ; If spriteJump is non-zero, load jump sprite
  JMP check_fall

check_fall:
  LDA spriteFall
  BNE jump_sprite ; If spriteFall is non-zero, load jump sprite

  JMP standing_sprite ; If you got here, both fall and jump flags are deactivated
  
; Check if sprite is walking
  LDA walkAnimation
  CMP #$01   ; Check if the walking animation is active
  BNE standing_sprite ; If not, use the standing sprite

  ; Use the walking sprite tiles
  LDA walkCounter
  AND #$03   ; using lower 2 bits for animation frame
  TAX ; transfer to x register
  LDA walking_frames, X
  STA $0201
  LDA walking_frames + 1, X
  STA $0205
  LDA walking_frames + 2, X
  STA $0209
  LDA walking_frames + 3, X
  STA $020d

  JMP continue

  standing_sprite:
    LDA #$06
    STA $0201
    LDA #$07
    STA $0205
    LDA #$16
    STA $0209
    LDA #$17
    STA $020d
    JMP continue
  ; write player tile numbers
  jump_sprite:
    LDA #$0a
    STA $0201
    LDA #$0b
    STA $0205
    LDA #$1a
    STA $0209
    LDA #$1b
    STA $020d
    JMP continue
  
  walk_sprite:
    LDA #$08
    STA $0201
    LDA #$09
    STA $0205
    LDA #$18
    STA $0209
    LDA #$19
    STA $020d
  
  continue:
  ; write player tile attributes
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
  CMP #MIN_X_POSITION       ; Checks left screen limit
  BEQ done_checking_left
  DEC player_x

  ; Start walking animation
  LDA walkCounter
  INX ; increment x register
  CPX #$03 ; compare with immediate value 1
  BNE skip_increment
  LDA #$00 ; if comparison result is equal, load 0 into accumulator
  STA walkCounter ; store accumulator in variable
  INC walkAnimation ; increment value of variable
skip_increment:

done_checking_left:

check_right:
  ; Check Right button
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_jump
  ; Check if moving right would not go beyond the right screen edge
  LDA player_x
  CMP #MAX_X_POSITION       ; Checks right screen limit
  BEQ done_checking_right
  INC player_x

  LDA walkCounter
  INX
  CPX #$03
  BNE skip_increment_right
  LDA #$00
  STA walkCounter
  INC walkAnimation
skip_increment_right:

; Increment walkCounter for the next frame
  INC walkCounter

done_checking_right:

platform_range:
  LDA player_x           ; Load player's X coordinate
  CMP #MIN_PLATFORM_X    ; Compare with platform's minimum X coordinate
  BCC not_on_platform     ; Branch if player is to the left of the platform
  LDA player_x
  CMP #MAX_PLATFORM_X    ; Compare with platform's maximum X coordinate
  BCS not_on_platform     ; Branch if player is to the right of the platform
  LDA #$01               
  STA inPlatformRange    ; Set inPlatformRange flag to 1
  LDA onPlatform
  CMP #1                 ; Check if on platform
  BEQ fall_from_platform    ; If on platform, check if in range of platform to fall or stay on it
  JMP check_jump

not_on_platform:
  LDA #$00               
  STA inPlatformRange    ; Set inPlatformRange flag to 0
  LDA onPlatform
  CMP #0                 ; Check if on platform
  BEQ check_jump
  JMP fall_from_platform   ; If on platform, check if the sprite can fall from platform

fall_from_platform:
  LDA inPlatformRange    
  CMP #0                 ; Check if not in platform range
  BEQ at_peak            ; If not it will start to fall again, using "at_peak" subroutine
  JMP check_jump

check_jump:
  LDA pad1
  AND #BTN_UP
  BEQ check_if_jumping   ; If Up Button NOT pressed, branch to check_if_jumping, else continue
  LDY spriteJump         ; Load jump flag 
  CPY #0                 ; Compare with 0
  BEQ start_jump         ; Branch to start_jump If equal to 0
  JMP check_if_jumping   ; If NO branch, check if jumping/falling
 

check_if_jumping:
  LDA spriteJump         ; Load jump flag
  CMP #1                 ; Compare accumulator with 1
  BEQ jumping            ; Branch to jump if flag is active (equal 1)
  LDA spriteFall         ; Load fall flag
  CMP #1                 ; Compare accumulator with 1
  BEQ falling            ; Branch to fall if flag is active (equal 1)
  JMP done_checking      ; If neither jump or fall are active, jump to end of subroutine


start_jump:
  LDA #$00               
  STA onPlatform         ; If jump starts, it will not be on platform
  LDA spriteFall         
  CMP #1                 ; Check if falling so it doesnt double jump
  BEQ falling            ; Branch to keep falling
  LDA #$3a               ; Load value to Accumulator (jump height)
  STA jumpCounter        ; Store value from accumulator to jumpCounter memory space
  LDA #$01               
  STA spriteJump         ; Set jump flag
  JMP jumping            ; Start jumping

jumping:
  LDA player_y           ; Load Y coord to accum
  CMP #MIN_Y_POSITION    ; Compare with top of screen
  BEQ at_peak            ; Branch to 'at_peak' if sprite touches the top
  LDX jumpCounter        ; Load to X register what is in jumpCounter
  DEC player_y           ; decrease player's Y coordinate (goes up)
  DEX                    ; decrease X register 
  STX jumpCounter        ; Store what is in X register to jumpCounter
  CPX #0                 ; Check if X register is 0
  BEQ at_peak            ; If so, pleayer reached the peak
  JMP done_checking      ; If not, jump to the end to run the loop again

at_peak:
  LDA #$01               ; Load 1 to accumulator
  STA spriteFall         ; Store active flag to spriteFall, it means the sprite will fall now
  LDA #$00               ; Load 0 to accumulator
  STA spriteJump         ; Store flag to spriteJump, sprite is now falling
  STA onPlatform
  JMP falling            ; Start falling

falling:
  LDA player_y                  ; Load player's Y coordinate to accum.
  CMP #MAX_Y_POSITION           ; Compare with floor limit
  BEQ finished_falling_ground   ; If equal, branch to finish_falling which deactivates falling flag
  LDA inPlatformRange           
  CMP #1                        ; Check if in platform range 
  BEQ fall_on_platform          ; Jumps to a similar falling branch that takes the platform range into account
  INC player_y                  ; Keep falling
  JMP done_checking             ; Jump to the end of subroutine to restart loop

fall_on_platform:
  LDA player_y
  CMP #PLATFORM_LEVEL           ; Checks if platform height was reached
  BEQ finished_falling_plat
  INC player_y                  ; keep falling
  JMP done_checking

finished_falling_plat:
  LDA #$00               ; Loads 0 to accum
  STA spriteFall         ; Sets spriteFall and spriteJump to 0, essentially ending the falling/jumping
  STA spriteJump         
  LDA #$01
  STA onPlatform         ; If you fall on the platform, it sets the flag to one, the sprite is on the platform
  JMP done_checking
  
finished_falling_ground:
  LDA #$00               ; Loads 0 to accum
  STA spriteFall         ; Sets spriteFall to 0, essentially ending the falling
  STA spriteJump         
  JMP done_checking      ; jump to the end

  done_checking:

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
.byte $10, $06, $16, $26
.byte $10, $09, $19, $20

walking_frames:
.byte $06, $07, $16, $17
.byte $08, $09, $18, $19

.segment "CHR"
.incbin "lava_background.chr"

;ca65 src/background.asm
;ca65 src/game.asm
;ca65 src/controllers.asm
;ca65 src/reset.asm
;ld65 src/reset.o src/background.o src/controllers.o src/game.o -C nes.cfg -o game.nes