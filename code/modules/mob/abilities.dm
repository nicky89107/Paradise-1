/*
Creature-level abilities.
*/

/var/global/list/ability_verbs = list(	)


/mob/living/carbon/human/slime/proc/slimepeople_ventcrawl()

	set category = "Abilities"
	set name = "Ventcrawl (Slime People)"
	set desc = "The ability to crawl through vents if naked and not holding anything."


	if(istype(usr,/mob/living/carbon/human/slime))
		var/mob/living/carbon/human/slime/M = usr
		// Check if the client has a mob and if the mob is valid and alive.
		if(M.stat==2)
			M << "\red You must be corporeal and alive to do that."
			return 0

		//Handcuff check.
		if(M.restrained())
			M << "\red You cannot do this while restrained."
			return 0

		if(M.handcuffed)
			M << "\red You cannot do this while cuffed."
			return 0

		if(M.contents.len != 0)
			M << "\red You need to be naked and have nothing in your hands to ventcrawl."
			return 0

		M.handle_ventcrawl()
	else
		src << "This should not be happening. At all."

/mob/living/carbon/human/slime/proc/change_gender()

	set category = "Abilities"
	set name = "Change Gender"
	set desc = "Change your own gender at will."

	if(istype(usr,/mob/living/carbon/human/slime))
		var/mob/living/carbon/human/slime/M = usr
		// Check if the client has a mob and if the mob is valid and alive.
		if(M.stat==2)
			M << "\red You must be corporeal and alive to do that."
			return 0

		if(M.gender == MALE)
			M.gender = FEMALE
			M.update_icons()
			M.regenerate_icons()
			M.visible_message("You make yourself female!")
			return 1
		else
			M.gender = MALE
			M.update_icons()
			M.regenerate_icons()
			M.visible_message("You make yourself male!")
			return 1

	else
		src << "This should not be happening. At all."


/mob/living/carbon/human/slime/proc/set_absorb()

	set category = "Abilities"
	set name = "Toggle Slime Digestion"
	set desc = "Toggle absorbing people you coat over."

	if(istype(usr,/mob/living/carbon/human/slime))
		var/mob/living/carbon/human/slime/M = usr
		// Check if the client has a mob and if the mob is valid and alive.
		if(M.stat==2)
			M << "\red You must be corporeal and alive to do that."
			return 0

		if(M.shouldabsorb == 0)
			M.shouldabsorb = 1
			M.visible_message("You will now digest people in your slime.")
		else
			M.shouldabsorb = 0
			M.visible_message("You will no longer digest people in your slime.")

/mob/living/carbon/human/slime/proc/release_captive()

	set category = "Abilities"
	set name = "Release Slime Captive"
	set desc = "Release anyone you have trapped in your slime."

	if(istype(usr,/mob/living/carbon/human/slime))
		var/mob/living/carbon/human/slime/M = usr

		if(M.stat==2)
			M << "\red You must be corporeal and alive to do that."
			return 0

		if(M.slime_contents)
			M.vomitslime()

/mob/living/carbon/human/slime/proc/become_slime()

	set category = "Abilities"
	set name = "Become puddle"
	set desc = "Become a puddle of slime!"

	if(istype(usr,/mob/living/carbon/human/slime))
		var/mob/living/carbon/human/slime/M = usr

		if(M.stat==2)
			M << "\red You must be corporeal and alive to do that."
			return 0

		var/mob/living/simple_animal/slime_puddle/puddle

		puddle = new /mob/living/simple_animal/slime_puddle(M.loc)

		M.loc = puddle
		puddle.key = M.key