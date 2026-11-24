NameRatersHouse_Script:
	jp EnableAutoTextBoxDrawing

NameRatersHouseYesNoScript:
	call PrintText
	call YesNoChoice
	ld a, [wCurrentMenuItem]
	and a
	ret

NameRatersHouse_TextPointers:
	def_text_pointers
	dw_const NameRatersHouseNameRaterText, TEXT_NAMERATERSHOUSE_NAME_RATER

NameRatersHouseNameRaterText:
	text_asm
	call SaveScreenTilesToBuffer2
	ld hl, .WantMeToRateText
	call NameRatersHouseYesNoScript
	jr nz, .did_not_rename
	ld hl, .WhichPokemonText
	call PrintText
	xor a
	ld [wPartyMenuTypeOrMessageID], a
	ld [wUpdateSpritesEnabled], a
	ld [wMenuItemToSwap], a
	call DisplayPartyMenu
	push af
	call GBPalWhiteOutWithDelay3
	call RestoreScreenTilesAndReloadTilePatterns
	call LoadGBPal
	pop af
	jr c, .did_not_rename
	call GetPartyMonName2
	ld hl, .GiveItANiceNameText
	call NameRatersHouseYesNoScript
	jr nz, .did_not_rename
	ld hl, .WhatShouldWeNameItText
	call PrintText
	farcall DisplayNameRaterScreen
	jr c, .did_not_rename
	ld hl, .PokemonHasBeenRenamedText
.done
	call PrintText
	jp TextScriptEnd
.did_not_rename
	ld hl, .ComeAnyTimeYouLikeText
	jr .done

.WantMeToRateText:
	text_far _NameRatersHouseNameRaterWantMeToRateText
	text_end

.WhichPokemonText:
	text_far _NameRatersHouseNameRaterWhichPokemonText
	text_end

.GiveItANiceNameText:
	text_far _NameRatersHouseNameRaterGiveItANiceNameText
	text_end

.WhatShouldWeNameItText:
	text_far _NameRatersHouseNameRaterWhatShouldWeNameItText
	text_end

.PokemonHasBeenRenamedText:
	text_far _NameRatersHouseNameRaterPokemonHasBeenRenamedText
	text_end

.ComeAnyTimeYouLikeText:
	text_far _NameRatersHouseNameRaterComeAnyTimeYouLikeText
	text_end
