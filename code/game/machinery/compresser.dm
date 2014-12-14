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
	var/grinding = 0 //Is it currently busy?
	var/mob/living/occupant //Person inside.
	var/eat_dir = WEST //Which direction will we accept from?

/obj/machinery/compresser/meatcube //eewww.
	name = "Meatcube"
	desc = "Poor fucker."
	icon = 'icons/obj/meatcube.dmi'
	icon_state = "meatcube"
	anchored = 0
	layer = MOB_LAYER
	density = 1

/obj/item/slimecube //eeewww?
	name = "Slime Person Cube"
	desc = "Slime-person in a box! Poor thing."
	icon = 'icons/obj/meatcube.dmi'
	icon_state = "slimecube"
	anchored = 0
	w_class = 3.0

/obj/item/slimecube/relaymove(mob/user as mob)
	if (user.stat)
		return
	user << "\blue You can't escape the box."

/obj/item/slimecube/attackby(obj/item/weapon/W as obj, mob/user as mob)
	..()

	if (!istype(W, /obj/item/weapon/crowbar))
		user << "\blue I'll need a crowbar for that."
		return

	user << "\blue You break off one side of the slime box."
	for(var/mob/M in src) //Should only be one but whatever.
		M.loc = src.loc
		if (M.client)
			M.client.eye = M.client.mob
			M.client.perspective = MOB_PERSPECTIVE
	del(src)

/obj/machinery/compresser/New()
	..()
	update_icon()

/obj/machinery/compresser/power_change()
	..()
	update_icon()

/obj/machinery/compresser/Bump(var/atom/movable/AM) //Bump detectection.
	..()
	if(AM)
		Bumped(AM)

/obj/machinery/compresser/Bumped(var/atom/movable/AM, var/obj/machinery/compresser/slimecube/S) //Bump action.
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
		if(ishuman(AM))
			if(eatmob) //Should we eat them?
				eat(AM)
			else
				stop(AM) //Let's stop them.
		else // Can't recycle anything other than humans, too lazy to code.
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

/obj/machinery/compresser/proc/eat(var/mob/living/carbon/human/H)
	if(H.abiotic(1))
		H.visible_message("The Compressor grabs ahold of your legs and arms.")
		sleep(10)
		H.visible_message("The Compressor starts taking off all your clothes.")
		for(var/obj/item/W in H)
			H.drop_from_inventory(W)
		sleep(20)
		H.visible_message("\blue <b>The Compressor</b> takes off your clothes.")
		H.underwear = 7
		H.undershirt = 5
		H.update_body(1)
		sleep(10)
		H.visible_message("\blue <b>The Compressor</b> lets go of your arms and legs.")
		H.loc = src
		src.occupant = H
		update_icon()
	else
		H.loc = src
		src.occupant = H
		update_icon()

	if(src.occupant.get_species() == "Slime People")
		src.occupant.visible_message("The Compressor takes you in, and closes behind you.")
		sleep(10)
		visible_message("\red <B> The Compressor </b> states, 'Engaging compression.'")
		src.occupant.visible_message("\blue You hear a faint voice. \red <B> The Compressor </b> states, 'Engaging compression.'")
		sleep(20)
		src.occupant.visible_message("\blue The walls start closing in on you!")
		sleep(20)
		src.occupant.visible_message("\blue You put your hands up to stop the walls, but only succeed in getting your hands pushed by the walls.")
		sleep(30)
		src.occupant.visible_message("\blue The walls are touching your shoulders!")
		sleep(30)
		src.occupant.visible_message("\blue The walls are squeezing your gelatineous body!")
		sleep(20)
		src.occupant.visible_message("\blue Your body is being squashed. \red The pressure is starting to hurt!")
		sleep(20)
		src.occupant.visible_message("\red The walls keep pressing against you from every side, reducing you to a cube!")
		sleep(20)
		src.occupant.visible_message("\red The pressure is very painful, your core is having trouble vibrating in the thick slime")
		sleep(20)
		src.occupant.visible_message("\red The walls close on you, encasing you in a plastic box!")
		sleep(10)
		var/obj/item/slimecube/cube = new /obj/item/slimecube (src.loc)
		if (src.occupant.client)
			src.occupant.client.perspective = EYE_PERSPECTIVE
			src.occupant.client.eye = cube
		src.occupant.loc = cube

	else
		src.occupant.visible_message("The Compressor takes you in, and closes behind you.")
		sleep(10)
		visible_message("\red <B> The Compressor </b> states, 'Engaging compression.'")
		src.occupant.visible_message("\blue You hear a faint voice. \red <B> The Compressor </b> states, 'Engaging compression.'")
		sleep(20)
		src.occupant.visible_message("\red The walls start closing in on you!")
		sleep(20)
		src.occupant.visible_message("\red You put your hands up to stop the walls, but only succeed in getting your hands pushed by the walls.")
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
		new /obj/machinery/compresser/meatcube(loc)
