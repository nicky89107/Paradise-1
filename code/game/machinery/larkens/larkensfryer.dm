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
	var/mob/living/carbon/human/occupant // Mob who has been put inside
	var/timer = 0
	var/throw_dir = SOUTH

/obj/machinery/larkens/fryer/New()
	..()


/obj/machinery/larkens/fryer/power_change()
	..()


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

		src.startfrying(user)


/obj/machinery/larkens/fryer/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
	if(O.loc == user) //no you can't pull things out of your ass
		return
	if(user.restrained() || user.stat || user.weakened || user.stunned || user.paralysis || user.resting) //are you cuffed, dying, lying, stunned or other
		return
	if(O.anchored || get_dist(user, src) > 1 || get_dist(user, O) > 1 || user.contents.Find(src)) // is the mob anchored, too far away from you, or are you too far away from the source
		return
	if(!ishuman(O)) //humans only
		return
	if(user.loc==null) // just in case someone manages to get a closet into the blue light dimension, as unlikely as that seems
		return
	if(!istype(user.loc, /turf) || !istype(O.loc, /turf)) // are you in a container/closet/pod/etc?
		return
	if(src.occupant)
		user << "The Fryer is full! You can't fit in there!"
		visible_message ("\blue The Fryer rejects [user.name].")

	var/mob/living/carbon/human/H = O
	if(!H)
		return
	if(H != user)
		return
	if(!istype(H) || H.buckled)
		return
	var/didstrip = 0

	if(H.abiotic(1))
		didstrip =1
		H.apply_effect(40, STUN, 0)
		src.visible_message("<span class='warning'>\The [src] states, 'Clothes simply won't do!'")
		sleep(10)
		H.visible_message("<span class='warning'>\The [src]'s robotic arms clamp down on [H.name]'s arms and legs!</span>", \
							"<span class='warning'>\The [src]'s robotic arms clamp down on your arms and legs!</span>")
		sleep(30)
		src.visible_message("<span class='warning'>\The [src] states, 'Engaging quiet mode.'")
		sleep(20)
		src.visible_message("<span class='danger'>A 5th arm extends from \the [src], holding a muzzle!</span>")
		sleep(30)
		H.visible_message("<span class='danger'>\The [src] clamps a muzzle onto [H.name]'s face!</span>", \
							"<span class='danger'>\The [src] clamps a muzzle onto your face!</span>")
		H.sdisabilities |= MUTE
		sleep(30)
		H.visible_message("<span class='danger'>\The [src] starts removing [H.name]'s clothing!</span>", \
							"<span class='danger'>\The [src]'s arms hold you firmly as it starts removing your clothing!</span>")
		sleep(30)
		for(var/obj/item/W in H)
			H.drop_from_inventory(W)
		sleep(20)
		H.visible_message("<span class='danger'>\The [src] removes [H.name]'s underclothing.</span>", \
							"<span class='danger'>\The [src] removes your underclothes!</span>")
		H.underwear = 7
		H.undershirt = 5
		H.update_body(1)
		sleep(10)

	if(!didstrip)
		H.visible_message("<span class='warning'>[H.name] gives \himself to the Fryer's arms.</span>", \
							"<span class='warning'>You let \the [src]'s arms take ahold of you.</span>")
		H.apply_effect(40, STUN, 0)
		sleep(10)
		H.visible_message("<span class='warning'>\The [src]'s 4 arms grab ahold of <b>[H.name]'s</b> arms and legs!</span>", \
							"<span class='warning'>\The [src]'s 4 arms grab ahold of your arms and legs.")
	sleep(40)
	H.apply_effect(-80, STUN, 0)
	H.visible_message("<span class='danger'>\The [src] lifts <b>[H.name]</b> into the air over the top of it!</span>", \
						"<span class='danger'>\The [src] easily lifts you into the air over the top of it!</span>")
	H.visible_message()
	if(H.client)
		H.client.perspective = EYE_PERSPECTIVE
		H.client.eye = src
	H.loc = src
	src.occupant = H
	src.add_fingerprint(user)
	src.startfrying(H)

/obj/machinery/larkens/fryer/proc/go_out()
	if (!src.occupant)
		return
	if(operating)
		src.occupant.visible_message("\red The fryer is currently operating!")
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant.client)
		src.occupant.client.eye = src.occupant.client.mob
		src.occupant.client.perspective = MOB_PERSPECTIVE
	src.occupant.loc = src.loc
	src.occupant.throw_at(get_edge_target_turf(src,throw_dir),1,2)
	src.occupant = null
	return

/obj/machinery/larkens/fryer/proc/startfrying(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("<span class='warning'>\The [src] states, 'That would be a waste of energy.'</span>")
		return
	use_power(1000)
	src.operating = 1

	src.occupant.attack_log += "\[[time_stamp()]\] Was fried by <b>[user]/[user.ckey]</b>"
	user.attack_log += "\[[time_stamp()]\] fried <b>[src.occupant]/[src.occupant.ckey]</b>"
	if(src.occupant.ckey)
		msg_admin_attack("[user.name] ([user.ckey]) fried [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(user))
		src.occupant.LAssailant = null
	else
		src.occupant.LAssailant = user
	sleep(30)
	src.visible_message("<span class='warning'>\The [src] moves <b>[src.occupant.name]</b> limbs to be spread-eagle.</span>")
	src.occupant.show_message("<span class='warning'>\The [src] forces your limbs spread-eagle.</span>")
	sleep(30)
	visible_message("<span class='notice'>\The [src] scans <b>[src.occupant.name]</b></span>")
	src.occupant.show_message("<span class='notice'>\The [src] scans you.</span>")
	sleep(30)
	visible_message("<span class='warning'>\The [src] states, 'Detected [src.occupant.get_species()], gender [src.occupant.get_gender()].'</span> </br>")
	src.occupant.show_message("<span class='warning'>\The [src] states, 'Detected [src.occupant.get_species()], gender [src.occupant.get_gender()].'</span> </br>")
	sleep(20)
	visible_message("<span class='warning'>\The [src] states, 'Engaging Frying.'</span>")
	src.occupant.show_message("<span class='warning'>\The [src] states, 'Engaging Frying.'</span>")
	sleep(30)
	visible_message("<span class='warning'><b>[src.occupant.name]</b> is slowly immersed in the deepfryer!</span>")
	src.occupant.show_message("<span class='warning'>\The [src] shoves you down slowly into the scalding oil.</span>")
	icon_state = "human_fryer_on"
	visible_message("<span class='danger'><b>[src.occupant]</b> screams!</span>")
	sleep(10)
	src.occupant.show_message("<span class='danger'>Your skin is cooking!</span>")
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
	if(src.occupant.stat == DEAD)
		src.visible_message("<span class='danger'>\The [src] states, 'Frying complete!'</br> \The [src] tosses the lifeless body of <b>[src.occupant.name]</b> onto the ground.</span>")
		src.operating = 0
		icon_state = "human_fryer_off"

		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		src.occupant.ChangeToHusk()
		src.go_out()
	else
		src.occupant.show_message("<span class='danger'>Make the pain stop!</span>")
		src.occupant.apply_effect(40, AGONY, 0)
		sleep(10)
		src.occupant.apply_damage(100, BURN, "head", 0)
		src.occupant.apply_damage(100, BURN, "chest", 0)
		src.visible_message("<span class='danger'>\The [src] states, 'Frying complete!'</br> \The [src] tosses the lifeless body of <b>[src.occupant.name]</b> onto the ground.</span>")
		src.operating = 0
		icon_state = "human_fryer_off"

		playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
		src.occupant.ChangeToHusk()
		src.go_out()

