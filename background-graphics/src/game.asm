.include "constants.inc"
.include "header.inc"
.import read_controller1
.import read_controller2

.segment "ZEROPAGE"
player1_x: .res 1
player1_y: .res 1
player2_x: .res 1
player2_y: .res 1
pad1: .res 1
pad2: .res 1
jumpCounter: .res 1
jumpSpriteFlag: .res 1
onPlatform: .byte 0
inPlatformRange: .byte 0
spriteJump: .byte 0
spriteFall: .byte 0
walkCounter: .res 1
walkCounter2: .res 1
walkingFlag: .res 1
walkingFlag2: .res 1
walkingAnimation: .res 1
walkingAnimation2: .res 1
facing_direction: .res 1  
facing_direction2: .res 1 ; 0 --> Right, 1 --> left
jumpCounter2: .res 1
jumpSpriteFlag2: .res 1
onPlatform2: .byte 0
inPlatformRange2: .byte 0
spriteJump2: .byte 0
spriteFall2: .byte 0
.exportzp player1_x, player1_y, pad1, jumpCounter, jumpSpriteFlag, spriteJump, spriteFall
.exportzp player2_x, player2_y, pad2, jumpCounter2, jumpSpriteFlag2, spriteJump2, spriteFall2, facing_direction2, walkingFlag2

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
  JSR read_controller2
  JSR draw_player1
  JSR draw_player2
	JSR update_player
  JSR update_player2

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
  STA walkingAnimation
  STA walkingFlag
  STA facing_direction
  STA walkCounter2
  STA walkingAnimation2
  STA walkingFlag2
  STA facing_direction2
  
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

.proc draw_player1  ; PLAYER ONE
  ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA facing_direction
  CMP #0
  BEQ check_R_jump
  JMP check_L_jump

  check_L_jump:
    LDA spriteJump
    BNE jump_left ; If spriteJump is non-zero, load jump sprite
    JMP check_L_fall

  check_L_fall:
    LDA spriteFall
    BNE jump_left ; If spriteFall is non-zero, load jump sprite
  ; If you got here, both fall and jump flags are deactivated
    JMP check_L_walk

     jump_left:  ; LEFT JUMP SPRITE
    LDA #$2a
    STA $0201
    LDA #$2b
    STA $0205
    LDA #$3a
    STA $0209
    LDA #$3b
    STA $020d
    JMP continue

  check_L_walk:
    LDA walkingFlag
    CMP #1   ; Check if the walking animation is active
    BNE standing_left ; If not, use the standing sprite

    LDA walkingAnimation
    CMP #0
    BEQ walk_left
    JMP standing_left

  check_R_jump:
    LDA spriteJump
    BNE jump_right ; If spriteJump is non-zero, load jump sprite
    JMP check_R_fall

  check_R_fall:
    LDA spriteFall
    BNE jump_right ; If spriteFall is non-zero, load jump sprite
  ; If you got here, both fall and jump flags are deactivated
    JMP check_R_walk

  jump_right:  ; RIGHT JUMP SPRITE
    LDA #$0a
    STA $0201
    LDA #$0b
    STA $0205
    LDA #$1a
    STA $0209
    LDA #$1b
    STA $020d
    JMP continue

  check_R_walk:
    LDA walkingFlag
    CMP #1   ; Check if the walking animation is active
    BNE standing_right ; If not, use the standing sprite

    LDA walkingAnimation
    CMP #0
    BEQ walk_right
    JMP standing_right

  walk_count:
    INC walkCounter
    LDA walkCounter
    CMP #5
    BEQ change_Anim
    JMP continue

  change_Anim:
    LDA walkingAnimation
    CMP #0
    BEQ set_to_one
    LDA #$00
    STA walkingAnimation
    JMP reset_counter

  set_to_one:
    LDA #$01
    STA walkingAnimation
    JMP reset_counter

  reset_counter:
    LDA #$00
    STA walkCounter
    JMP continue

  count_if_walking:
    LDA walkingAnimation
    CMP #1
    BEQ walk_count
    JMP continue

;---------------------------------Left facing sprites-------------------------------------;
 standing_left:   ;  Left standing sprite
    LDA #$26
    STA $0201
    LDA #$27
    STA $0205
    LDA #$36
    STA $0209
    LDA #$37
    STA $020d
    JMP count_if_walking
  
  walk_left:   ; left walk sprite
    LDA #$28
    STA $0201
    LDA #$29
    STA $0205
    LDA #$38
    STA $0209
    LDA #$39
    STA $020d
    JMP walk_count

;---------------------------------Left facing sprites-------------------------------------;

;-------------------------------------RIGHT facing sprites------------------------------------;

  standing_right:   ;  Right standing sprite
    LDA #$06
    STA $0201
    LDA #$07
    STA $0205
    LDA #$16
    STA $0209
    LDA #$17
    STA $020d
    JMP count_if_walking
  
  walk_right:   ; Right walk sprite
    LDA #$08
    STA $0201
    LDA #$09
    STA $0205
    LDA #$18
    STA $0209
    LDA #$19
    STA $020d

    JMP walk_count
  ;---------------------------------RIGHT facing sprites------------------------------------;


  continue:
  ; write player tile attributes
  ; use palette 0
  LDA #$00
  STA $0202
  STA $0206
  STA $020a
  STA $020e

  ; top left tile:
  LDA player1_y
  STA $0200
  LDA player1_x
  STA $0203

  ; top right tile (x + 8):
  LDA player1_y
  STA $0204
  LDA player1_x
  CLC
  ADC #$08
  STA $0207

  ; bottom left tile (y + 8):
  LDA player1_y
  CLC
  ADC #$08
  STA $0208
  LDA player1_x
  STA $020b

  ; bottom right tile (x + 8, y + 8)
  LDA player1_y
  CLC
  ADC #$08
  STA $020c
  LDA player1_x
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

.proc draw_player2 ; PLAYER TWO
   ; save registers
  PHP
  PHA
  TXA
  PHA
  TYA
  PHA

  LDA facing_direction2
  CMP #0
  BEQ check_R_jump2
  JMP check_L_jump2

  check_L_jump2:
    LDA spriteJump2
    BNE jump_left2 ; If spriteJump is non-zero, load jump sprite
    JMP check_L_fall2

  check_L_fall2:
    LDA spriteFall2
    BNE jump_left2 ; If spriteFall is non-zero, load jump sprite
  ; If you got here, both fall and jump flags are deactivated
    JMP check_L_walk2

     jump_left2:  ; LEFT JUMP SPRITE
    LDA #$2a
    STA $0211
    LDA #$2b
    STA $0215
    LDA #$3a
    STA $0219
    LDA #$3b
    STA $021d
    JMP continue2

  check_L_walk2:
    LDA walkingFlag2
    CMP #1   ; Check if the walking animation is active
    BNE standing_left2 ; If not, use the standing sprite

    LDA walkingAnimation2
    CMP #0
    BEQ walk_left2
    JMP standing_left2

  check_R_jump2:
    LDA spriteJump2
    BNE jump_right2 ; If spriteJump is non-zero, load jump sprite
    JMP check_R_fall2

  check_R_fall2:
    LDA spriteFall2
    BNE jump_right2 ; If spriteFall is non-zero, load jump sprite
  ; If you got here, both fall and jump flags are deactivated
    JMP check_R_walk2

  jump_right2:  ; RIGHT JUMP SPRITE
    LDA #$0a
    STA $0211
    LDA #$0b
    STA $0215
    LDA #$1a
    STA $0219
    LDA #$1b
    STA $021d
    JMP continue2

  check_R_walk2:
    LDA walkingFlag2
    CMP #1   ; Check if the walking animation is active
    BNE standing_right2 ; If not, use the standing sprite

    LDA walkingAnimation2
    CMP #0
    BEQ walk_right2
    JMP standing_right2

  walk_count2:
    INC walkCounter2
    LDA walkCounter2
    CMP #5
    BEQ change_Anim2
    JMP continue2

  change_Anim2:
    LDA walkingAnimation2
    CMP #0
    BEQ set_to_one2
    LDA #$00
    STA walkingAnimation2
    JMP reset_counter2

  set_to_one2:
    LDA #$01
    STA walkingAnimation2
    JMP reset_counter2

  reset_counter2:
    LDA #$00
    STA walkCounter2
    JMP continue2

  count_if_walking2:
    LDA walkingAnimation2
    CMP #1
    BEQ walk_count2
    JMP continue2

;---------------------------------Left facing sprites-------------------------------------;
 standing_left2:   ;  Left standing sprite
    LDA #$26
    STA $0211
    LDA #$27
    STA $0215
    LDA #$36
    STA $0219
    LDA #$37
    STA $021d
    JMP count_if_walking2
  
  walk_left2:   ; left walk sprite
    LDA #$28
    STA $0211
    LDA #$29
    STA $0215
    LDA #$38
    STA $0219
    LDA #$39
    STA $021d
    JMP walk_count2

;---------------------------------Left facing sprites-------------------------------------;

;-------------------------------------RIGHT facing sprites------------------------------------;

  standing_right2:   ;  Right standing sprite
    LDA #$06
    STA $0211
    LDA #$07
    STA $0215
    LDA #$16
    STA $0219
    LDA #$17
    STA $021d
    JMP count_if_walking2
  
  walk_right2:   ; Right walk sprite
    LDA #$08
    STA $0211
    LDA #$09
    STA $0215
    LDA #$18
    STA $0219
    LDA #$19
    STA $021d

    JMP walk_count2
  ;---------------------------------RIGHT facing sprites------------------------------------;

  continue2:
  ; write player tile attributes
  ; use palette 0
  LDA #$01
  STA $0212
  STA $0216
  STA $021a
  STA $021e

  ; top left tile:
  LDA player2_y
  STA $0210
  LDA player2_x
  STA $0213

  ; top right tile (x + 8):
  LDA player2_y
  STA $0214
  LDA player2_x
  CLC
  ADC #$08
  STA $0217

  ; bottom left tile (y + 8):
  LDA player2_y
  CLC
  ADC #$08
  STA $0218
  LDA player2_x
  STA $021b

  ; bottom right tile (x + 8, y + 8)
  LDA player2_y
  CLC
  ADC #$08
  STA $021c
  LDA player2_x
  CLC
  ADC #$08
  STA $021f


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

  LDA #$00
  STA walkingFlag
  ; Load button presses
  LDA pad1

  ; Check Left button
  AND #BTN_LEFT
  BEQ check_right ; If result is zero, left not pressed
  LDA #$01
  STA facing_direction
  LDA #$01
  STA walkingFlag
  ; Check if moving left would not go beyond the left screen edge
  LDA player1_x
  CMP #MIN_X_POSITION       ; Checks left screen limit
  BEQ done_checking_left
  DEC player1_x              ; Decrease X to move left
  JMP platform_range        ; Checks if player within platform range
done_checking_left:

check_right:
  ; Check Right button
  LDA pad1
  AND #BTN_RIGHT
  BEQ check_jump
  LDA #$00
  STA facing_direction
  LDA #$01
  STA walkingFlag
  LDA player1_x
  CMP #MAX_X_POSITION       ; Checks right screen limit
  BEQ done_checking_right
  INC player1_x              ; Increase x coordinate to move right
  JMP platform_range        ; Checks if player within platform range after every horizontal movement
done_checking_right:

platform_range:
  LDA player1_x           ; Load player's X coordinate
  CMP #MIN_PLATFORM_X    ; Compare with platform's minimum X coordinate
  BCC not_on_platform     ; Branch if player is to the left of the platform
  LDA player1_x
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
  LDA player1_y           ; Load Y coord to accum
  CMP #MIN_Y_POSITION    ; Compare with top of screen
  BEQ at_peak            ; Branch to 'at_peak' if sprite touches the top
  LDX jumpCounter        ; Load to X register what is in jumpCounter
  DEC player1_y           ; decrease player's Y coordinate (goes up)
  DEC player1_y
  DEX                    ; decrease X register 
  DEX
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
  LDA player1_y                  ; Load player's Y coordinate to accum.
  CMP #MAX_Y_POSITION           ; Compare with floor limit
  BEQ finished_falling_ground   ; If equal, branch to finish_falling which deactivates falling flag
  LDA inPlatformRange           
  CMP #1                        ; Check if in platform range 
  BEQ fall_on_platform          ; Jumps to a similar falling branch that takes the platform range into account
  INC player1_y                  ; Keep falling
  INC player1_y
  JMP done_checking             ; Jump to the end of subroutine to restart loop

fall_on_platform:
  LDA player1_y
  CMP #PLATFORM_LEVEL           ; Checks if platform height was reached
  BEQ finished_falling_plat
  INC player1_y                  ; keep falling
  INC player1_y
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

.proc update_player2 ; PLAYER TWO
  PHP  ; Start by saving registers,
  PHA  ; as usual.
  TXA
  PHA
  TYA
  PHA

  LDA #$00
  STA walkingFlag2
  ; Load button presses
  LDA pad2

  ; Check Left button
  AND #BTN_LEFT
  BEQ check_right2 ; If result is zero, left not pressed
  LDA #$01
  STA facing_direction2
  LDA #$01
  STA walkingFlag2
  ; Check if moving left would not go beyond the left screen edge
  LDA player2_x
  CMP #MIN_X_POSITION       ; Checks left screen limit
  BEQ done_checking_left2
  DEC player2_x              ; Decrease X to move left
  JMP platform_range2       ; Checks if player within platform range
done_checking_left2:

check_right2:
  ; Check Right button
  LDA pad2
  AND #BTN_RIGHT
  BEQ check_jump2
  LDA #$00
  STA facing_direction2
  LDA #$01
  STA walkingFlag2
  LDA player2_x
  CMP #MAX_X_POSITION       ; Checks right screen limit
  BEQ done_checking_right2
  INC player2_x              ; Increase x coordinate to move right
  JMP platform_range2       ; Checks if player within platform range after every horizontal movement
done_checking_right2:

platform_range2:
  LDA player2_x           ; Load player's X coordinate
  CMP #MIN_PLATFORM_X    ; Compare with platform's minimum X coordinate
  BCC not_on_platform2     ; Branch if player is to the left of the platform
  LDA player2_x
  CMP #MAX_PLATFORM_X    ; Compare with platform's maximum X coordinate
  BCS not_on_platform2     ; Branch if player is to the right of the platform
  LDA #$01               
  STA inPlatformRange2    ; Set inPlatformRange flag to 1
  LDA onPlatform2
  CMP #1                 ; Check if on platform
  BEQ fall_from_platform2    ; If on platform, check if in range of platform to fall or stay on it
  JMP check_jump2

not_on_platform2:
  LDA #$00               
  STA inPlatformRange2    ; Set inPlatformRange flag to 0
  LDA onPlatform2
  CMP #0                 ; Check if on platform
  BEQ check_jump2
  JMP fall_from_platform2   ; If on platform, check if the sprite can fall from platform

fall_from_platform2:
  LDA inPlatformRange2    
  CMP #0                 ; Check if not in platform range
  BEQ at_peak2            ; If not it will start to fall again, using "at_peak" subroutine
  JMP check_jump2

check_jump2:
  LDA pad2
  AND #BTN_UP
  BEQ check_if_jumping2   ; If Up Button NOT pressed, branch to check_if_jumping, else continue
  LDY spriteJump2         ; Load jump flag 
  CPY #0                 ; Compare with 0
  BEQ start_jump2         ; Branch to start_jump If equal to 0
  JMP check_if_jumping2   ; If NO branch, check if jumping/falling
 

check_if_jumping2:
  LDA spriteJump2         ; Load jump flag
  CMP #1                 ; Compare accumulator with 1
  BEQ jumping2            ; Branch to jump if flag is active (equal 1)
  LDA spriteFall2         ; Load fall flag
  CMP #1                 ; Compare accumulator with 1
  BEQ falling2            ; Branch to fall if flag is active (equal 1)
  JMP done_checking2      ; If neither jump or fall are active, jump to end of subroutine


start_jump2:
  LDA #$00               
  STA onPlatform2         ; If jump starts, it will not be on platform
  LDA spriteFall2         
  CMP #1                 ; Check if falling so it doesnt double jump
  BEQ falling2            ; Branch to keep falling
  LDA #$3a               ; Load value to Accumulator (jump height)
  STA jumpCounter2        ; Store value from accumulator to jumpCounter memory space
  LDA #$01               
  STA spriteJump2         ; Set jump flag
  JMP jumping2            ; Start jumping

jumping2:
  LDA player2_y           ; Load Y coord to accum
  CMP #MIN_Y_POSITION    ; Compare with top of screen
  BEQ at_peak2            ; Branch to 'at_peak' if sprite touches the top
  LDY jumpCounter2        ; Load to X register what is in jumpCounter
  DEC player2_y           ; decrease player's Y coordinate (goes up)
  DEC player2_y
  DEY                    ; decrease X register 
  DEY
  STY jumpCounter2        ; Store what is in X register to jumpCounter
  CPY #0                 ; Check if X register is 0
  BEQ at_peak2            ; If so, pleayer reached the peak
  JMP done_checking2      ; If not, jump to the end to run the loop again

at_peak2:
  LDA #$01               ; Load 1 to accumulator
  STA spriteFall2         ; Store active flag to spriteFall, it means the sprite will fall now
  LDA #$00               ; Load 0 to accumulator
  STA spriteJump2         ; Store flag to spriteJump, sprite is now falling
  STA onPlatform2
  JMP falling2            ; Start falling

falling2:
  LDA player2_y                  ; Load player's Y coordinate to accum.
  CMP #MAX_Y_POSITION           ; Compare with floor limit
  BEQ finished_falling_ground2   ; If equal, branch to finish_falling which deactivates falling flag
  LDA inPlatformRange2           
  CMP #1                        ; Check if in platform range 
  BEQ fall_on_platform2          ; Jumps to a similar falling branch that takes the platform range into account
  INC player2_y                  ; Keep falling
  INC player2_y
  JMP done_checking2             ; Jump to the end of subroutine to restart loop

fall_on_platform2:
  LDA player2_y
  CMP #PLATFORM_LEVEL           ; Checks if platform height was reached
  BEQ finished_falling_plat2
  INC player2_y                  ; keep falling
  INC player2_y
  JMP done_checking2

finished_falling_plat2:
  LDA #$00               ; Loads 0 to accum
  STA spriteFall2         ; Sets spriteFall and spriteJump to 0, essentially ending the falling/jumping
  STA spriteJump2        
  LDA #$01
  STA onPlatform2         ; If you fall on the platform, it sets the flag to one, the sprite is on the platform
  JMP done_checking2
  
finished_falling_ground2:
  LDA #$00               ; Loads 0 to accum
  STA spriteFall2         ; Sets spriteFall to 0, essentially ending the falling
  STA spriteJump2         
  JMP done_checking2      ; jump to the end

  done_checking2:

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