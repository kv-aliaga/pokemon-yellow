; try to initiate a wild pokemon encounter
; returns success in Z
TryDoWildEncounter:
	ld a, [wNPCMovementScriptPointerTableNum]
	and a
	ret nz
	ld a, [wMovementFlags]
	and a ; is player exiting a door, jumping over a ledge, or fishing?
	ret nz
	callfar IsPlayerStandingOnDoorTileOrWarpTile
	jr nc, .notStandingOnDoorOrWarpTile
.CantEncounter
	ld a, $1
	and a
	ret
.notStandingOnDoorOrWarpTile
	callfar IsPlayerJustOutsideMap
	jr z, .CantEncounter
	ld a, [wRepelRemainingSteps]
	and a
	jr z, .next
	dec a
	jr z, .lastRepelStep
	ld [wRepelRemainingSteps], a
.next
; determine if wild pokemon can appear in the half-block we're standing in
; is the bottom left tile (8,9) of the half-block we're standing in a grass/water tile?
; note that by using the bottom left tile, this prevents the "left-shore" tiles from generating grass encounters
	hlcoord 8, 9
	ld c, [hl]
	ld a, [wGrassTile]
	cp c
	ld a, [wGrassRate]
	jr z, .CanEncounter
	ld a, $14 ; in all tilesets with a water tile, this is its id
	cp c
	ld a, [wWaterRate]
	jr z, .CanEncounter
; even if not in grass/water, standing anywhere we can encounter pokemon
; so long as the map is "indoor" and has wild pokemon defined.
; ...as long as it's not Viridian Forest or Safari Zone.
	ld a, [wCurMap]
	cp FIRST_INDOOR_MAP ; is this an indoor map?
	jr c, .CantEncounter2
	ld a, [wCurMapTileset]
	cp FOREST ; Viridian Forest/Safari Zone
	jr z, .CantEncounter2
	ld a, [wGrassRate]
.CanEncounter
; compare encounter chance with a random number to determine if there will be an encounter
	ld b, a
	ldh a, [hRandomAdd]
	cp b
	jr nc, .CantEncounter2
	ldh a, [hRandomSub]
	ld b, a
	ld hl, WildMonEncounterSlotChances
.determineEncounterSlot
	ld a, [hli]
	cp b
	jr nc, .gotEncounterSlot
	inc hl
	jr .determineEncounterSlot
.gotEncounterSlot
; determine which wild pokemon (grass or water) can appear in the half-block we're standing in
	ld c, [hl]
	ld hl, wGrassMons
	lda_coord 8, 9
	cp $14 ; is the bottom left tile (8,9) of the half-block we're standing in a water tile?
	jr nz, .gotWildEncounterType ; else, it's treated as a grass tile by default
	ld hl, wWaterMons
.gotWildEncounterType
	ld b, 0
	add hl, bc
	ld a, [hli]
	ld [wCurEnemyLevel], a
	ld a, [hl]
	ld [wCurPartySpecies], a
	ld [wEnemyMonSpecies2], a
	ld a, [wRepelRemainingSteps]
	and a
	jr nz, .CantEncounter2 ; an active Repel blocks every wild encounter, regardless of level
	jr .willEncounter
.lastRepelStep
	; $ff is outside the valid Repel duration range; NewBattle handles the UI.
	ld a, $ff
	ld [wRepelRemainingSteps], a
	jr .CantEncounter2
.CantEncounter2
	ld a, $1
	and a
	ret
.willEncounter
	xor a
	ret

DisplayRepelExpiryFlow::
	call GetStrongestRepelInBag
	jr z, .noRepel
	ld hl, RepelWoreOffText
	call PrintText
	; The replacement question is shorter; clear leftover characters from the notice.
	hlcoord 1, 14
	lb bc, 3, 18
	call ClearScreenArea
	call RepelReplacementPrompt
	scf ; the Yes/No choice consumed the button press
	ret
.noRepel
	ld hl, RepelWoreOffText
	call PrintText
	xor a ; no menu was shown, so let the expiry notice wait for dismissal
	ret

RepelReplacementPrompt::
	call GetStrongestRepelInBag
	ret z
	ld hl, RepelAgainText
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ret nz
; Recheck the Bag after confirmation and consume exactly one strongest available Repel.
	call GetStrongestRepelInBag
	ret z
	ldh [hItemToRemoveID], a
	cp MAX_REPEL
	jr z, .useMaxRepel
	cp SUPER_REPEL
	jr z, .useSuperRepel
	ld a, 100
	ld [wRepelRemainingSteps], a
	farcall RemoveItemByID
	ret
.useSuperRepel
	ld a, 200
	ld [wRepelRemainingSteps], a
	farcall RemoveItemByID
	ret
.useMaxRepel
	ld a, 250
	ld [wRepelRemainingSteps], a
	farcall RemoveItemByID
	ret

GetStrongestRepelInBag:
	ld a, [wNumBagItems]
	and a
	jr z, .none
	ld c, a
	ld hl, wBagItems
	ld d, 0
.loop
	ld a, [hli]
	ld b, a
	ld a, [hli] ; quantity
	and a
	jr z, .next
	ld a, b
	cp MAX_REPEL
	jr z, .maxRepel
	cp SUPER_REPEL
	jr z, .superRepel
	cp REPEL
	jr nz, .next
	ld a, d
	and a
	jr nz, .next
	ld d, REPEL
.next
	dec c
	jr nz, .loop
	ld a, d
	and a
	ret
.maxRepel
	ld a, MAX_REPEL
	and a
	ret
.superRepel
	ld d, SUPER_REPEL
	jr .next
.none
	xor a
	ret

RepelAgainText::
	text "Use another"
	line "REPEL?"
	text_end

RepelWoreOffText::
	text "REPEL's effect"
	line "wore off."
	text_end

INCLUDE "data/wild/probabilities.asm"
