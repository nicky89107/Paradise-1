/obj/machinery/compresser
	name = "Compresser"
	desc = "Compresses things into useable materials."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-b1"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/safety_mode = 0 // Temporality stops the machine if it detects a mob
	var/eatmob = 1 //Basically an admin emag var
	var/grinding = 0
	var/mob/living/occupant
	var/eat_dir = WEST

/obj/machinery/compresser/New()
	..()
	update_icon()

/obj/machinery/compresser/power_change()
	..()
	update_icon()

/obj/machinery/compresser/Bump(var/atom/movable/AM)
	..()
	if(AM)
		Bumped(AM)

/obj/machinery/compresser/Bumped(var/atom/movable/AM)
	if(safety_mode)
		return
	// If we're not already grinding something.
	if(!grinding)
		grinding = 1
		spawn(1)
			grinding = 0
	else
		return

	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		if(isliving(AM))
			if(eatmob)
				eat(AM)
			else
				stop(AM)
		else // Can't recycle
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.loc = src.loc


/obj/machinery/compresser/proc/stop(var/mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = 1
	update_icon()
	L.loc = src.loc

	spawn(SAFETY_COOLDOWN)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		safety_mode = 0
		update_icon()

/obj/machinery/compresser/proc/eat(var/mob/living/L)
	L.loc = src
	src.occupant = L
	update_icon()
	src.occupant.visible_message("The Compressor takes you in, and closes behind you.")
	sleep(10)
	visible_message("\red <B> The Compressor </b> states, 'Engaging compression.'")
	src.occupant.visible_message("\blue You hear a faint voice. \red <B> The Compressor </b> states, 'Engaging compression.'")
	sleep(20)
	src.occupant.visible_message("\red The walls start closing in on you!")
	sleep(20)
	src.occupant.visible_message("\red You put you hands up to stop the walls, but only succed in getting your hands pushed by the walls.")
	sleep(30)
	src.occupant.visible_message("\red The walls are touching your shoulders!")
	sleep(20)
	src.occupant.visible_message("\red Your bones are cracking and your limbs are being crushed together!")
	src.occupant.apply_damage(20, BRUTE, "l_leg", 0)
	src.occupant.apply_damage(20, BRUTE, "r_leg", 0)
	src.occupant.apply_damage(20, BRUTE, "l_arm", 0)
	src.occupant.apply_damage(20, BRUTE, "r_arm", 0)
	playsound(src.loc, 'sound/effects/snap.ogg', 50, 0)
	sleep(30)
	src.occupant.visible_message("\red Your chest is being crushed!")
	src.occupant.apply_damage(40, BRUTE, "chest", 0)
	sleep(10)
	playsound(src.loc, 'sound/effects/squelch1.ogg', 50, 0)
	sleep(20)
	src.occupant.emote("scream")
	src.occupant.death(1)
	src.occupant.ghostize()
	del(src.occupant)
	visible_message("\red <b> The Compressor </b> states, 'No usable material harvested. Disposing of unusable material.'")
	new /obj/effect/decal/cleanable/blood/gibs(loc)
	new /obj/effect/decal/cleanable/blood/gibs(loc)