VermilionDock_Script:
	call EnableAutoTextBoxDrawing
	ld hl, wCurrentMapScriptFlags
	bit BIT_CUR_MAP_LOADED_1, [hl]
	res BIT_CUR_MAP_LOADED_1, [hl]
	call nz, VermilionDockMapLoaded
	CheckEventHL EVENT_STARTED_WALKING_OUT_OF_DOCK
	jr nz, .walking_out_of_dock
	CheckEventReuseHL EVENT_GOT_HM01
	ret z
	ld a, [wDestinationWarpID]
	cp $1
	ret nz
	; The warp ID is saved and can still be 1 when a game is resumed by the
	; truck. Only start the ship-exit sequence on the ship's dock warp.
	ld a, [wXCoord]
	cp 14
	ret nz
	ld a, [wYCoord]
	cp 2
	ret nz
	CheckEventReuseHL EVENT_SS_ANNE_LEFT
	jp z, VermilionDockSSAnneLeavesScript
	SetEventReuseHL EVENT_STARTED_WALKING_OUT_OF_DOCK
	call Delay3
	ld a, 3
	call VermilionDockSimulateNorthwardMovement
	ret

.walking_out_of_dock
	CheckEventAfterBranchReuseHL EVENT_WALKED_OUT_OF_DOCK, EVENT_STARTED_WALKING_OUT_OF_DOCK
	ret nz
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld [wJoyIgnore], a
	SetEventReuseHL EVENT_WALKED_OUT_OF_DOCK
	ret

VermilionDockMapLoaded:
	; The block loader has already cleared the ship before the map is drawn.
	; Remove the ship warp and handle the one-time re-entry movement.
	CheckEvent EVENT_SS_ANNE_LEFT
	ret z
	ld hl, wNumberOfWarps
	dec [hl]
	ld a, [wDestinationWarpID]
	cp $1 ; re-entry from either Vermilion City entrance
	ret nz
	CheckEvent EVENT_STARTED_WALKING_OUT_OF_DOCK
	ret z
	CheckEvent EVENT_WALKED_OUT_OF_DOCK
	ret z
	; The city warp lands on water after the ship is cleared. Step north onto
	; the passable dock tile, without repeating the one-time walk-out to the city.
	call Delay3
	ld a, 1
	call VermilionDockSimulateNorthwardMovement
	ret

VermilionDockPrepareMap::
	ld a, [wCurMap]
	cp VERMILION_DOCK
	ret nz
	CheckEvent EVENT_SS_ANNE_LEFT
	ret z
	jp VermilionDockClearShipBlocks

; Queue a northward movement sequence with the number of steps in a.
VermilionDockSimulateNorthwardMovement:
	ld c, a
	ld hl, wStatusFlags5
	set BIT_SCRIPTED_MOVEMENT_STATE, [hl]
	ld hl, wSimulatedJoypadStatesEnd
	ld a, PAD_UP
	ld b, c
.queueStep
	ld [hli], a
	dec b
	jr nz, .queueStep
	ld a, c
	ld [wSimulatedJoypadStatesIndex], a
	xor a
	ld [wSpritePlayerStateData2MovementByte1], a
	ld [wOverrideSimulatedJoypadStatesMask], a
	dec a
	ld [wJoyIgnore], a
	ret

VermilionDockSSAnneLeavesScript:
	SetEventForceReuseHL EVENT_SS_ANNE_LEFT
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	call StopAllMusic
	ld c, BANK(Music_Surfing)
	ld a, MUSIC_SURFING
	call PlayMusic
	farcall LoadSmokeTileFourTimes
	xor a
	ld [wSpritePlayerStateData1ImageIndex], a
	ld c, 120
	call DelayFrames
	ld b, HIGH(vBGMap1)
	call CopyScreenTileBufferToVRAM
	hlcoord 0, 10
	ld bc, SCREEN_WIDTH * 6
	ld a, $14 ; water tile
	call FillMemory
	ld a, 1
	ldh [hAutoBGTransferEnabled], a
	call Delay3
	xor a
	ldh [hAutoBGTransferEnabled], a
	ld [wSSAnneSmokeDriftAmount], a
	ldh [rOBP1], a
	call UpdateCGBPal_OBP1
	ld a, 88
	ld [wSSAnneSmokeX], a
	ld hl, wMapViewVRAMPointer
	ld c, [hl]
	inc hl
	ld b, [hl]
	push bc
	push hl
	ld a, SFX_SS_ANNE_HORN
	call PlaySoundWaitForCurrent
	ld a, $ff
	ld [wUpdateSpritesEnabled], a
	ld d, $0
	ld e, $8
.shift_columns_up
	ld hl, $2
	add hl, bc
	ld a, l
	ld [wMapViewVRAMPointer], a
	ld a, h
	ld [wMapViewVRAMPointer + 1], a
	push hl
	push de
	call ScheduleEastColumnRedraw
	call VermilionDock_EmitSmokePuff
	pop de
	ld b, $10
.smoke_puff_drift_loop
	call VermilionDock_AnimSmokePuffDriftRight
	ld c, $8
.delay_between_drifts
	call VermilionDock_SyncScrollWithLY
	dec c
	jr nz, .delay_between_drifts
	inc d
	dec b
	jr nz, .smoke_puff_drift_loop
	pop bc
	dec e
	jr nz, .shift_columns_up
	xor a
	ldh [rWY], a
	ldh [hWY], a
	call VermilionDock_EraseSSAnne
	ld a, SFX_SS_ANNE_HORN
	call PlaySound
	ld c, 120
	call DelayFrames
	ld a, $90
	ldh [hWY], a
	ld a, $1
	ld [wUpdateSpritesEnabled], a
	pop hl
	pop bc
	ld [hl], b
	dec hl
	ld [hl], c
	call LoadPlayerSpriteGraphics
	farcall RedrawMapView
	ld hl, wNumberOfWarps
	dec [hl]
	ret

VermilionDock_AnimSmokePuffDriftRight:
	push bc
	push de
	ld hl, wShadowOAMSprite04XCoord
	ld a, [wSSAnneSmokeDriftAmount]
	swap a
	ld c, a
	ld de, OBJ_SIZE
.drift_loop
	inc [hl]
	inc [hl]
	add hl, de
	dec c
	jr nz, .drift_loop
	pop de
	pop bc
	ret

VermilionDock_EmitSmokePuff:
; new smoke puff above the S.S. Anne's front smokestack
	ld a, [wSSAnneSmokeX]
	sub 16
	ld [wSSAnneSmokeX], a
	ld c, a
	ld b, 100 ; Y
	ld a, [wSSAnneSmokeDriftAmount]
	inc a
	ld [wSSAnneSmokeDriftAmount], a
	ld a, $1
	ld de, VermilionDockOAMBlock
	call WriteOAMBlock
	ret

VermilionDockOAMBlock:
; tile ID, attributes
	db $fc, OAM_PAL1
	db $fd, OAM_PAL1
	db $fe, OAM_PAL1
	db $ff, OAM_PAL1

VermilionDock_SyncScrollWithLY:
	ld h, d
	ld l, $50
	call .sync_scroll_ly
	ld h, $0
	ld l, $80
.sync_scroll_ly
	ldh a, [rLY]
	cp l
	jr nz, .sync_scroll_ly
	ld a, h
	ldh [rSCX], a
.wait_for_ly_match
	ldh a, [rLY]
	cp h
	jr z, .wait_for_ly_match
	ret

VermilionDockClearShipBlocks::
; Replace the ship's full block footprint so later map scrolling cannot redraw
; either half from the source layout.
	hlowcoord 5, 1, VERMILION_DOCK_WIDTH
	ld a, $d ; water block
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	hlowcoord 5, 2, VERMILION_DOCK_WIDTH
	ld a, $d ; water block
	ld [hli], a
	ld [hli], a
	ld [hli], a
	ld [hl], a
	ret

VermilionDock_EraseSSAnne:
; Update the live map; the caller redraws it after restoring the VRAM pointer.
	call VermilionDockClearShipBlocks
	ret

VermilionDock_TextPointers:
	def_text_pointers
	dw_const VermilionDockMewText,        TEXT_VERMILIONDOCK_MEW
	dw_const VermilionDockNeedsPartyText, TEXT_VERMILIONDOCK_NEEDS_PARTY

VermilionDockNeedsPartyText:
	text "You need a POKéMON"
	line "to face MEW."
	done
	text_end

VermilionDockMewText:
	text "MEW leaps out from"
	line "under the truck!@"
	text_asm
	ld a, MEW
	call PlayCry
	call WaitForSoundToFinish
	jp TextScriptEnd

VermilionDockTruckHiddenEvent::
	ld a, [wHiddenEventFunctionArgument]
	and a
	jr z, .checkAvailability
	ld a, [wSpritePlayerStateData1FacingDirection]
	cp SPRITE_FACING_UP
	ret nz
.checkAvailability
	CheckEvent EVENT_BEAT_MEW
	ret nz
	; A caught Mew stays unavailable even on saves without the event flag.
	ld hl, wPokedexOwned + (DEX_MEW - 1) / 8
	bit (DEX_MEW - 1) % 8, [hl]
	ret nz
	ld a, [wPartyCount]
	and a
	jr z, .noParty
	ld a, TEXT_VERMILIONDOCK_MEW
	ldh [hTextID], a
	call DisplayTextID
	call VermilionDockSetMewLevel
	; Record the encounter before handing control to the battle loop so it
	; survives saving after capture, defeat, escape, or blackout.
	SetEvent EVENT_BEAT_MEW
	ld a, MEW
	ld [wCurOpponent], a
	ret
.noParty
	ld a, TEXT_VERMILIONDOCK_NEEDS_PARTY
	ldh [hTextID], a
	jp DisplayTextID

VermilionDockSetMewLevel:
	ld a, [wPartyCount]
	ld b, a
	ld hl, wPartyMon1Level
	ld c, 0
.nextMon
	ld a, [hl]
	cp c
	jr c, .keepMax
	ld c, a
.keepMax
	ld de, PARTYMON_STRUCT_LENGTH
	add hl, de
	dec b
	jr nz, .nextMon
	ld a, c
	add 5
	cp 100
	jr c, .setLevel
	ld a, 100
.setLevel
	ld [wCurEnemyLevel], a
	ret
