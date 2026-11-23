HealParty:
; Restore HP and PP.

	ld hl, wPartySpecies
	ld de, wPartyMon1HP
.healmon
	ld a, [hli]
	cp $ff
	jr z, .done

	push hl
	push de

	ld hl, MON_STATUS - MON_HP
	add hl, de
	xor a
	ld [hl], a

	push de
	ld b, NUM_MOVES ; A Pokémon has 4 moves
.pp
	ld hl, MON_MOVES - MON_HP
	add hl, de

	ld a, [hl]
	and a
	jr z, .nextmove

	dec a
	ld hl, MON_PP - MON_HP
	add hl, de

	push hl
	push de
	push bc

	ld hl, Moves
	ld bc, MOVE_LENGTH
	call AddNTimes
	ld de, wMoveData
	ld a, BANK(Moves)
	call FarCopyData
	ld a, [wMoveData + MOVE_PP]

	pop bc
	pop de
	pop hl

	inc de
	push bc
	ld b, a
	ld a, [hl]
	and PP_UP_MASK
	add b
	ld [hl], a
	pop bc

.nextmove
	dec b
	jr nz, .pp
	pop de

	ld hl, MON_MAXHP - MON_HP
	add hl, de
	ld a, [hli]
	ld [de], a
	inc de
	ld a, [hl]
	ld [de], a

	pop de
	pop hl

	push hl
	ld bc, PARTYMON_STRUCT_LENGTH
	ld h, d
	ld l, e
	add hl, bc
	ld d, h
	ld e, l
	pop hl
	jr .healmon

.done
	xor a
	ld [wWhichPokemon], a
	ld [wUsingPPUp], a

	ld a, [wPartyCount]
	ld b, a
.ppup
	push bc
	call RestoreBonusPP
	pop bc
	ld hl, wWhichPokemon
	inc [hl]
	dec b
	jr nz, .ppup
	ret

HealBoxedPokemon:
	; These shared selection fields belong to the surrounding nurse flow.
	ld a, [wMonDataLocation]
	push af
	ld a, [wWhichPokemon]
	push af
	ld a, [wUsingPPUp]
	push af
	ld a, [wCurrentMenuItem]
	push af
	ld a, [wCurPartySpecies]
	push af
	ld a, [wCurSpecies]
	push af
	ld a, [wCurEnemyLevel]
	push af
	ld a, [wBuffer]
	push af

	; Preserve the active box before using it as scratch space for saved boxes.
	callfar SaveCurrentBoxData
	call HealBoxData
	callfar SaveCurrentBoxData

	; The active box's saved slot can be stale, so leave it out of this pass.
	xor a
	ld [wBuffer], a ; saved box number (0-11)
.savedBoxLoop
	ld a, [wBuffer]
	ld c, a
	ld a, [wCurrentBoxNum]
	and BOX_NUM_MASK
	cp c
	jr z, .nextSavedBox

	call GetHealBoxSRAMLocation
	push bc ; box number and SRAM bank
	push hl ; saved box address
	callfar EnableSRAM
	pop hl ; restore saved box pointer
	pop bc ; restore saved box bank
	ld a, b
	ld [rRAMB], a
	ld de, wBoxDataStart
	ld bc, wBoxDataEnd - wBoxDataStart
	call CopyData
	callfar DisableSRAM
	call HealBoxData

	call GetHealBoxSRAMLocation
	push bc
	push hl
	callfar EnableSRAM
	pop hl
	pop bc
	ld a, b
	ld [rRAMB], a
	push hl ; saved SRAM destination
	ld hl, wBoxDataStart
	pop de
	ld bc, wBoxDataEnd - wBoxDataStart
	call CopyData
	callfar DisableSRAM
.nextSavedBox
	ld hl, wBuffer
	inc [hl]
	ld a, [hl]
	cp NUM_BOXES
	jp nz, .savedBoxLoop

	; Rebuild both saved-box bank checksums using the save system's format.
	callfar EnableSRAM
	ld a, BANK("Saved Boxes 1")
	ld [rRAMB], a
	ld hl, sBox1
	ld bc, sBank2AllBoxesChecksum - sBox1
	call CalcSavedBoxChecksum
	ld [sBank2AllBoxesChecksum], a
	callfar CalcIndividualBoxCheckSums
	ld a, BANK("Saved Boxes 2")
	ld [rRAMB], a
	ld hl, sBox1
	ld bc, sBank2AllBoxesChecksum - sBox1
	call CalcSavedBoxChecksum
	ld [sBank2AllBoxesChecksum], a
	callfar CalcIndividualBoxCheckSums
	callfar DisableSRAM

	; Restore the active WRAM copy and refresh its main-save checksum.
	callfar EnableSRAM
	ld a, BANK("Save Data")
	ld [rRAMB], a
	ld hl, sCurBoxData
	ld de, wBoxDataStart
	ld bc, wBoxDataEnd - wBoxDataStart
	call CopyData
	callfar DisableSRAM
	callfar SaveCurrentBoxData
	pop af
	ld [wBuffer], a
	pop af
	ld [wCurEnemyLevel], a
	pop af
	ld [wCurSpecies], a
	pop af
	ld [wCurPartySpecies], a
	pop af
	ld [wCurrentMenuItem], a
	pop af
	ld [wUsingPPUp], a
	pop af
	ld [wWhichPokemon], a
	pop af
	ld [wMonDataLocation], a
	ret

CalcSavedBoxChecksum:
	; Same checksum as CalcCheckSum, computed here to stay in this ROM bank.
	ld d, 0
.loop
	ld a, [hli]
	add d
	ld d, a
	dec bc
	ld a, b
	or c
	jr nz, .loop
	ld a, d
	cpl
	ret

GetHealBoxSRAMLocation:
	; Return B = SRAM bank and HL = saved box address for wBuffer (0-11).
	ld a, [wBuffer]
	ld b, 2
	cp NUM_BOXES / 2
	jr c, .boxIndexReady
	inc b
	sub NUM_BOXES / 2
.boxIndexReady
	ld e, a
	ld d, 0
	ld hl, HealSavedBoxPointerTable
	add hl, de
	add hl, de
	ld a, [hli]
	ld h, [hl]
	ld l, a
	ret

HealSavedBoxPointerTable:
	dw sBox1, sBox2, sBox3, sBox4, sBox5, sBox6
	dw sBox7, sBox8, sBox9, sBox10, sBox11, sBox12

HealBoxData:
	ld a, BOX_DATA
	ld [wMonDataLocation], a
	ld a, [wBoxCount]
	and a
	ret z ; uninitialized and empty boxes have a zero count
	xor a
	ld [wWhichPokemon], a
	ld hl, wBoxSpecies
.monLoop
	ld a, [hli]
	cp $ff
	ret z
	and a
	jp z, .skipMon
	push hl

	; Box records don't store calculated stats, so recalculate max HP from
	; the stored level, experience, DVs, and stat experience.
	callfar LoadMonData
	ld hl, wBoxMons
	ld a, [wWhichPokemon]
	ld bc, BOXMON_STRUCT_LENGTH
	call AddNTimes
	ld bc, MON_BOX_LEVEL
	add hl, bc
	ld a, [hl]
	ld [wLoadedMonLevel], a
	ld [wCurEnemyLevel], a
	ld hl, wLoadedMonHPExp - 1
	ld de, wLoadedMonStats
	ld b, 1
	call CalcStats

	ld hl, wBoxMon1HP
	ld a, [wWhichPokemon]
	ld bc, BOXMON_STRUCT_LENGTH
	call AddNTimes
	ld de, wLoadedMonMaxHP
	ld a, [de]
	ld [hli], a
	inc de
	ld a, [de]
	ld [hli], a
	ld hl, wBoxMon1HP
	ld a, [wWhichPokemon]
	ld bc, BOXMON_STRUCT_LENGTH
	call AddNTimes
	ld bc, MON_STATUS - MON_HP
	add hl, bc
	xor a
	ld [hl], a ; status

	; GetMaxPP includes the existing PP-Up bits and caps PP at the real max.
	xor a
	ld [wCurrentMenuItem], a
.moveLoop
	ld a, [wCurrentMenuItem]
	ld hl, wBoxMon1Moves
	ld bc, BOXMON_STRUCT_LENGTH
	ld a, [wWhichPokemon]
	call AddNTimes
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [hl]
	and a
	jr z, .skipMove
	ld a, [wCurrentMenuItem]
	callfar GetMaxPP
	ld hl, wBoxMon1PP
	ld a, [wWhichPokemon]
	ld bc, BOXMON_STRUCT_LENGTH
	call AddNTimes
	ld a, [wCurrentMenuItem]
	ld c, a
	ld b, 0
	add hl, bc
	ld a, [wMaxPP]
	ld [hl], a
.skipMove
	ld hl, wCurrentMenuItem
	inc [hl]
	ld a, [hl]
	cp NUM_MOVES
	jr nz, .moveLoop

	pop hl
	ld a, [wWhichPokemon]
	inc a
	ld [wWhichPokemon], a
	ld b, a
	ld a, [wBoxCount]
	cp b
	jp nz, .monLoop
	ret
.skipMon
	ld a, [wWhichPokemon]
	inc a
	ld [wWhichPokemon], a
	ld b, a
	ld a, [wBoxCount]
	cp b
	jp nz, .monLoop
	ret
