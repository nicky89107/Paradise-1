/obj/machinery/trashburner
	name = "Trash Burner"
	desc = "A large machine used to burn trash."
	icon = 'icons/obj/recycling.dmi'
	icon_state = "grinder-o0"
	layer = MOB_LAYER+1 // Overhead
	anchored = 1
	density = 1
	var/safety_mode = 0 // Temporality stops the machine if it detects a mob
	var/grinding = 0
	var/icon_name = "grinder-o"
	var/blood = 0
	var/eat_dir = WEST
	var/mob/living/occupant //Person inside.
	var/dohuman = 1

/obj/machinery/trashburner/New()
	// On us
	..()
	update_icon()

/obj/machinery/trashburner/examine()
	set src in view()
	..()
	usr << "The power light is [(stat & NOPOWER) ? "off" : "on"]."
	usr << "The safety-mode light is [safety_mode ? "on" : "off"]."
	usr << "The safety-sensors status light is [dohuman ? "off" : "on"]."

/obj/machinery/trashburner/power_change()
	..()
	update_icon()


/obj/machinery/trashburner/update_icon()
	..()
	var/is_powered = !(stat & (BROKEN|NOPOWER))
	if(safety_mode)
		is_powered = 0
	icon_state = icon_name + "[is_powered]" + "[(blood ? "bld" : "")]" // add the blood tag at the end

// This is purely for admin possession !FUN!.
/obj/machinery/trashburner/Bump(var/atom/movable/AM)
	..()
	if(AM)
		Bumped(AM)


/obj/machinery/trashburner/Bumped(var/atom/movable/AM)

	if(stat & (BROKEN|NOPOWER))
		return
	if(safety_mode)
		return
	// If we're not already grinding something.
	if(!grinding)
		grinding = 1
		spawn(60)
			grinding = 0
	else
		return

	var/move_dir = get_dir(loc, AM.loc)
	if(move_dir == eat_dir)
		if(isliving(AM))
			if(dohuman)
				eat(AM)
			else
				stop(AM)
		else if(istype(AM, /obj/item))
			recycle(AM)
		else // Can't recycle
			playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
			AM.loc = src.loc

/obj/machinery/trashburner/proc/recycle(var/obj/item/I, var/sound = 1)
	I.loc = src.loc
	if(!istype(I, /obj/item/weapon/disk/nuclear) && !istype(I,/obj/item/flag/nation))
		visible_message("\red <B> The Burner</b> states, 'Engaging burning.'")
		qdel(I)
		sleep(60)
		visible_message("\red <b>The Burner</b> states, 'Burning Complete!'")
		if(sound)
			playsound(src.loc, 'sound/items/Welder.ogg', 50, 1)


/obj/machinery/trashburner/proc/stop(var/mob/living/L)
	playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 50, 0)
	safety_mode = 1
	update_icon()
	L.loc = src.loc

	spawn(SAFETY_COOLDOWN)
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		safety_mode = 0
		update_icon()

/obj/machinery/trashburner/proc/eat(var/mob/living/carbon/human/H)
	H.loc = src
	src.occupant = H
	update_icon()

	visible_message("\red The Burner accepts [src.occupant.name] and closes behind them.")
	src.occupant.visible_message("The Burner takes you in, and closes behind you.")
	sleep(10)
	visible_message("\red <B> The Burner</b> states, 'Engaging burning.'")
	src.occupant.visible_message("\blue You hear a faint voice. \red <B> The Burner </b> states, 'Engaging burning.'")
	sleep(10)
	src.occupant.visible_message("\red There is a roar, as flames shoot up the sides of the burner.")
	sleep(10)
	src.occupant.visible_message("\red The flames are burning your flesh!")
	src.occupant.apply_damage(30, BURN, "chest", 0)
	sleep(20)
	src.occupant.visible_message("\red Your flesh feels like it is melting!")
	src.occupant.apply_damage(40, BURN, "chest", 0)
	sleep(10)
	src.occupant.emote("scream")
	src.occupant.death(1)
	src.occupant.ghostize()
	qdel(src.occupant)
	visible_message("\red <b>The Burner</b> states, 'Burning Complete!'")