/* Morgue stuff
 * Contains:
 *		Morgue
 *		Morgue trays
 *		Creamatorium
 *		Creamatorium trays
 */

/*
 * Morgue
 */

/obj/structure/morgue
	name = "morgue"
	desc = "Used to keep bodies in untill someone fetches them."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = 1
	dir = EAST
	var/obj/structure/m_tray/connected = null
	anchored = 1.0
	var/timed = 0 //used for timed shut

/obj/structure/morgue/verb/timedshut(mob/user as mob)
	set category = "Object"
	set name = "Morgue Timed-Shut"
	set src in oview(1)

	if(!timed)
		timed = 1
		user.visible_message("You set the morgue to shut after 10 seconds.")
		sleep(100)
		src.attack_hand(user)
		timed = 0
	else
		return

/obj/structure/morgue/verb/nap(mob/user as mob)
	set category = "Object"
	set name = "Morgue Nap"
	set src in oview(1)

	if(!timed)
		timed = 1
		user.visible_message("You set the morgue to shut after 10 seconds, and open in 10 minutes.")
		sleep(100)
		src.attack_hand(user)
		timed = 0
		spawn(6000)
			src.attack_hand(user)
	else
		return
/obj/structure/morgue/proc/update()
	if(src.connected)
		src.icon_state = "morgue0"
	else
		if(src.contents.len)

			var/mob/living/M = locate() in contents

			var/obj/structure/closet/body_bag/B = locate() in contents
			if(M==null) M = locate() in B

			if(M)
				if(M.client)
					src.icon_state = "morgue3"
				else
					src.icon_state = "morgue2"

			else src.icon_state = "morgue4"
		else src.icon_state = "morgue1"
	return


/obj/structure/morgue/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
	return

/obj/structure/morgue/alter_health()
	return src.loc

/obj/structure/morgue/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/morgue/attack_hand(mob/user as mob)
	if (src.connected)
		for(var/atom/movable/A as mob|obj in src.connected.loc)
			if (!( A.anchored ))
				A.loc = src
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		//src.connected = null
		del(src.connected)
	else
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		src.connected = new /obj/structure/m_tray( src.loc )
		step(src.connected, src.dir)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, src.dir)
		if (T.contents.Find(src.connected))
			src.connected.connected = src
			src.icon_state = "morgue0"
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.connected.loc
			src.connected.icon_state = "morguet"
			src.connected.dir = src.dir
		else
			//src.connected = null
			del(src.connected)
	src.add_fingerprint(user)
	update()
	return

/obj/structure/morgue/attackby(P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.get_active_hand() != P)
			return
		if ((!in_range(src, usr) && src.loc != user))
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Morgue- '[]'", t)
		else
			src.name = "Morgue"
	src.add_fingerprint(user)
	return

/obj/structure/morgue/relaymove(mob/user as mob)
	if (user.stat)
		return
	src.connected = new /obj/structure/m_tray( src.loc )
	step(src.connected, EAST)
	src.connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, EAST)
	if (T.contents.Find(src.connected))
		src.connected.connected = src
		src.icon_state = "morgue0"
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.connected.loc
			//Foreach goto(106)
		src.connected.icon_state = "morguet"
	else
		//src.connected = null
		del(src.connected)
	return


/*
 * Morgue tray
 */
/obj/structure/m_tray
	name = "morgue tray"
	desc = "Apply corpse before closing."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = 1
	layer = 2.0
	var/obj/structure/morgue/connected = null
	anchored = 1.0
	throwpass = 1

/obj/structure/m_tray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/m_tray/attack_hand(mob/user as mob)
	if (src.connected)
		for(var/atom/movable/A as mob|obj in src.loc)
			if (!( A.anchored ))
				A.loc = src.connected
			//Foreach goto(26)
		src.connected.connected = null
		src.connected.update()
		add_fingerprint(user)
		//SN src = null
		del(src)
		return
	return

/obj/structure/m_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if (!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if (!ismob(user) || user.stat || user.lying || user.stunned)
		return
	O.loc = src.loc
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			if ((B.client && !( B.blinded )))
				B << text("\red [] stuffs [] into []!", user, O, src)
	return


/*
 * Crematorium
 */

/obj/structure/crematorium
	name = "crematorium"
	desc = "A human incinerator. Works well on barbeque nights."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"
	density = 1
	var/obj/structure/c_tray/connected = null
	anchored = 1.0
	var/cremating = 0
	var/id = 1
	var/locked = 0
	var/bagtype

/obj/structure/crematorium/proc/update()
	if (src.connected)
		src.icon_state = "crema0"
	else
		if (src.contents.len)
			src.icon_state = "crema2"
		else
			src.icon_state = "crema1"
	return

/obj/structure/crematorium/ex_act(severity)
	switch(severity)
		if(1.0)
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.loc
				ex_act(severity)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
		if(3.0)
			if (prob(5))
				for(var/atom/movable/A as mob|obj in src)
					A.loc = src.loc
					ex_act(severity)
				qdel(src)
				return
	return

/obj/structure/crematorium/alter_health()
	return src.loc

/obj/structure/crematorium/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/crematorium/attack_hand(mob/user as mob)
//	if (cremating) AWW MAN! THIS WOULD BE SO MUCH MORE FUN ... TO WATCH
//		user.show_message("\red Uh-oh, that was a bad idea.", 1)
//		//usr << "Uh-oh, that was a bad idea."
//		src:loc:poison += 20000000
//		src:loc:firelevel = src:loc:poison
//		return
	if (cremating)
		usr << "\red It's locked."
		return
	if ((src.connected) && (src.locked == 0))
		for(var/atom/movable/A as mob|obj in src.connected.loc)
			if (!( A.anchored ))
				A.loc = src
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		//src.connected = null
		del(src.connected)
	else if (src.locked == 0)
		playsound(src.loc, 'sound/items/Deconstruct.ogg', 50, 1)
		src.connected = new /obj/structure/c_tray( src.loc )
		step(src.connected, SOUTH)
		src.connected.layer = OBJ_LAYER
		var/turf/T = get_step(src, SOUTH)
		if (T.contents.Find(src.connected))
			src.connected.connected = src
			src.icon_state = "crema0"
			for(var/atom/movable/A as mob|obj in src)
				A.loc = src.connected.loc
			src.connected.icon_state = "cremat"
		else
			//src.connected = null
			del(src.connected)
	src.add_fingerprint(user)
	update()

/obj/structure/crematorium/attackby(P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/pen))
		var/t = input(user, "What would you like the label to be?", text("[]", src.name), null)  as text
		if (user.get_active_hand() != P)
			return
		if ((!in_range(src, usr) > 1 && src.loc != user))
			return
		t = copytext(sanitize(t),1,MAX_MESSAGE_LEN)
		if (t)
			src.name = text("Crematorium- '[]'", t)
		else
			src.name = "Crematorium"
	src.add_fingerprint(user)
	return

/obj/structure/crematorium/relaymove(mob/user as mob)
	if (user.stat || locked)
		return
	src.connected = new /obj/structure/c_tray( src.loc )
	step(src.connected, SOUTH)
	src.connected.layer = OBJ_LAYER
	var/turf/T = get_step(src, SOUTH)
	if (T.contents.Find(src.connected))
		src.connected.connected = src
		src.icon_state = "crema0"
		for(var/atom/movable/A as mob|obj in src)
			A.loc = src.connected.loc
			//Foreach goto(106)
		src.connected.icon_state = "cremat"
	else
		//src.connected = null
		del(src.connected)
	return

/obj/structure/crematorium/proc/cremate(atom/A, mob/user as mob)
//	for(var/obj/machinery/crema_switch/O in src) //trying to figure a way to call the switch, too drunk to sort it out atm
//		if(var/on == 1)
//		return
	if(cremating)
		return //don't let you cremate something twice or w/e

	if(contents.len <= 0)
		for (var/mob/M in viewers(src))
			M.show_message("\red You hear a hollow crackle.", 1)
			return

	else
		if(!isemptylist(src.search_contents_for(/obj/item/weapon/disk/nuclear)))
			usr << "You get the feeling that you shouldn't cremate one of the items in the cremator."
			return
		if(!isemptylist(src.search_contents_for(/obj/item/flag/nation)))
			usr << "You get the feeling that you shouldn't cremate one of the items in the cremator."
			return
		for (var/mob/M in viewers(src))
			M.show_message("\red You hear a roar as the crematorium activates.", 1)

		cremating = 1
		locked = 1
		icon_state = "crema_active"

		for(var/mob/living/M in contents)
			if (M.stat!=2)
				M.visible_message("\red The cremator door locks into place!")
				sleep(20)
				M.visible_message("\red There is a hum as the cremator activates. Fuck.")
				sleep(10)
				M.visible_message("\red Flames shoot out of the sides of the creamator!")
				sleep(20)
				M.visible_message("\red The flames start burning your skin!")
				M.apply_effect(20, AGONY, 0)
				M.emote("scream")
				sleep(20)
				M.visible_message("\red Your skin is melting!")
				M.apply_effect(30, AGONY, 0)
				M.emote("scream")
				sleep(20)
				M.visible_message("\red You are in extreme pain!")
				M.apply_effect(30, AGONY, 0)
				M.emote("scream")
				sleep(10)
				M.visible_message("\red You pass out from the pain!")
				M.apply_effect(100, AGONY, 0)
				sleep(30)
			//Logging for this causes runtimes resulting in the cremator locking up. Commenting it out until that's figured out.
			//M.attack_log += "\[[time_stamp()]\] Has been cremated by <b>[user]/[user.ckey]</b>" //No point in this when the mob's about to be deleted
			//user.attack_log +="\[[time_stamp()]\] Cremated <b>[M]/[M.ckey]</b>"
			//log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> cremated <b>[M]/[M.ckey]</b>")
			M.death(1)
			M.ghostize()
			del(M)

		for(var/obj/O in contents) //obj instead of obj/item so that bodybags and ashes get destroyed. We dont want tons and tons of ash piling up
			if(istype(O, /obj/structure/closet))
				if(istype(O, /obj/structure/closet/coffin))
					bagtype = "coffin"
				else if(istype(O, /obj/structure/closet/body_bag))
					bagtype = "bag"
				else
					bagtype = "locker"

				del(O)
				cremate2("autocoffinkill")
				cremating = 0
				update()
				return
			del(O)


		new /obj/effect/decal/cleanable/ash(src)
		sleep(30)
		cremating = 0
		locked = 0
		update()
		playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
		sleep(20)
		visible_message("The cremator tray slides out.")
		src.attack_hand(src)
	return

/obj/structure/crematorium/proc/cremate2(atom/A, mob/user as mob)
//	for(var/obj/machinery/crema_switch/O in src) //trying to figure a way to call the switch, too drunk to sort it out atm
//		if(var/on == 1)
//		return
	cremating = 1
	locked = 1
	icon_state = "crema_active"

	for(var/mob/living/M in contents)
		if (M.stat!=2)
			M.visible_message("\red You hear a click.")
			sleep(10)
			if(bagtype == "coffin")
				M.visible_message("\red The coffin lid presses firmly shut.")
				sleep(20)
				M.visible_message("\red You hear a roar outside. Fuck.")
				sleep(10)
				M.visible_message("\red It is getting quite hot in here...")
				sleep(10)
				M.visible_message("\red The heat makes your whole body sweat, and you smell burning wood.")
				sleep(20)
				M.visible_message("\red Flames erupt from under the coffin and start burning the wood to ashes!")
				sleep(10)
				M.visible_message("\red You are set ablaze!")
				M.apply_effect(20, AGONY, 0)
				sleep(10)
				M.visible_message("\red The flames are surrounding you! FUCK!")
				M.apply_effect(30, AGONY, 0)
				sleep(20)
				M.visible_message("\red Your skin is melting!")
				M.apply_effect(20, AGONY, 0)
				sleep(20)
				M.visible_message("\red You pass out from the pain.")
				M.apply_effect(300, AGONY, 0)

			else if(bagtype == "bag")
				M.visible_message("\red You hear a roar outside. Fuck.")
				sleep(20)
				M.visible_message("\red The bag starts getting hot against your skin.")
				sleep(10)
				M.visible_message("\red You start sweating in the heat.")
				sleep(20)
				M.visible_message("\red The bag is getting hot...")
				M.apply_effect(10, AGONY, 0)
				sleep(20)
				M.visible_message("\red The bag is burning against your skin!")
				M.apply_effect(10, AGONY, 0)
				sleep(20)
				M.visible_message("\red The bag starts getting noticably softer and incredibly hot.")
				M.apply_effect(10, AGONY, 0)
				sleep(20)
				M.visible_message("\red <b>The bag starts melting onto your skin! </b>")
				M.apply_effect(20, AGONY, 0)
				sleep(20)
				M.visible_message("\red <b>The incredible heat causes the bag to start painfully fusing with your skin!</b>")
				M.apply_effect(20, AGONY, 0)
				sleep(20)
				M.emote("scream")
				M.apply_effect(30, AGONY, 0)
				M.visible_message("\red <b>The bag is searing your skin!</b>")


		//Logging for this causes runtimes resulting in the cremator locking up. Commenting it out until that's figured out.
		//M.attack_log += "\[[time_stamp()]\] Has been cremated by <b>[user]/[user.ckey]</b>" //No point in this when the mob's about to be deleted
		//user.attack_log +="\[[time_stamp()]\] Cremated <b>[M]/[M.ckey]</b>"
		//log_attack("\[[time_stamp()]\] <b>[user]/[user.ckey]</b> cremated <b>[M]/[M.ckey]</b>")
		M.death(1)
		M.ghostize()
		del(M)


	new /obj/effect/decal/cleanable/ash(src)
	sleep(30)
	cremating = 0
	locked = 0
	update()
	playsound(src.loc, 'sound/machines/ding.ogg', 50, 1)
	sleep(20)
	visible_message("The cremator tray slides out.")
	src.attack_hand(src)


/*
 * Crematorium tray
 */
/obj/structure/c_tray
	name = "crematorium tray"
	desc = "Apply body before burning."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cremat"
	density = 1
	layer = 2.0
	var/obj/structure/crematorium/connected = null
	anchored = 1.0
	throwpass = 1

/obj/structure/c_tray/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/structure/c_tray/attack_hand(mob/user as mob)
	if (src.connected)
		for(var/atom/movable/A as mob|obj in src.loc)
			if (!( A.anchored ))
				A.loc = src.connected
			//Foreach goto(26)
		src.connected.connected = null
		src.connected.update()
		add_fingerprint(user)
		//SN src = null
		del(src)
		return
	return

/obj/structure/c_tray/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if ((!( istype(O, /atom/movable) ) || O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src) || user.contents.Find(O)))
		return
	if (!ismob(O) && !istype(O, /obj/structure/closet/body_bag))
		return
	if (!ismob(user) || user.stat || user.lying || user.stunned)
		return
	O.loc = src.loc
	if (user != O)
		for(var/mob/B in viewers(user, 3))
			if ((B.client && !( B.blinded )))
				B << text("\red [] stuffs [] into []!", user, O, src)
			//Foreach goto(99)
	return

/obj/machinery/crema_switch/attack_hand(mob/user as mob)
	for (var/obj/structure/crematorium/C in world)
		if (C.id == id)
			if (!C.cremating)
				visible_message("You hit the creamtor switch, it starts counting down.")
				sleep(10)
				visible_message("\red Three!")
				sleep(10)
				visible_message("\red Two!")
				sleep(10)
				visible_message("\red One!")
				sleep(10)
				C.cremate(user)
			else
				visible_message("The cremator is already on!")
				return

