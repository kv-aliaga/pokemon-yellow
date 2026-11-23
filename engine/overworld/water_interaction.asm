CheckWaterInteraction::
	predef GetTileAndCoordsInFrontOfPlayer
	lda_coord 8, 9 ; tile the player is standing on
	ld [wTilePlayerStandingOn], a
	callfar IsNextTileShoreOrWater
	ret nc
	ld hl, TilePairCollisionsWater
	callfar CheckForTilePairCollisions
	ret c
	call FindPartyMonThatKnowsSurf
	ret nc
	ld a, [wWhichPokemon]
	push af
	ld a, [wCurPartySpecies]
	push af
	tx_pre_id WaterInteractionText
	call PrintPredefTextID
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld a, [wChosenMenuItem]
	and a ; did the player choose No?
	jr z, .startSurf
	pop af
	ld [wCurPartySpecies], a
	pop af
	ld [wWhichPokemon], a
	ret
.startSurf
	pop af ; discard the saved party selection
	pop af ; discard the saved party species
	farcall TryStartSurf
	ret

FindPartyMonThatKnowsSurf:
	ld a, [wPartyCount]
	and a
	ret z
	ld b, a
	ld a, [wWhichPokemon]
	push af ; preserve the existing party selection if no Pokémon knows Surf
	xor a
	ld [wWhichPokemon], a
	ld hl, wPartyMon1Species
.partyLoop
	push bc
	push hl ; preserve the current Pokémon's species address
	ld bc, MON_MOVES
	add hl, bc
	ld c, NUM_MOVES
.moveLoop
	ld a, [hli]
	cp SURF
	jr z, .foundSurf
	dec c
	jr nz, .moveLoop
	pop hl
	pop bc
	ld de, PARTYMON_STRUCT_LENGTH
	add hl, de
	ld a, [wWhichPokemon]
	inc a
	ld [wWhichPokemon], a
	dec b
	jr nz, .partyLoop
	pop af
	ld [wWhichPokemon], a
	and a
	ret
.foundSurf
	pop hl
	pop bc
	pop af ; discard the old party selection
	ld a, [hl]
	ld [wCurPartySpecies], a
	scf
	ret

WaterInteractionText::
	text "Would you like to"
	line "use SURF?@"
	text_asm
	call YesNoChoice
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	jp TextScriptEnd
