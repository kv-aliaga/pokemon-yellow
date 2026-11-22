DiglettsCave_Script:
	jp EnableAutoTextBoxDrawing

DiglettsCave_TextPointers:
	def_text_pointers
	dw_const DiglettsCaveTradeNPCText, TEXT_DIGLETTSCAVE_TRADE_NPC

DiglettsCaveTradeNPCText:
	text_asm
	ld a, TRADE_FOR_HAUNTER_GRAVELER
	ld [wWhichTrade], a
	predef DoInGameTradeDialogue
	jp TextScriptEnd
