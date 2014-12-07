/obj/machinery/larkens/fryer
	name = "Larkens Fryer"
	desc = "The Fryer seems to be over-sized."
	icon = 'icons/obj/cooking_machines.dmi'
	icon_state = "human_fryer_off"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500
	var/operating = 0 //Is it on?
	var/mob/living/occupant // Mob who has been put inside
	var/timer = 0
	var/grabbed = 0 //Used for dialog changes.

/obj/machinery/larkens/fryer/New()
	..()
	update_icon()

/obj/machinery/larkens/fryer/power_change()
	..()
	update_icon()

/obj/machinery/larkens/fryer/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(src.occupant)
		user << "\red The Fryer is full, empty it first!"
		return
	if (!( istype(G, /obj/item/weapon/grab)) || !(istype(G.affecting, /mob/living/carbon/human)))
		user << "\red This item is not suitable for the Larkens Fryer!"
		return
	if(G.affecting.abiotic(1))
		user << "\red <B>The Fryer states, 'Clothes ruin a good meal!'</B>"
		return

	user.visible_message("\red [user] starts to put [G.affecting] into the fryer's robotic arms!")
	src.add_fingerprint(user)
	if(do_after(user, 30) && G && G.affecting && !occupant)
		user.visible_message("\red [user] puts [G.affecting] into the fryer's robotic arms!")
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		del(G)
		update_icon()
		src.startfrying(user)


/obj/machinery/larkens/fryer/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
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
		user << "The Fryer is full! You can't fit in there!"
		visible_message ("\blue The Fryer rejects [user.name].")
	var/mob/living/carbon/human/H = O
	if(!istype(H) || H.buckled)
		return
	if(H.abiotic(1))
		H.apply_effect(40, STUN, 0)
		visible_message ("\blue <b>The Fryer</b> states 'Clothes simply won't do!'</B>")
		sleep(10)
		H.visible_message ("\red <b>The Fryer</b>'s arms clamp down on your arms and legs.")
		grabbed = 1
		sleep(30)
		visible_message ("\red <b>The Fryer</b> states, 'Engaging quiet mode.'")
		sleep(30)
		visible_message ("\red A 5th arm extends from the Fryer, holding a muzzle.")
		sleep(30)
		H.visible_message ("\red <b>The Fryer</b> clamps a muzzle onto your face.")
		H.sdisabilities |= MUTE
		visible_message ("\red <b>The Fryer</b> clamps a muzzle onto [H.name]'s face.")
		sleep(30)
		visible_message ("\blue <b>The Fryer</b> starts removing [H.name]'s clothing.")
		H.visible_message ("\blue You have no choice but to let <b>The Fryer</b> to take your clothing.")
		sleep(30)
		for(var/obj/item/W in H)
			H.drop_from_inventory(W)
		sleep(20)
		visible_message("\blue <b>The Fryer</b> starts removing [H.name]'s underclothing.")
		H.visible_message("\blue <b>The Fryer</b> takes off your underclothes.")
		H.underwear = 7
		H.undershirt = 5
		H.update_body(1)
		sleep(10)
	if(!H)
		return
	if(!grabbed)
		if(H.get_gender() == "female")
			visible_message("\red <b>[H.name]</b> gives herself to the Fryer's arms.")
		else
			visible_message("\red <b>[H.name]</b> gives himself to the Fryer's arms.")
		H.visible_message("\red You let the fryer's arms take ahold of you.")
		H.apply_effect(40, STUN, 0)
		sleep(10)
		visible_message("\red <b>The Fryer</b>'s 4 arms grab ahold of <b>[H.name]'s</b> arms and legs!")
		H.visible_message("\red <b>The Fryer</b>'s 4 arms grab ahold of your arms and legs.")

	sleep(40)
	H.apply_effect(-80, STUN, 0)
	visible_message("\red <b>The Fryer</b> lifts <b>[H.name]</b> over the top of it's self.")
	H.visible_message("\red <b>The Fryer</b> easily lifts you into the air over the top of it.")
	if(H.client)
		H.client.perspective = EYE_PERSPECTIVE
		H.client.eye = src
	H.loc = src
	src.occupant = H
	src.add_fingerprint(user)
	src.startfrying(H)
	update_icon()

/obj/machinery/larkens/fryer/proc/go_out()
	if (!src.occupant)
		return
	if(operating)
		src.occupant.visible_message("\red The fryer is locked!")
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.x = src.x - 1
	src.occupant.y = src.y
	src.occupant.z = src.z
	src.occupant = null
	update_icon()
	return

/obj/machinery/larkens/fryer/proc/startfrying(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("\red <b>The Fryer</b>states, 'That would be a waste of energy.'")
		return
	use_power(1000)
	src.operating = 1
	update_icon()
	src.occupant.attack_log += "\[[time_stamp()]\] Was fried by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] fried <b>[src.occupant]/[src.occupant.ckey]</b>"
	if(src.occupant.ckey)
		msg_admin_attack("[user.name] ([user.ckey]) fried [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(user))
		src.occupant.LAssailant = null
	else
		src.occupant.LAssailant = user
	sleep(30)
	visible_message("\red <b>The Fryer</b> moves <b>[src.occupant.name]</b> limbs to be spread-eagle.")
	src.occupant.visible_message("\red <b>The Fryer</b> forces your limbs spread-eagle.")
	sleep(30)
	visible_message("\blue <b>The Fryer</b> scans <b>[src.occupant.name]</b>")
	src.occupant.visible_message("\blue <b>The Fryer</b> scans you.")
	sleep(30)
	visible_message("\red <b>The Fryer</b> states, 'Detected [src.occupant.get_species()], gender [src.occupant.get_gender()].' </br>")
	src.occupant.visible_message("\red <b>The Fryer</b> states, 'Detected [src.occupant.get_species()], gender [src.occupant.get_gender()].' </br>")
	sleep(20)
	visible_message("\red <b>The Fryer</b> states, 'Engaging Frying.'")
	src.occupant.visible_message("\red <b>The Fryer</b> states, 'Engaging Frying.'")
	sleep(30)
	visible_message("\red <b>[src.occupant.name]</b> is slowly immersed in the deepfryer!")
	src.occupant.visible_message("\red <b>The Fryer</b> shoves you down slowly into the scalding oil.")
	icon_state = "human_fryer_on"
	visible_message("<b>[src.occupant]</b> groans loudly.")
	sleep(10)
	src.occupant.visible_message("\red <b>Your skin is burning off!</b>")
	src.occupant.apply_effect(40, AGONY, 0)
	src.occupant.apply_damage(10, BURN, "l_leg", 0)
	src.occupant.apply_damage(10, BURN, "chest", 0)
	src.occupant.apply_damage(10, BURN, "r_leg", 0)
	src.occupant.apply_damage(10, BURN, "groin", 0)
	src.occupant.apply_damage(10, BURN, "head", 0)
	src.occupant.apply_damage(10, BURN, "r_arm", 0)
	src.occupant.apply_damage(10, BURN, "l_arm", 0)
	src.occupant.sdisabilities |= MUTE
	sleep(20)
	src.occupant.apply_effect(40, AGONY, 0)
	src.occupant.apply_damage(50, BURN, "chest", 0)
	src.occupant.apply_damage(40, BURN, "groin", 0)
	src.occupant.apply_damage(40, BURN, "head", 0)
	sleep(30)
	if(src.occupant.stat == 2)
		visible_message("\red <b>The Fryer</b> states, 'Frying complete!'</br> <b>The Fryer</b> tosses the lifeless body of <b>[src.occupant.name]</b> onto the ground.")
		src.operating = 0
		icon_state = "human_fryer_off"
		update_icon()
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		src.go_out()
	else
		src.occupant.visible_message("\red <b> Make the pain stop! </b>")
		src.occupant.apply_effect(40, AGONY, 0)
		sleep(10)
		src.occupant.apply_damage(100, BURN, "head", 0)
		src.occupant.apply_damage(100, BURN, "chest", 0)
		visible_message("\red <b>The Fryer</b> states, 'Frying complete!</br> <b>The Fryer</b> tosses the lifeless body of <b>[src.occupant.name]</b> onto the ground.")
		src.operating = 0
		icon_state = "human_fryer_off"
		update_icon()
		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		src.go_out()

