	const_export DIGLETTSCAVE_TRADE_NPC

DiglettsCave_Object:
	db $19 ; border block

	def_warp_events
	warp_event  5,  5, DIGLETTS_CAVE_ROUTE_2, 3
	warp_event 37, 31, DIGLETTS_CAVE_ROUTE_11, 3

	def_bg_events

	def_object_events

	object_event 10,  9, SPRITE_SUPER_NERD, STAY, DOWN, TEXT_DIGLETTSCAVE_TRADE_NPC
	def_warps_to DIGLETTS_CAVE
