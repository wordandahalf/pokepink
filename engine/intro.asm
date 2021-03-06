MOVE_GENGAR_RIGHT   EQU $00
MOVE_GENGAR_LEFT    EQU $01
MOVE_NIDORINO_RIGHT EQU $ff

PlayIntro: ; (located @ 10:5997)
	xor a
	ld [hJoyHeld], a
	inc a
	ld [H_AUTOBGTRANSFERENABLED], a
	call ShowContributorsAndDisclaimer
	call PlayShootingStar ; Debatable routine name--this also displays the three copyright notices.
	callab PlayIntroScene
	xor a
	ld [hSCX], a
	ld [H_AUTOBGTRANSFERENABLED], a
	call ClearSprites
	call DelayFrame
	ret

InitIntroNidorinoOAM:
	ld hl, wOAMBuffer
	ld d, 0
.loop
	push bc
	ld a, [wBaseCoordY]
	ld e, a
.innerLoop
	ld a, e
	add 8
	ld e, a
	ld [hli], a ; Y
	ld a, [wBaseCoordX]
	ld [hli], a ; X
	ld a, d
	ld [hli], a ; tile
	ld a, $80
	ld [hli], a ; attributes
	inc d
	dec c
	jr nz, .innerLoop
	ld a, [wBaseCoordX]
	add 8
	ld [wBaseCoordX], a
	pop bc
	dec b
	jr nz, .loop
	ret

IntroClearScreen:
	ld hl, vBGMap1
	ld bc, $240
	jr IntroClearCommon

IntroClearMiddleOfScreen:
; clear the area of the tile map between the black bars on the top and bottom
	coord hl, 0, 4
	ld bc, SCREEN_WIDTH * 10

IntroClearCommon:
	ld [hl], $0
	inc hl
	dec bc
	ld a, b
	or c
	jr nz, IntroClearCommon
	ret

IntroPlaceBlackTiles:
	ld a, $1
.loop
	ld [hli], a
	dec c
	jr nz, .loop
	ret

CopyTileIDsFromList_ZeroBaseTileID:
	ld c, 0
	predef_jump CopyTileIDsFromList

ShowContributorsAndDisclaimer:
	ld b, SET_PAL_GAME_FREAK_INTRO
	call RunPaletteCommand
	
	; Thanks @Zumilsawhat?#5982!
    call DisableLCD
    xor a
	ld [hWY], a
    ld hl, vChars2          ; tile $00
    ld de, vChars2 + $7f0   ; tile $7f
    ld c, $10
.clearboth_emptytiles
    ld [hli], a
    ld [de], a
    inc de
    dec c
    jr nz, .clearboth_emptytiles
    call EnableLCD

	call LoadFontTilePatterns

	ld a, %11100100
	ld [rBGP], a
	call UpdateGBCPal_BGP

	coord hl, 0, 2
	ld de, .title
	call PlaceString

	coord hl, 0, 7
	ld de, .pleasenodmca
	call PlaceString

	ld c, 180
	call DelayFrames

	call ClearScreen

	coord hl, 0, 7
	ld de, .support
	call PlaceString

	ld c, 180
	call DelayFrames

	ret
.title:
	db "    ", $54, "MON PINK    "
	db "       forked       "
	db "        from        "
	db "   pret/pokeyellow@"
.pleasenodmca:
	db "     THIS IS AN     "
	db "     UNOFFICIAL     "
	db "   FAN RECREATION"
	next ""
	next "    NO COPYRIGHT"
	next "    INFRINGEMENT"
	next "      INTENDED@"
.support:
	db "      Support       "
	db "      official      "
	db "      releases!@"

PlayShootingStar:
	callba LoadCopyrightAndTextBoxTiles
	ld c, 180
	call DelayFrames
	call ClearScreen
	call DisableLCD
	xor a
	ld [wCurOpponent], a
	call IntroDrawBlackBars
; write the black and white tiles
	ld hl, vChars2
	ld bc, $10
	xor a
	call FillMemory
	ld hl, vChars2 + $10
	ld bc, $10
	ld a, $ff
	call FillMemory
; copy gamefreak logo and others
	ld hl, GameFreakIntro
	ld de, vChars2 + $600
	ld bc, GameFreakIntroEnd - GameFreakIntro
	ld a, BANK(GameFreakIntro)
	call FarCopyData
	ld hl, GameFreakIntro
	ld de, vChars1
	ld bc, GameFreakIntroEnd - GameFreakIntro
	ld a, BANK(GameFreakIntro)
	call FarCopyData

	call EnableLCD
	ld hl, rLCDC
	res 5, [hl]
	set 3, [hl]
	ld c, 64
	call DelayFrames
	callba AnimateShootingStar
	push af
	pop af
	jr c, .next ; skip the delay if the user interrupted the animation
	ld c, 40
	call DelayFrames
.next
	call IntroClearMiddleOfScreen
	call ClearSprites
	jp Delay3

IntroDrawBlackBars:
; clear the screen and draw black bars on the top and bottom
	call IntroClearScreen
	coord hl, 0, 0
	ld c, SCREEN_WIDTH * 4
	call IntroPlaceBlackTiles
	coord hl, 0, 14
	ld c, SCREEN_WIDTH * 4
	call IntroPlaceBlackTiles
	ld hl, vBGMap1
	ld c, $80
	call IntroPlaceBlackTiles
	ld hl, vBGMap1 + $1c0
	ld c, $80
	jp IntroPlaceBlackTiles

EmptyFunc4:
	ret

GameFreakIntro:
	INCBIN "gfx/gamefreak_intro.2bpp"
	INCBIN "gfx/gamefreak_logo.2bpp"
	ds $10 ; blank tile
GameFreakIntroEnd:
