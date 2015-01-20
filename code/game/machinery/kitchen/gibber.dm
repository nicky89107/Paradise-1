/obj/machinery/gibber
	name = "Gibber"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"
	density = 1
	anchored = 1
	var/operating = 0 //Is it on?
	var/dirty = 0 // Does it need cleaning?
	var/gibtime = 40 // Time from starting until meat appears
	var/mob/living/carbon/human/occupant // Mob who has been put inside
	var/dramatic = 1 //Do we use dramatic code or quick-code?
	var/locked = 0 // Is the gibber locked shut?
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500

//auto-gibs anything that bumps into it
/obj/machinery/gibber/autogibber
	var/turf/input_plate

	New()
		..()
		spawn(5)
			for(var/i in cardinal)
				var/obj/machinery/mineral/input/input_obj = locate( /obj/machinery/mineral/input, get_step(src.loc, i) )
				if(input_obj)
					if(isturf(input_obj.loc))
						input_plate = input_obj.loc
						del(input_obj)
						break

			if(!input_plate)
				diary << "a [src] didn't find an input plate."
				return

	Bumped(var/atom/A)
		if(!input_plate) return

		if(ismob(A))
			var/mob/M = A

			if(M.loc == input_plate
			)
				M.loc = src
				M.gib()

/obj/machinery/gibber/bumpgibber
	name = "Autogibber- No tenderness."
	Bumped(var/atom/A)
		if(ismob(A))
			var/mob/M = A
			if(M.abiotic(1))
				M.visible_message("\red Subject may not have abiotic items on.")
				if(M.resting)
					M.visible_message("\red Larkens.Override(Disposals) Detected.")
					sleep(10)
					M.visible_message("\red Stripping Subject.")
					for(var/obj/item/W in M)
						M.drop_from_inventory(W)
				else
					return
			else
				if(M.client)
					M.client.perspective = EYE_PERSPECTIVE
					M.client.eye = src
				M.loc = src
				src.occupant = M
				update_icon()
				visible_message ("\red The gibber drags [M.name] in.")
				M.visible_message ("\red The gibber grabs ahold of your feet and drags you in.")
				src.startgibbing(M)

/obj/machinery/gibber/bumpgibberFull
	name = "Autogibber-All in One"
	Bumped(var/atom/A)
		if(ismob(A))
			var/mob/living/carbon/human/H = A
			if(H.abiotic(1))
				H.visible_message("\red Subject may not have abiotic items on.")
				if(H.resting)
					H.visible_message("\red Larkens.Override(Disposals) Detected.")
					sleep(10)
					H.visible_message("\red Stripping Subject.")
					for(var/obj/item/W in H)
						H.drop_from_inventory(W)
					H.underwear = 7
					H.undershirt = 5
					H.update_body(1)
					sleep(5)
				else
					return
			else
				if(H.client)
					H.client.perspective = EYE_PERSPECTIVE
					H.client.eye = src
				H.loc = src
				src.occupant = H
				update_icon()
				visible_message ("\red The gibber drags [H.name] in.")
				H.visible_message ("\red The gibber grabs ahold of your feet and drags you in.")
				src.startgibbingFull(H)

/obj/machinery/gibber/tenderizer
	name = "Tenderizer"
	Bumped(var/atom/A)
		if(ismob(A))
			var/mob/living/carbon/human/H = A
			if(H.abiotic(1))
				H.visible_message("\red Subject may not have abiotic items on.")
				if(H.resting)
					H.visible_message("\red Larkens.Override(Disposals) Detected.")
					sleep(10)
					H.visible_message("\red Stripping Subject.")
					for(var/obj/item/W in H)
						H.drop_from_inventory(W)
					H.underwear = 7
					H.undershirt = 5
					H.update_body(1)
					sleep(10)
				else
					return
			else
				if(H.client)
					H.client.perspective = EYE_PERSPECTIVE
					H.client.eye = src
				H.loc = src
				src.occupant = H
				update_icon()
				visible_message ("\red The Tenderizer drags [H.name] into it.")
				H.visible_message ("\red The Tenderizer locks onto your legs and drags you in.")
				src.starttenderizing(H)


/obj/machinery/gibber/New()
	..()
	src.overlays += image('icons/obj/kitchen.dmi', "grjam")

/obj/machinery/gibber/update_icon()
	overlays.Cut()
	if (dirty)
		src.overlays += image('icons/obj/kitchen.dmi', "grbloody")
	if(stat & (NOPOWER|BROKEN))
		return
	if (!occupant)
		src.overlays += image('icons/obj/kitchen.dmi', "grjam")
	else if (operating)
		src.overlays += image('icons/obj/kitchen.dmi', "gruse")
	else
		src.overlays += image('icons/obj/kitchen.dmi', "gridle")

/obj/machinery/gibber/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/gibber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/gibber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		user << "\red It's locked and running"
		return
	if(src.occupant.ckey == user.ckey)
		src.occupant.visible_message ("\red You hit the internal 'Sweet Relief' button.")
		src.startgibbingFull(user)
	else
		visible_message("\red You hit the big red flashing 'Gib' button.")
		src.occupant.visible_message ("\blue You hear a beep, and then a hum as the gibber springs to life. This can't be good.")
		src.startgibbingFull(user)

/obj/machinery/gibber/tenderizer/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		user << "\red It's locked and running."
		return
	if(src.occupant.ckey == user.ckey)
		src.occupant.visible_message ("\red You hit the internal start button.")
		src.starttenderizing(user)
	else
		visible_message("\red You hit the big red flashing 'Start Tenderization' button.")
		src.occupant.visible_message ("\blue You hear a beep, and then a hum as the tenderizer springs to life. This can't be good.")
		src.starttenderizing(user)

/obj/machinery/gibber/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(src.occupant)
		user << "\red The gibber is full, empty it first!"
		return
	if (!( istype(G, /obj/item/weapon/grab)) || !(istype(G.affecting, /mob/living/carbon/human)))
		user << "\red This item is not suitable for the gibber!"
		return
	if(G.affecting.abiotic(1))
		user << "\red Subject may not have abiotic items on."
		return

	user.visible_message("\red [user] starts to put [G.affecting] into the gibber!")
	src.add_fingerprint(user)
	if(do_after(user, 30) && G && G.affecting && !occupant)
		user.visible_message("\red [user] stuffs [G.affecting] into the gibber!")
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		del(G)
		update_icon()


/obj/machinery/gibber/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
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
		user << "The gibber is full! You can't fit in there!"
		visible_message ("\blue The Gibber rejects [user.name].")
	var/mob/living/L = O
	if(L.ckey != user.ckey)
		return
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic(1))
		visible_message ("\blue <B>The Gibber states, 'Subject cannot have abiotic items on.'</B>")
		return
	if(!L)
		return
	if(L.client)
		L.client.perspective = EYE_PERSPECTIVE
		L.client.eye = src
	L.loc = src
	src.occupant = L
	src.add_fingerprint(user)
	update_icon()


/obj/machinery/gibber/verb/eject()
	set category = "Object"
	set name = "Empty Gibber"
	set src in oview(1)

	if (usr.stat != 0)
		return
	if(operating||locked)
		usr.visible_message("\red The hatch is locked.")
		return
	else
		src.go_out()
		add_fingerprint(usr)
		update_icon()
		return

/obj/machinery/gibber/verb/lock()
	set category = "Object"
	set name = "Lock Gibber"
	set src in oview(1)

	if (usr.ckey != src.occupant.ckey)
		if (!locked)
			locked = 1
			usr.visible_message("\red You close the hatch and lock it.")
		else
			locked = 0
			usr.visible_message("\red You unlock the hatch and open it.")
	else
		if (!locked)
			usr.visible_message("You can't lock the hatch from inside!")
		else
			usr.visible_message("You can't unlock the hatch from inside!")
		return

/obj/machinery/gibber/proc/go_out()
	if (!src.occupant)
		return
	if(locked||operating)
		src.occupant.visible_message("\red The hatch is locked!")
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

/obj/machinery/gibber/proc/starttenderizing(mob/user as mob)
	var/datum/organ/external/LL = src.occupant.get_organ("l_leg")
	var/datum/organ/external/RL = src.occupant.get_organ("r_leg")
	if(src.operating)
		return
	if(src.occupant.get_species() == "Slime People")
		src.occupant.visible_message("\red <b>The Tenderizer</b> scans you, then decides it cannot tenderize your slime.")
		sleep(10)
		src.occupant.visible_message("\red <b>The Tenderizer</b> ejects you.")
		src.operating = 0
		src.eject()
		visible_message("\red <b>The Tenderizer</b> states 'Incompatible Meat, ejecting.'")
		return

	use_power(1000)
	src.operating = 1
	update_icon()
	src.occupant.attack_log += "\[[time_stamp()]\] Was tenderized by <b>auto-tender</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] Was Tenderized <b>via auto-tender</b>"
	if(src.occupant.ckey)
		msg_admin_attack("[user.name] ([user.ckey]) was tenderized.(<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	sleep(10)
	visible_message("\red The panel slides shut and locks.")
	src.occupant.visible_message("\red The panel slides shut and locks behind you.")
	sleep(20)
	visible_message("\red <b> The Tenderizer </b> states, 'Preparing Subject.'")
	src.occupant.visible_message("\blue You hear a faint voice. \red <b> The Tenderizer </b> states, 'Preparing Subject.'")
	src.occupant.visible_message("\red You feel a panel open underneath you.")
	sleep(30)
	src.occupant.visible_message("\red A large blow strikes your back.")
	src.occupant.visible_message("\red <b> Oh god, the pain! </b>")
	src.occupant.apply_effect(15, AGONY, 0)
	src.occupant.apply_damage(20, BRUTE, "chest", 0)
	sleep(30)
	src.occupant.visible_message("\red <b>A blow strikes your right leg.</b>")
	src.occupant.apply_effect(10, AGONY, 0)
	RL.fracture()
	sleep(10)
	src.occupant.visible_message("\red <b>Another blow strikes your left leg.</b>")
	src.occupant.apply_effect(10, AGONY, 0)
	LL.fracture()
	sleep(10)
	src.occupant.visible_message("\red <b>A number of blows strike your torso and groin.</b>")
	src.occupant.apply_damage(15, BRUTE, "groin", 0)
	src.occupant.apply_damage(15, BRUTE, "chest", 0)
	sleep(10)
	src.occupant.resting = 1
	src.operating = 0
	src.eject()


/obj/machinery/gibber/proc/startgibbingFull(mob/user as mob)
	var/datum/organ/external/LL = src.occupant.get_organ("l_leg")
	var/datum/organ/external/RL = src.occupant.get_organ("r_leg")
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("\red You hear a loud metallic grinding sound.")
		return
	use_power(1000)
	src.operating = 1
	update_icon()
	var/sourcename = src.occupant.real_name
	var/sourcejob = src.occupant.job
	var/sourcenutriment = src.occupant.nutrition / 15
	var/sourcetotalreagents = src.occupant.reagents.total_volume
	var/totalslabs = 3

	var/obj/item/weapon/reagent_containers/food/snacks/meat/human/allmeat[totalslabs]
	for (var/i=1 to totalslabs)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new
		newmeat.name = sourcename + newmeat.name
		newmeat.subjectname = sourcename
		newmeat.subjectjob = sourcejob
		newmeat.reagents.add_reagent ("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
		src.occupant.reagents.trans_to (newmeat, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
		allmeat[i] = newmeat

	src.occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] Gibbed <b>[src.occupant]/[src.occupant.ckey]</b>"
	if(src.occupant.ckey)
		msg_admin_attack("[user.name] ([user.ckey]) gibbed [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(user))
		src.occupant.LAssailant = null
	else
		src.occupant.LAssailant = user

	sleep(10)
	visible_message("\red The hatch closes and locks.")
	src.occupant.visible_message("\red The hatch closes and locks behind you.")
	sleep(20)
	visible_message("\red <b>The Gibber</b> states, 'Readying subject.'")
	src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Gibber</b> states 'Readying Subject.'")
	src.occupant.visible_message("\red A pair of rollers rolls you onto your back.")
	sleep(20)
	src.occupant.visible_message("\red Padded cuffs extend from the sides of <b>The Gibber</b> and take ahold of your arms and legs.")
	sleep(40)
	visible_message("\red <b>The Gibber</b> states, 'Subject Ready. Engaging Muzzle.'")
	src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Gibber</b> states 'Subject Ready. Engaging Muzzle.'")
	sleep(30)
	src.occupant.visible_message("\red A muzzle extends from above and clamps onto your mouth.")
	src.occupant.sdisabilities |= MUTE
	sleep(30)
	visible_message("\red <b>The Gibber</b> states 'Deploying Tenderizers.'")
	src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Gibber</b> states 'Deploying Tenderizers..'")
	sleep(20)
	src.occupant.visible_message("\red You feel a panel open underneath you.")
	sleep(30)
	src.occupant.visible_message("\red A large blow strikes your back.")
	src.occupant.visible_message("\red <b>Oh god, the pain! </b>")
	src.occupant.apply_effect(15, AGONY, 0)
	src.occupant.apply_damage(20, BRUTE, "chest", 0)
	sleep(30)
	src.occupant.visible_message("\red <b>A blow strikes your right leg.</b>")
	src.occupant.apply_effect(10, AGONY, 0)
	RL.fracture()
	sleep(10)
	src.occupant.visible_message("\red <b>Another blow strikes your left leg.</b>")
	src.occupant.apply_effect(10, AGONY, 0)
	LL.fracture()
	sleep(10)
	src.occupant.visible_message("\red <b>A number of blows strike your torso and groin.</b>")
	src.occupant.apply_damage(15, BRUTE, "groin", 0)
	src.occupant.apply_damage(15, BRUTE, "chest", 0)
	sleep(10)
	src.occupant.resting = 1
	sleep(40)
	visible_message("\red <b>The Gibber</b> states, 'Deploying Grinders.'")
	src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Gibber</b> states 'Deploying Grinders.'")
	sleep(30)
	src.occupant.visible_message("\red A number of sharp points dig into your arms, and legs.")
	sleep(10)
	src.occupant.visible_message("\red A large clamp seals around your waist. This can't bode well.")
	sleep(30)
	visible_message("\red <b>The Gibber</b> states 'Engaging Grinders.'")
	visible_message("\red The Gibber starts rumbling!")
	src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Gibber</b> states 'Engaging Grinders.'")
	sleep(30)
	src.occupant.visible_message("\red <b> You feel an extreme amount of pain as your hands and feet are seperated from your body. </b>")
	src.occupant.apply_effect(40, AGONY, 0)
	visible_message("\red You hear a loud squelchy grinding sound.")
	sleep(20)
	src.occupant.visible_message("\red <b>You make a loud groan as your knees and elbows are seperated. </b>")
	visible_message("<b>[src.occupant]</b>groans loudly.")
	sleep(40)
	src.occupant.visible_message("\red <b>As a blade saws your remaining limbs off, you attempt to scream out, but only make a little whimper. </b>")
	visible_message("<b>[src.occupant]</b>lightly whimpers.")
	sleep(40)
	src.occupant.visible_message("\red <b>You feel a serrated blade splitting your torso open! </b>")
	src.occupant.apply_effect(20, AGONY, 0)
	sleep(30)
	src.occupant.visible_message("\red <b>You feel your intense agony coming to an end as your internal organs are ripped out by a claw. </b>")
	visible_message("\red <b>The Gibber </b> states, 'Gibbing Complete!'")
	sleep(20)
	playsound(src.loc, 'sound/effects/gib.ogg', 50, 1)
	src.occupant.death(1)
	src.occupant.ghostize()
	del(src.occupant)
	spawn(src.gibtime)
		playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
		operating = 0
		for (var/i=1 to totalslabs)
			var/obj/item/meatslab = allmeat[i]
			var/turf/Tx = locate(src.x + i, src.y, src.z)
			meatslab.loc = src.loc
			meatslab.throw_at(Tx,i,3,src)
			if (!Tx.density)
				new /obj/effect/decal/cleanable/blood/gibs(Tx,i)
		src.operating = 0
		update_icon()


/obj/machinery/gibber/proc/startgibbing(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("\red You hear a loud metallic grinding sound.")
		return
	use_power(1000)
	src.operating = 1
	update_icon()
	var/sourcename = src.occupant.real_name
	var/sourcejob = src.occupant.job
	var/sourcenutriment = src.occupant.nutrition / 15
	var/sourcetotalreagents = src.occupant.reagents.total_volume
	var/totalslabs = 3

	var/obj/item/weapon/reagent_containers/food/snacks/meat/human/allmeat[totalslabs]
	for (var/i=1 to totalslabs)
		var/obj/item/weapon/reagent_containers/food/snacks/meat/human/newmeat = new
		newmeat.name = sourcename + newmeat.name
		newmeat.subjectname = sourcename
		newmeat.subjectjob = sourcejob
		newmeat.reagents.add_reagent ("nutriment", sourcenutriment / totalslabs) // Thehehe. Fat guys go first
		src.occupant.reagents.trans_to (newmeat, round (sourcetotalreagents / totalslabs, 1)) // Transfer all the reagents from the
		allmeat[i] = newmeat

	src.occupant.attack_log += "\[[time_stamp()]\] Was gibbed by <b>Conveyer Line</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] Gibbed <b>[src.occupant]/[src.occupant.ckey]</b>"
	if(src.occupant.ckey)
		msg_admin_attack("(Conveyer Line) gibbed [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(user))
		src.occupant.LAssailant = null
	else
		src.occupant.LAssailant = user
	if(src.dramatic)
		sleep(10)
		visible_message("\red The hatch closes and locks.")
		src.occupant.visible_message("\red The hatch closes and locks behind you.")
		sleep(20)
		visible_message("\red <b>The Gibber</b> states, 'Readying subject.'")
		src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Gibber</b> states 'Readying Subject.'")
		src.occupant.visible_message("\red A pair of rollers rolls you onto your back.")
		sleep(20)
		src.occupant.visible_message("\red Padded cuffs extend from the sides of <b>The Gibber</b> and take ahold of your arms and legs.")
		sleep(40)
		visible_message("\red <b>The Gibber</b> states, 'Subject Ready. Engaging Muzzle.'")
		src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Gibber</b> states 'Subject Ready. Engaging Muzzle.'")
		sleep(30)
		src.occupant.visible_message("\red A muzzle extends from above and clamps onto your mouth.")
		src.occupant.sdisabilities |= MUTE
		sleep(30)
		visible_message("\red <b>The Gibber</b> states, 'Deploying Grinders.'")
		src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Gibber</b> states 'Deploying Grinders.'")
		sleep(30)
		src.occupant.visible_message("\red A number of sharp points dig into your arms, and legs.")
		sleep(20)
		src.occupant.visible_message("\red A large clamp seals around your waist. This can't bode well.")
		sleep(30)
		visible_message("\red <b>The Gibber</b> states 'Engaging Grinders.'")
		visible_message("\red The Gibber starts rumbling!")
		src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Gibber</b> states 'Engaging Grinders.'")
		sleep(30)
		src.occupant.visible_message("\red <b>You feel an extreme amount of pain as your hands and feet are seperated from your body. </b>")
		src.occupant.apply_effect(40, AGONY, 0)
		visible_message("\red You hear a loud squelchy grinding sound.")
		sleep(20)
		src.occupant.visible_message("\red <b>You make a loud groan as your knees and elbows are seperated. </b>")
		visible_message("<b>[src.occupant]</b> groans loudly.")
		sleep(40)
		src.occupant.visible_message("\red <b>As a blade saws your remaining limbs off, you attempt to scream out, but only make a little whimper. </b>")
		visible_message("<b>[src.occupant]</b> lightly whimpers.")
		sleep(40)
		src.occupant.visible_message("\red <b>A saw slowly descends towards your neck.</b> </br> \blue Your last thoughts are 'Finally, the pain will be over'")
		visible_message("\red <b> The Gibber </b> states, 'Gibbing Complete!'")
		sleep(20)
		playsound(src.loc, 'sound/effects/gib.ogg', 50, 1)
		src.occupant.death(1)
		src.occupant.ghostize()
		del(src.occupant)
		spawn(src.gibtime)
			playsound(src.loc, 'sound/effects/splat.ogg', 50, 1)
			operating = 0
			for (var/i=1 to totalslabs)
				var/obj/item/meatslab = allmeat[i]
				var/turf/Tx = locate(src.x + i, src.y, src.z)
				meatslab.loc = src.loc
				meatslab.throw_at(Tx,i,3,src)
				if (!Tx.density)
					new /obj/effect/decal/cleanable/blood/gibs(Tx,i)
			src.operating = 0
			update_icon()