HallOfFame_Script:
	call EnableAutoTextBoxDrawing
	ld hl, HallOfFame_ScriptPointers
	ld a, [wHallOfFameCurScript]
	jp CallFunctionInTable

HallofFameRoomClearScripts: ; unreferenced
	xor a
	ld [wJoyIgnore], a
	ld [wHallOfFameCurScript], a
	ret

HallOfFame_ScriptPointers:
	def_script_pointers
	dw_const HallOfFameDefaultScript,            SCRIPT_HALLOFFAME_DEFAULT
	dw_const HallOfFameOakCongratulationsScript, SCRIPT_HALLOFFAME_OAK_CONGRATULATIONS
	dw_const HallOfFameResetEventsAndSaveScript, SCRIPT_HALLOFFAME_RESET_EVENTS_AND_SAVE
	dw_const HallOfFameNoopScript,               SCRIPT_HALLOFFAME_NOOP

HallOfFameNoopScript:
	ret

HallOfFameResetEventsAndSaveScript:
	call Delay3
	ld a, [wLetterPrintingDelayFlags]
	push af
	xor a
	ld [wJoyIgnore], a
	predef HallOfFamePC
	pop af
	ld [wLetterPrintingDelayFlags], a
	ld hl, wStatusFlags7
	res BIT_NO_MAP_MUSIC, [hl]
	ASSERT wStatusFlags7 + 1 == wElite4Flags
	inc hl
	set BIT_UNUSED_BEAT_ELITE_4, [hl] ; full Elite Four victory
	call HallOfFameRearmUncaughtLegendaries
	xor a ; SCRIPT_*_DEFAULT
	ld hl, wLoreleisRoomCurScript
	ld [hli], a ; wLoreleisRoomCurScript
	ld [hli], a ; wBrunosRoomCurScript
	ld [hl], a ; wAgathasRoomCurScript
	ld [wLancesRoomCurScript], a
	ld [wHallOfFameCurScript], a
	; Elite 4 events
	ResetEventRange INDIGO_PLATEAU_EVENTS_START, INDIGO_PLATEAU_EVENTS_END, 1
	xor a
	ld [wHallOfFameCurScript], a
	ld a, PALLET_TOWN
	ld [wLastBlackoutMap], a
	farcall SaveGameData
	ld b, 5
.delayLoop
	ld c, 600 / 5
	call DelayFrames
	dec b
	jr nz, .delayLoop
	call WaitForTextScrollButtonPress
	jp Init

HallOfFameDefaultScript:
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld hl, wSimulatedJoypadStatesEnd
	ld de, HallOfFameEntryMovement
	call DecodeRLEList
	dec a
	ld [wSimulatedJoypadStatesIndex], a
	call StartSimulatingJoypadStates
	ld a, SCRIPT_HALLOFFAME_OAK_CONGRATULATIONS
	ld [wHallOfFameCurScript], a
	ret

HallOfFameEntryMovement:
	db PAD_UP, 5
	db -1 ; end

HallOfFameOakCongratulationsScript:
	ld a, [wSimulatedJoypadStatesIndex]
	and a
	ret nz
	ld a, PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, HALLOFFAME_OAK
	ldh [hSpriteIndex], a
	call SetSpriteMovementBytesToFF
	ld a, SPRITE_FACING_LEFT
	ldh [hSpriteFacingDirection], a
	call SetSpriteFacingDirectionAndDelay
	call Delay3
	xor a
	ld [wJoyIgnore], a
	inc a ; PLAYER_DIR_RIGHT
	ld [wPlayerMovingDirection], a
	ld a, TEXT_HALLOFFAME_OAK
	ldh [hTextID], a
	call DisplayTextID
	ld a, PAD_BUTTONS | PAD_CTRL_PAD
	ld [wJoyIgnore], a
	ld a, TOGGLE_CERULEAN_CAVE_GUY
	ld [wToggleableObjectIndex], a
	predef HideObject
	ld a, SCRIPT_HALLOFFAME_RESET_EVENTS_AND_SAVE
	ld [wHallOfFameCurScript], a
	ret

HallOfFame_TextPointers:
	def_text_pointers
	dw_const HallOfFameOakText, TEXT_HALLOFFAME_OAK

HallOfFameOakText:
	text_far _HallOfFameOakText
	text_end

HallOfFameRearmUncaughtLegendaries:
	ld a, ARTICUNO
	call HallOfFameCheckOwned
	jr nz, .articunoOwned
	ResetEvent EVENT_BEAT_ARTICUNO
	ld a, TOGGLE_ARTICUNO
	ld [wToggleableObjectIndex], a
	predef ShowObject
.articunoOwned
	ld a, ZAPDOS
	call HallOfFameCheckOwned
	jr nz, .zapdosOwned
	ResetEvent EVENT_BEAT_ZAPDOS
	ld a, TOGGLE_ZAPDOS
	ld [wToggleableObjectIndex], a
	predef ShowObject
.zapdosOwned
	ld a, MOLTRES
	call HallOfFameCheckOwned
	jr nz, .moltresOwned
	ResetEvent EVENT_BEAT_MOLTRES
	ld a, TOGGLE_MOLTRES
	ld [wToggleableObjectIndex], a
	predef ShowObject
.moltresOwned
	ld a, MEWTWO
	call HallOfFameCheckOwned
	jr nz, .mewtwoOwned
	ResetEvent EVENT_BEAT_MEWTWO
	ld a, TOGGLE_MEWTWO
	ld [wToggleableObjectIndex], a
	predef ShowObject
.mewtwoOwned
	ld a, MEW
	call HallOfFameCheckOwned
	ret nz
	ResetEvent EVENT_BEAT_MEW
	ld a, TOGGLE_VERMILION_DOCK_MEW
	ld [wToggleableObjectIndex], a
	predef ShowObject
	ret

HallOfFameCheckOwned:
	ld [wPokedexNum], a
	predef IndexToPokedex
	ld a, [wPokedexNum]
	dec a
	ld c, a
	ld hl, wPokedexOwned
	ld b, FLAG_TEST
	predef FlagActionPredef
	ld a, c
	and a
	ret
