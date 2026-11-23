CheckWaterInteraction::
	predef GetTileAndCoordsInFrontOfPlayer
	ld a, [wTileInFrontOfPlayer]
	cp $14 ; water tile
	ret nz
	callfar IsNextTileShoreOrWater
	ret nc
	tx_pre_id WaterInteractionText
	call PrintPredefTextID
	xor a
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	ret

WaterInteractionText::
	text "TO-DO@"
	text_asm
	call YesNoChoice
	ld a, 1
	ld [wDoNotWaitForButtonPressAfterDisplayingText], a
	jp TextScriptEnd
