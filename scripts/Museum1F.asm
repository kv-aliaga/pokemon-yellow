Museum1F_Script:
	ld a, 1 << BIT_NO_AUTO_TEXT_BOX
	ld [wAutoTextBoxDrawingControl], a
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ld hl, Museum1F_ScriptPointers
	ld a, [wMuseum1FCurScript]
	call CallFunctionInTable
	ret

Museum1F_ScriptPointers:
	def_script_pointers
	dw_const Museum1FDefaultScript,                  SCRIPT_MUSEUM1F_DEFAULT
	dw_const Museum1FNoopScript,                    SCRIPT_MUSEUM1F_START_BATTLE
	dw_const Museum1FEndBattleScript,               SCRIPT_MUSEUM1F_END_BATTLE
	dw_const Museum1FNoopScript,                    SCRIPT_MUSEUM1F_NOOP

Museum1FDefaultScript:
	ld a, [wYCoord]
	cp 4
	ret nz
	ld a, [wXCoord]
	cp 9
	jr z, .showAutomaticText
	ld a, [wXCoord]
	cp 10
	ret nz
.showAutomaticText
	xor a
	ldh [hJoyHeld], a
	ld a, TEXT_MUSEUM1F_SCIENTIST1
	ldh [hTextID], a
	jp DisplayTextID

Museum1FEndBattleScript:
	call EndTrainerBattle
	call Museum1FGiveFossilReward
	xor a
	ld [wCurMapScript], a
	ld [wMuseum1FCurScript], a
	ret

Museum1FGiveFossilReward:
	CheckEvent EVENT_BEAT_MUSEUM_SUPER_NERD_REMATCH
	ret z
	CheckEvent EVENT_GOT_MUSEUM_FOSSIL_REWARD
	ret nz
	CheckEvent EVENT_GOT_HELIX_FOSSIL
	jr nz, .giveDome
	lb bc, HELIX_FOSSIL, 1
	call GiveItem
	ret nc
	SetEvent EVENT_GOT_MUSEUM_FOSSIL_REWARD
	ld hl, Museum1FReceivedHelixText
	call PrintText
	ret
.giveDome
	lb bc, DOME_FOSSIL, 1
	call GiveItem
	ret nc
	SetEvent EVENT_GOT_MUSEUM_FOSSIL_REWARD
	ld hl, Museum1FReceivedDomeText
	call PrintText
	ret

Museum1FNoopScript:
	ret

Museum1F_TextPointers:
	def_text_pointers
	dw_const Museum1FScientist1Text, TEXT_MUSEUM1F_SCIENTIST1
	dw_const Museum1FGamblerText,    TEXT_MUSEUM1F_GAMBLER
	dw_const Museum1FScientist2Text, TEXT_MUSEUM1F_SCIENTIST2
	dw_const Museum1FScientist3Text, TEXT_MUSEUM1F_SCIENTIST3
	dw_const Museum1FOldAmberText,   TEXT_MUSEUM1F_OLD_AMBER
	dw_const Museum1FSuperNerdText, TEXT_MUSEUM1F_SUPER_NERD
	dw_const Museum1FFossilResearcherText, TEXT_MUSEUM1F_FOSSIL_RESEARCHER

Museum1FScientist1Text:
	text_asm
	farcall Museum1FPrintScientist1Text
	jp TextScriptEnd

Museum1FGamblerText:
	text_asm
	farcall Museum1FPrintGamblerText
	jp TextScriptEnd

Museum1FScientist2Text:
	text_asm
	farcall Museum1FPrintScientist2Text
	jp TextScriptEnd

Museum1FScientist3Text:
	text_asm
	farcall Museum1FPrintScientist3Text
	jp TextScriptEnd

Museum1FOldAmberText:
	text_asm
	farcall Museum1FPrintOldAmberText
	jp TextScriptEnd

Museum1FSuperNerdText:
	text_asm
	CheckEvent EVENT_BEAT_LT_SURGE
	jr nz, .ready
	ld hl, Museum1FRematchLockedText
	call PrintText
	jp TextScriptEnd
.ready
	CheckEvent EVENT_BEAT_MUSEUM_SUPER_NERD_REMATCH
	jr z, .startBattle
	call Museum1FGiveFossilReward
	jp TextScriptEnd
.startBattle
	ld a, [wSpriteIndex]
	dec a
	add a
	ld e, a
	ld d, 0
	ld hl, wMapSpriteExtraData
	add hl, de
	inc hl
	CheckEvent EVENT_GOT_DOME_FOSSIL
	ld a, 13 ; Kabuto if Helix was chosen; Omanyte follows at index 12.
	jr z, .partyReady
	ld a, 12
.partyReady
	ld [hl], a
	ld hl, Museum1FSuperNerdTrainerHeader
	call TalkToTrainer
	ld a, [wCurMapScript]
	ld [wMuseum1FCurScript], a
	jp TextScriptEnd

Museum1FSuperNerdTrainerHeader:
	trainer EVENT_BEAT_MUSEUM_SUPER_NERD_REMATCH, 0, Museum1FSuperNerdBeforeText, Museum1FSuperNerdAfterText, Museum1FSuperNerdAfterText
	db -1

Museum1FSuperNerdBeforeText:
	text "Let's settle this"
	line "fossil debate!@"
	text_end

Museum1FSuperNerdAfterText:
	text "You've made your"
	line "point!@"
	text_end

Museum1FRematchLockedText:
	text "He is studying the"
	line "fossils for now."
	prompt
	text_end

Museum1FReceivedHelixText:
	text "You received the"
	line "HELIX FOSSIL!"
	prompt
	text_end

Museum1FReceivedDomeText:
	text "You received the"
	line "DOME FOSSIL!"
	prompt
	text_end

Museum1FFossilResearcherText:
	text_asm
	CheckEvent EVENT_GAVE_FOSSIL_TO_LAB
	jr nz, .checkRevival
	ld hl, .OfferText
	call PrintText
	farcall Lab4Script_GetFossilsInBag
	ld a, [wFilteredBagItemsCount]
	and a
	jr z, .noFossils
	farcall GiveFossilToCinnabarLab
	jp TextScriptEnd
.noFossils
	CheckEvent EVENT_GOT_HM01
	jr nz, .noFossilsText
	ld a, OLD_AMBER
	ld b, a
	predef GetQuantityOfItemInBag
	ld a, b
	and a
	jr z, .noFossilsText
	ld hl, .NeedCutText
	call PrintText
	jp TextScriptEnd
.noFossilsText
	ld hl, .NoFossilsText
	call PrintText
	jp TextScriptEnd
.checkRevival
	CheckEvent EVENT_LAB_STILL_REVIVING_FOSSIL
	jr nz, .stillReviving
	farcall LoadFossilItemAndMonName
	ld hl, .FossilRevivedText
	call PrintText
	SetEvent EVENT_LAB_HANDING_OVER_FOSSIL_MON
	ld a, [wFossilMon]
	ld b, a
	ld c, 30
	call GivePokemon
	jr c, .clearRevival
	jp TextScriptEnd
.clearRevival
	ResetEvents EVENT_GAVE_FOSSIL_TO_LAB, EVENT_LAB_STILL_REVIVING_FOSSIL, EVENT_LAB_HANDING_OVER_FOSSIL_MON
	jp TextScriptEnd
.stillReviving
	ld hl, .GoForAWalkText
	call PrintText
	jp TextScriptEnd
.OfferText
	text "I can revive fossils"
	line "for you here, too."
	prompt
	text_end
.NoFossilsText
	text "Bring me a fossil"
	line "when you find one."
	prompt
	text_end
.NeedCutText
	text "You need CUT to reach"
	line "the Old Amber here."
	prompt
	text_end
.GoForAWalkText
	text "The revival is still"
	line "in progress."
	prompt
	text_end
.FossilRevivedText
	text "Your fossil is back"
	line "to life!"
	prompt
	text_end
