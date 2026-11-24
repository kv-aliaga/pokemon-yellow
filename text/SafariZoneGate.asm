_SafariZoneGateSafariZoneWorker1Text::
	text "Welcome to the"
	line "SAFARI ZONE!"
	done

_SafariZoneGateSafariZoneWorker1LeavingEarlyText::
	text "Leaving early?@"
	text_end

_SafariZoneGateSafariZoneWorker1ReturnSafariBallsText::
	text "Please return any"
	line "SAFARI BALLs you"
	cont "have left."
	done

_SafariZoneGateSafariZoneWorker1GoodLuckText::
	text "Good Luck!"
	done

_SafariZoneGateSafariZoneWorker1GoodHaulComeAgainText::
	text "Did you get a"
	line "good haul?"
	cont "Come again!"
	done

_SafariZoneGateSafariZoneWorker1WouldYouLikeToJoinText::
	text "¥500: 30 BALLS,"
	line "500 steps."

	para "¥1500: 100 BALLS,"
	line "no step limit!"

	para "Choose a mode.@"
	text_end

_SafariZoneGateSafariZoneWorker1ThatllBe500PleaseText::
	text "That'll be ¥@"
	text_bcd wPriceTemp, $c3
	text ","
	line "please!"

	para "We only use a"
	line "special # BALL"
	cont "here.@"
	text_end


_SafariZoneGateSafariZoneWorker1Received30SafariBallsText::
	text_start
	para "<PLAYER> received"
	line "30 SAFARI BALLs!@"
	text_end

_SafariZoneGateSafariZoneWorker1Received100SafariBallsText::
	text_start
	para "<PLAYER> received"
	line "100 SAFARI BALLs!@"
	text_end

_SafariZoneGateSafariZoneWorker1CallYouOnThePAText::
	text_start

	para "We'll call you on"
	line "the PA when you"
	cont "run out of time"
	cont "or SAFARI BALLs!"
	done

_SafariZoneGateSafariZoneWorker1CallYouOnThePAUnlimitedText::
	text_start

	para "We'll call you on"
	line "the PA when you"
	cont "run out of SAFARI"
	cont "BALLs!"
	done

_SafariZoneGateSafariZoneWorker1PleaseComeAgainText::
	text "OK! Please come"
	line "again!"
	done

_SafariZoneGateSafariZoneWorker1NotEnoughMoneyText::
	text "Oops! Not enough"
	line "money!"
	done

_SafariZoneGateSafariZoneWorker2FirstTimeHereText::
	text "Hi! Is it your"
	line "first time here?"
	done

_SafariZoneGateSafariZoneWorker2SafariZoneExplanationText::
	text "SAFARI ZONE has 4"
	line "zones in it."

	para "Each zone has"
	line "different kinds"
	cont "of #MON. Use"
	cont "SAFARI BALLs to"
	cont "catch them!"

	para "When you run out"
	line "of time or SAFARI"
	cont "BALLs, it's game"
	cont "over for you!"

	para "Before you go,"
	line "open an unused"
	cont "#MON BOX so"
	cont "there's room for"
	cont "new #MON!"
	done

_SafariZoneGateSafariZoneWorker2YoureARegularHereText::
	text "Sorry, you're a"
	line "regular here!"
	done

_SafariZoneLowCostText1::
	text_start

	para "Oh, all right, pay"
	line "me what you have."
	prompt

_SafariZoneLowCostText2::
	text "But, I can't give"
	line "you all 30 BALLs."
	done

_SafariZoneLowCostText3::
	text_start

	para "You're persistent,"
	line "aren't you?"

	para "OK, you can go in"
	line "for free, but"
	cont "just this once!@"
	text_end

_SafariZoneLowCostText4::
	text_start
	done

_SafariZoneLowCostText5::
	text "I'm sorry, but you"
	line "have to pay to"
	cont "enter."
	done

_SafariZoneLowCostText6::
	text "You can't enter"
	line "without paying!"
	done

_SafariZoneLowCostText7::
	text "I said, no money,"
	line "no entry!"
	done

_SafariZoneLowCostText8::
	text "Read my lips, NO!"
	line "Get it?"
	done
