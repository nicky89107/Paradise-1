/obj/machinery/larkensoven
	name = "Larkens Oven"
	desc = "The oven seems to be over-sized."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "oven_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/mob/living/occupant // Mob who has been put inside
	var/dramatic = 1 //Do we use dramatic code or quick-code?
	var/locked = 0 // Is the gibber locked shut?

/obj/machinery/larkensoven/New()
	..()
	update_icon()

/obj/machinery/larkensoven/power_change()
	..()
	update_icon()

/obj/machinery/larkensoven/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(src.occupant)
		user << "\red The oven is full, empty it first!"
		return
	if (!( istype(G, /obj/item/weapon/grab)) || !(istype(G.affecting, /mob/living/carbon/human)))
		user << "\red This item is not suitable for the Larkens Oven!"
		return
	if(G.affecting.abiotic(1))
		user << "\red <B>The Oven states, 'Clothes ruin a good meal!'</B>"
		return

	user.visible_message("\red [user] starts to put [G.affecting] into the oven!")
	src.add_fingerprint(user)
	if(do_after(user, 30) && G && G.affecting && !occupant)
		user.visible_message("\red [user] stuffs [G.affecting] into the oven!")
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		del(G)
		update_icon()

/obj/machinery/larkensoven/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ismob(O)) //humans only
		return
	if(istype(O, /mob/living/simple_animal) || istype(O, /mob/living/silicon)) //animals and robots dont fit
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(src.occupant)
		user << "The Oven is full! You can't fit in there!"
		visible_message ("\blue The Oven rejects [user.name].")
	var/mob/living/L = O
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic(1))
		visible_message ("\blue <B>The Oven states, 'Clothes ruin a good meal!'</B>")
		return
	if(!L)
		return
	if(L.client)
		L.client.perspective = EYE_PERSPECTIVE
		L.client.eye = src
	L.loc = src
	src.occupant = L
	src.add_fingerprint(user)
	visible_message("\red [src.occupant.name] crawls into the oven.")
	src.occupant.visible_message("\red You crawl into the oven!")
	update_icon()

/obj/machinery/larkensoven/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		user << "\red It's locked and running"
		return
	if(src.occupant.ckey == user.ckey)
		src.occupant.visible_message("\red You can't turn that on from inside!")
		return
	else
		if(!locked)
			visible_message("\red You close and lock the oven door.")
			src.occupant.visible_message("\red [user.name] closes and locks the oven door!")
			sleep(20)
			visible_message("\red You turn the dial up to 275 degrees and hit 'Start'.")
			src.occupant.visible_message ("\blue You hear a beep, and then a crackling as the oven turns on. This can't be good.")
			src.startcooking(user)
		else
			sleep(20)
			visible_message("\red You turn the dial up to 275 degrees and hit 'Start'.")
			src.occupant.visible_message ("\blue You hear a beep, and then a crackling as the oven turns on. This can't be good.")
			src.startcooking(user)

/obj/machinery/larkensoven/verb/eject()
	set category = "Object"
	set name = "Empty Oven"
	set src in oview(1)

	if (usr.stat != 0)
		return
	if(operating||locked)
		usr.visible_message("\red The oven is locked.")
		return
	else
		src.go_out()
		add_fingerprint(usr)
		update_icon()
		return

/obj/machinery/larkensoven/relaymove(mob/user as mob)
	if (locked||operating)
		src.occupant.visible_message("\red The oven is locked!")
	else
		src.visible_message("\red [src.occupant.name] starts crawling out of the oven!")
		src.occupant.visible_message("\red You start crawling out of the oven.")
		sleep(40)
		src.go_out()
		return

/obj/machinery/larkensoven/proc/go_out()
	if (!src.occupant)
		return
	if(locked||operating)
		src.occupant.visible_message("\red The oven is locked!")
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant = null
	update_icon()
	return

/obj/machinery/larkensoven/verb/lock()
	set category = "Object"
	set name = "Lock Oven"
	set src in oview(1)

	if (usr.ckey != src.occupant.ckey)
		if (!locked)
			locked = 1
			usr.visible_message("\red You close the oven door and lock it.")
		else
			locked = 0
			usr.visible_message("\red You unlock the oven door and open it.")
	else
		if (!locked)
			usr.visible_message("You can't lock the door from inside!")
		else
			usr.visible_message("You can't unlock the door from inside!")
		return

/obj/machinery/larkensoven/proc/startcooking(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("\red <b>The Oven</b>states, 'That would be a waste of energy, deary!'")
		return
	use_power(1000)
	src.operating = 1
	src.locked = 1
	update_icon()
	src.occupant.attack_log += "\[[time_stamp()]\] Was cooked by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] cooked <b>[src.occupant]/[src.occupant.ckey]</b>"
	if(src.occupant.ckey)
		msg_admin_attack("[user.name] ([user.ckey]) cooked [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(user))
		src.occupant.LAssailant = null
	else
		src.occupant.LAssailant = user

	sleep(20)
	src.occupant.visible_message("\blue Is it getting warm in here...?")
	sleep(60)
	src.occupant.visible_message("\red You start sweating.")
	sleep(50)
	src.occupant.visible_message("\red Your skin starts burning.")
	sleep(50)
	src.occupant.visible_message("\red It's getting really fucking hot in here.")
	src.occupant.apply_damage(5, BURN, "Chest", 0)
	sleep(50)
	src.occupant.visible_message("\red Your skin is starting to burn badly!")
	src.occupant.apply_damage(10, BURN, "Chest", 0)
	sleep(50)
	src.occupant.visible_message("\red <b> It burns so badly! </b>")
	src.occupant.apply_damage(10, BURN, "l_leg", 0)
	src.occupant.apply_damage(10, BURN, "Chest", 0)
	src.occupant.apply_damage(10, BURN, "r_leg", 0)
	sleep(50)
	src.occupant.apply_effect(10, AGONY, 0)
	src.occupant.visible_message("\red <b> Your skin feels like it is searing off. </b>")
	src.occupant.apply_damage(10, BURN, "l_arm", 0)
	src.occupant.apply_damage(10, BURN, "l_leg", 0)
	src.occupant.apply_damage(10, BURN, "head", 0)
	sleep(50)
	src.occupant.emote("scream")
	src.occupant.apply_effect(40, AGONY, 0)
	src.occupant.visible_message("\red <b> Your entire body feels like it is melting! </b>")
	sleep(50)
	src.occupant.apply_effect(20, AGONY, 0)
	src.occupant.apply_damage(20, BURN, "chest", 0)
	src.occupant.apply_damage(10, BURN, "l_arm", 0)
	src.occupant.apply_damage(10, BURN, "l_leg", 0)
	src.occupant.apply_damage(10, BURN, "head", 0)
	sleep(50)
	src.occupant.apply_damage(50, BURN, "chest", 0)
	if(src.occupant.stat != 0)
		src.operating = 0
		src.locked = 0
		update_icon()
		src.eject()
	else
		src.occupant.apply_damage(100, BURN, "chest", 0)
		sleep(30)
		src.operating = 0
		src.locked = 0
		update_icon()
		src.go_out()