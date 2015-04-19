/obj/machinery/larkens/oven
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
	var/mob/living/carbon/human/occupant // Mob who has been put inside
	var/mob/living/carbon/human/occupant2 // Second mob, for twice the fun
	var/locked = 0 // Is the gibber locked shut?
	var/timer = 0
	var/stage = 0
	var/ocmuzzle = 0 //Used to prevent screaming when muzzled.
	var/oc2muzzle = 0 //Used to prevent screaming when muzzled.

/obj/machinery/larkens/oven/New()
	..()
	update_icon()

/obj/machinery/larkens/oven/power_change()
	..()
	update_icon()

/obj/machinery/larkens/oven/proc/message_to_occupants(V)
	if(src.occupant)
		src.occupant.show_message(V)
		if(src.occupant2)
			src.occupant2.show_message(V)
	else
		log_debug("No occupants found in oven at (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

/obj/machinery/larkens/oven/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(istype(G, /obj/item/weapon/grab))
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

	else if(istype(G, /obj/item/weapon/crowbar))
		if(operating)
			if(user.ckey == src.occupant.ckey || user.ckey == src.occupant2.ckey)
				user.show_message("\red The inside of the oven is completely sealed and cannot be broken open.")
				return
			else
				if(src.stage > 3.5)
					user.show_message("\red The oven is heating your crowbar too much for you to hold onto it.")
					return
				else
					user.show_message("\red You shove the crowbar into the door and try to break the lock. (This will take around 5 seconds.)")
					sleep(50)
					user.show_message("\red You break the lock!")
					user.show_message("\red <b>The Oven</b> states, 'Error, shutting down for saftey.'")
					if(src.stage > 2.5)
						user.show_message("\red A burst of hot air surges out of the oven!")
						var/mob/living/carbon/human/H = user
						H.apply_damage(20, BURN)
						sleep(10)
						src.operating = 0
						src.locked = 0
						src.eject()
						src.icon_state = "oven_off"
						src.update_icon()
					else
						sleep(10)
						src.operating = 0
						src.locked = 0
						src.eject()
						src.icon_state = "oven_off"
						src.update_icon()
		else
			user.visible_message("\red What exactly are you going to do with a crowbar and an oven?")
			return

	else if(istype(G, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = G
		if(WT.remove_fuel(1, user))
			if(operating)
				user.show_message("\red You start welding through the protective cover. (This will take about 4 seconds.)")
				sleep(40)
				user.show_message("\red A wave of heat goes past you, but you duck behind the intact paneling before it can burn you.")
				user.show_message("\red <b>The Oven</b> states, 'Critcal Error, shutting down for maitnance.'")
				src.operating = 0
				src.locked = 0
				src.eject()
				sleep(10)
				playsound(src.loc, 'sound/effects/sparks1.ogg', 50, 0)
				new /obj/effect/decal/cleanable/robot_debris(loc)
				sleep(5)
				del(src)
		else if(WT.remove_fuel(0, user))
			user.show_message("\red You need more welding fuel to do that!")
			return
		else
			return

	else
		return

/obj/machinery/larkens/oven/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
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
	if(istype(O, /mob/living/carbon/human))
		var/mob/living/L = O

		if(user.ckey != L.ckey)
			if(!istype(L) || L.buckled)
				return
			if(L.abiotic(1, 1))
				visible_message("\blue <B>The Oven states, 'Clothes ruin a good meal!'</B>")
				return
			if(!L)
				return

			visible_message("\red [user.name] starts shoving [O.name] into the oven!")
			sleep(10)
			visible_message("\red [user.name] shoves [O.name] into the oven!")

			if(src.occupant)
				if(L.client)
					L.client.perspective = EYE_PERSPECTIVE
					L.client.eye = src
				L.loc = src
				src.occupant2 = L
				src.add_fingerprint(user)
				update_icon()
				return

			else
				if(L.client)
					L.client.perspective = EYE_PERSPECTIVE
					L.client.eye = src
				L.loc = src
				src.occupant = L
				src.add_fingerprint(user)
				update_icon()
				return


		if(src.occupant)
			if(L.ckey != user.ckey)
				return
			if(!istype(L) || L.buckled)
				return
			if(L.abiotic(1, 1))
				visible_message ("\blue <B>The Oven states, 'Clothes ruin a good meal!'</B>")
				return
			if(!L)
				return
			if(L.client)
				L.client.perspective = EYE_PERSPECTIVE
				L.client.eye = src
			L.loc = src
			src.occupant2 = L
			src.add_fingerprint(user)
			visible_message("\red [src.occupant2.name] crawls into the oven.")
			src.occupant2.show_message("\red You crawl into the oven!")
			update_icon()
			return

		if(L.ckey != user.ckey)
			return
		if(!istype(L) || L.buckled)
			return
		if(L.abiotic(1, 1))
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
		src.occupant.show_message("\red You crawl into the oven!")
		update_icon()

/obj/machinery/larkens/oven/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		if(src.occupant && src.occupant.ckey == user.ckey)
			user << "\red You hopelessly bang against the door."
			visible_message("\red [src.occupant.name] bangs against the locked oven door!")
			return

		if(src.occupant2 && src.occupant2.ckey == user.ckey)
			user << "\red You hopelessly bang against the door."
			visible_message("\red [src.occupant2.name] bangs against the locked oven door!")
			return

	if(!src.occupant)
		if(timer)
			user.show_message("\red You press the start button. The timer displays : 10 seconds.")
			sleep(100)
			visible_message("\red \The [src]'s door shuts and locks!")
			sleep(20)
			src.startcooking(user)

		else
			visible_message("\red <b> The Oven </b> states, 'That would be a waste of power, deary!'")

	else
		if((src.occupant && src.occupant == user) || (src.occupant2 && src.occupant2 == user))
			user.show_message("\red You can't turn that on from inside!")

		else
			if(timer)
				var/answer = input("Are you sure you wish to start the oven on a timer?", "Start Oven", "No") in list ("Yes", "No")
				if(answer == "Yes")
					user.show_message("\red You press the start button. The timer displays : 10 seconds.")
					sleep(100)
					visible_message("\red The oven door shuts and locks.")
					message_to_occupants("\red With a whir, the oven door shuts and locks.")
					sleep(20)
					visible_message("\red <b>\The [src]</b> states, 'Engaging.'")
					message_to_occupants("\blue You hear a faint voice. \red <b>The Oven</b> states, 'Engaging.'")
					src.startcooking(user)
				else
					user.show_message("\red You decide not to start \the [src].")
					return

			else
				var/answer = input("Are you sure you wish to start the oven?", "Start Oven", "No") in list ("Yes", "No")
				if(answer == "Yes")
					if(!locked)
						visible_message("\red You close and lock the oven door.")
						message_to_occupants("\red [user.name] closes and locks the oven door!")
						sleep(20)
						visible_message("\red You turn the dial up to 150C and hit 'Start'.")
						message_to_occupants("\blue You hear a beep, and then a crackling as the oven turns on. This can't be good.")

						src.startcooking(user)
					else
						sleep(20)
						visible_message("\red You turn the dial up to 150C and hit 'Start'.")
						message_to_occupants("\blue You hear a beep, and then a crackling as the oven turns on. This can't be good.")
						src.startcooking(user)
				else
					visible_message("\red You decide not to cook.")
					return


/obj/machinery/larkens/oven/verb/eject()
	set category = "Object"
	set name = "Empty Oven"
	set src in oview(1)

	if (usr.stat != 0)
		return
	if(operating||locked)
		usr.visible_message("\red The Oven is locked.")
		return
	else
		src.visible_message("\red The Oven pushes out it's contents.")
		src.go_out()
		src.go_out2()
		add_fingerprint(usr)
		update_icon()
		return

/obj/machinery/larkens/oven/relaymove(mob/user as mob)
	if (src.occupant2)
		if (user.ckey == src.occupant2.ckey)
			if (locked||operating)
				src.occupant.visible_message("\red The oven is locked!")
			else
				src.occupant.visible_message("\red [src.occupant2.name] starts crawling out of the oven beside you.")
				src.visible_message("\red [src.occupant2.name] starts crawling out of the oven!")
				src.occupant2.visible_message("\red You start crawling out of the oven.")
				sleep(40)
				src.go_out2()
				return

	if (locked||operating)
		src.occupant.visible_message("\red The oven is locked!")
	else
		src.visible_message("\red [src.occupant.name] starts crawling out of the oven!")
		src.occupant.visible_message("\red You start crawling out of the oven.")
		src.occupant2.visible_message("\red [src.occupant.name] starts crawling out of the oven beside you.")
		sleep(40)
		src.go_out()
		return

/obj/machinery/larkens/oven/proc/go_out()
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

/obj/machinery/larkens/oven/proc/go_out2()
	if (!src.occupant2)
		return
	if(locked||operating)
		src.occupant2.visible_message("\red The oven is locked!")
		return
	for(var/obj/O in src)
		O.loc = src.loc
	if (src.occupant2.client)
		src.occupant2.client.eye = src.occupant2.client.mob
		src.occupant2.client.perspective = MOB_PERSPECTIVE
	src.occupant2.loc = src.loc
	src.occupant2 = null
	ocmuzzle = 0
	oc2muzzle = 0


/obj/machinery/larkens/oven/verb/lock()
	set category = "Object"
	set name = "Lock Oven"
	set src in oview(1)
	if(src.occupant || src.occupant2 || src.occupant && src.occupant2)
		if(usr == src.occupant || src.occupant2 && usr == src.occupant2)
			usr.show_message("<span class='warning'>You can't open \the [src] from inside!</span>")
			return

		if(src.operating)
			usr.show_message("<span class='warning'>\The [src] is running, and won't let you open it!</span>")
			return

	usr.show_message("<span class='warning'>You [locked ? "unlock" : "lock"] \the [src]'s door and [locked ? "open" : "close"] it.</span>")
	locked = !locked

/obj/machinery/larkens/oven/verb/timer()
	set category = "Object"
	set name = "Turn on Oven Timer"
	set src in oview(1)

	usr.show_message("<span class='warning'>[timer ? "You turn off \the [src]'s timer." : "You set \the [src]'s timer to turn on ten seconds after pressing the button."]</span>")
	timer = !timer

/obj/machinery/larkens/oven/proc/startcooking(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("\red <b>The Oven</b> states, 'That would be a waste of energy, deary!'")
		return

	if(src.occupant2)
		if(isLarkens(src.occupant2) && !isLarkens(src.occupant))
			visible_message("\red <b>The Oven</b> states, 'Burn the clan!'")
			message_to_occupants("\blue You hear a faint voice. \red <b>The Oven</b> states, 'Burn the clan!'")
			sleep(10)
			message_to_occupants("\red <b>The Oven</b> states over the internal speakers, 'Quiet now, dear.'")
			sleep(10)
			message_to_occupants("\red A muzzle extends and clamps over [src.occupant2.name]'s mouth!")
			src.occupant2.visible_message("\red A muzzle extends and clamps onto your mouth.")
			src.occupant2.sdisabilities |= MUTE
			oc2muzzle = 1

		if(isLarkens(src.occupant2) && isLarkens(src.occupant))
			visible_message("\red <b>The Oven</b> states, '2 Larkens for twice the flavor!'")
			message_to_occupants("\blue You hear a faint voice. \red <b>The Oven</b> states, '2 Larkens for twice the flavor!'")
			sleep(10)
			message_to_occupants("\red <b>The Oven</b> states over the internal speakers, 'Quiet now, dearies.'")
			sleep(10)
			message_to_occupants("\red A muzzle extends and clamps over [src.occupant.name]'s mouth!")
			src.occupant.visible_message("\red A muzzle extends and clamps onto your mouth.")
			src.occupant.sdisabilities |= MUTE
			ocmuzzle = 1
			sleep(10)
			message_to_occupants("\red <b>The Oven</b> states over the internal speakers, 'Your turn now, darling.'")
			sleep(10)
			message_to_occupants("\red A muzzle extends and clamps over [src.occupant2.name]'s mouth!")
			src.occupant2.sdisabilities |= MUTE
			oc2muzzle = 1


		use_power(1000)
		src.operating = 1
		src.locked = 1
		update_icon()
		src.occupant.attack_log += "\[[time_stamp()]\] Was cooked by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
		src.occupant2.attack_log += "\[[time_stamp()]\] Was cooked by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
		user.attack_log += "\[[time_stamp()]\] cooked <b>[src.occupant]/[src.occupant.ckey]</b>"
		if(src.occupant.ckey)
			msg_admin_attack("[user.name] ([user.ckey]) cooked [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
			msg_admin_attack("[user.name] ([user.ckey]) cooked [src.occupant2] ([src.occupant2.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
		if(!iscarbon(user))
			src.occupant.LAssailant = null
			src.occupant2.LAssailant = null
		else
			src.occupant.LAssailant = user
			src.occupant2.LAssailant = user
		icon_state = "oven_on"

		log_debug("Oven: Doing 2user for [src.occupant.ckey] and [src.occupant2.ckey]")
		sleep(20)
		visible_message("\red <b>The Oven</b> states, 'Stage 1.' <br> <b>The Oven</b> states, 'Current temperature is: 37C'")
		stage = 1
		message_to_occupants("\blue Is it getting warm in here...?")
		message_to_occupants("\red The internal thermometer shows 37C.")
		if(!src.operating)
			icon_state = "oven_off"
			update_icon()
			return
		while(operating)
			sleep(70)
			visible_message("\red <b>The Oven</b> states, 'Stage 1 heating.'")
			stage = 1.5
			visible_message("\blue The Oven is giving off a nice warmth.")
			message_to_occupants("\red You start sweating.")
			sleep(60)
			visible_message("\red <b>The Oven</b> states, 'Stage 2.' </br> <b>The Oven</b> states, 'Current temperature is: 45C'")
			stage = 2
			visible_message("\blue The Oven is a bit too hot to touch.")
			message_to_occupants("\red Your skin starts burning.")
			message_to_occupants("\red The internal thermometer shows 45C.")
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 2 heating.'</br> <b>The Oven</b> states, 'Current temperature is: 49C'")
			stage = 2.5
			visible_message("\blue The air around the oven is getting unpleasently hot.")
			message_to_occupants("\red It's getting really fucking hot in here.")
			message_to_occupants("\red The internal thermometer shows 49C.")
			src.occupant.apply_damage(5, BURN, "Chest", 0)
			src.occupant2.apply_damage(5, BURN, "Chest", 0)
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 3.' </br> <b>The Oven</b> states, 'Current temperature is: 64C'")
			stage = 3
			if(!ocmuzzle)
				src.occupant.emote("scream")
			message_to_occupants("\red Your skin is starting to burn badly!")
			message_to_occupants("\red The internal thermometer shows 64C.")
			src.occupant.apply_damage(10, BURN, "Chest", 0)
			if(!oc2muzzle)
				src.occupant2.emote("scream")
			src.occupant2.apply_damage(10, BURN, "Chest", 0)
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 3 heating.'")
			stage = 3.5
			if(!ocmuzzle)
				src.occupant.emote("scream")
			message_to_occupants("\red <b> It burns so badly! </b>")
			message_to_occupants("\red The internal thermometer shows 75C.")
			src.occupant.apply_damage(10, BURN, "l_leg", 0)
			src.occupant.apply_damage(10, BURN, "Chest", 0)
			src.occupant.apply_damage(10, BURN, "r_leg", 0)
			if(!oc2muzzle)
				src.occupant2.emote("scream")
			src.occupant2.apply_damage(10, BURN, "l_leg", 0)
			src.occupant2.apply_damage(10, BURN, "Chest", 0)
			src.occupant2.apply_damage(10, BURN, "r_leg", 0)
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 4.' </br> <b>The Oven</b> states, 'Current temperature is: 82C'")
			stage = 4
			src.occupant.apply_effect(20, AGONY, 0)
			if(!ocmuzzle)
				src.occupant.emote("scream")
			message_to_occupants("\red <b> Your skin feels like it is searing off. </b>")
			message_to_occupants("\red The internal thermometer shows 82C.")
			src.occupant.apply_damage(10, BURN, "l_arm", 0)
			src.occupant.apply_damage(10, BURN, "l_leg", 0)
			src.occupant.apply_damage(10, BURN, "head", 0)
			src.occupant2.apply_effect(20, AGONY, 0)
			if(!oc2muzzle)
				src.occupant2.emote("scream")
			src.occupant2.apply_damage(10, BURN, "l_arm", 0)
			src.occupant2.apply_damage(10, BURN, "l_leg", 0)
			src.occupant2.apply_damage(10, BURN, "head", 0)
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 4 heating.'")
			stage = 4.5
			if(!ocmuzzle)
				src.occupant.emote("scream")
			src.occupant.apply_effect(40, AGONY, 0)
			message_to_occupants("\red <b> Your skin is burning like hell! </b>")
			message_to_occupants("\red The internal thermometer shows 86C, and is climbing rapidly...")
			if(!oc2muzzle)
				src.occupant2.emote("scream")
			src.occupant2.apply_effect(40, AGONY, 0)
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 5.' </br> <b>The Oven</b> states, 'Current temperature is: 103C'")
			stage = 5
			message_to_occupants("\red <b> Your entire body feels like it is melting! </b>")
			message_to_occupants("\red The internal thermometer shows 103C.")
			if(!ocmuzzle)
				src.occupant.emote("scream")
			src.occupant.apply_effect(40, AGONY, 0)
			src.occupant.apply_damage(20, BURN, "chest", 0)
			src.occupant.apply_damage(10, BURN, "l_arm", 0)
			src.occupant.apply_damage(10, BURN, "l_leg", 0)
			src.occupant.apply_damage(10, BURN, "head", 0)
			if(!oc2muzzle)
				src.occupant2.emote("scream")
			src.occupant2.apply_effect(40, AGONY, 0)
			src.occupant2.apply_damage(20, BURN, "chest", 0)
			src.occupant2.apply_damage(10, BURN, "l_arm", 0)
			src.occupant2.apply_damage(10, BURN, "l_leg", 0)
			src.occupant2.apply_damage(10, BURN, "head", 0)
			sleep(20)
			message_to_occupants("\red You smell a sweet aroma... and realize it is your own cooking flesh!")
			sleep(30)
			visible_message("\red <b>The Oven</b> states, 'Finalizing cook.'")
			message_to_occupants("\blue You hear a faint voice. \red <b>The Oven</b> states, 'Finalizing cook.'")
			src.occupant.apply_damage(50, BURN, "chest", 0)
			src.occupant2.apply_damage(50, BURN, "chest", 0)
			if(src.occupant.stat == 2)
				visible_message("\red <b>The Oven</b> states, 'Cooking complete!'")
				stage = 0
				src.operating = 0
				src.locked = 0
				icon_state = "oven_off"
				update_icon()
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
				src.occupant.ChangeToHusk()
				src.go_out()
			if(src.occupant2.stat == 2)
				stage = 0
				src.operating = 0
				src.locked = 0
				icon_state = "oven_off"
				update_icon()
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
				src.occupant2.ChangeToHusk()
				src.go_out()
			else
				visible_message("\red <b>The Oven</b> states, 'Engaging heating grille.' </br> <b>The Oven</b> states, 'Current temperature is: 130C'")
				src.occupant.apply_damage(10, BURN, "chest", 0)
				message_to_occupants("\red <b> You hear a faint buzzing noise, and the grille under you starts searing through your flesh.</b>")
				message_to_occupants("\red The internal thermometer quickly jumps to 130C.")
				sleep(30)
				src.occupant.apply_damage(10, BURN, "l_leg", 0)
				src.occupant.apply_damage(10, BURN, "r_leg", 0)
				if(src.occupant.stat == 2)
					sleep(30)
					stage = 0
					src.operating = 0
					src.locked = 0
					icon_state = "oven_off"
					update_icon()
					visible_message("\red <b>The Oven</b> states, 'Cooking complete!'")
					playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
					src.occupant.ChangeToHusk()
					src.go_out()
				if(src.occupant2.stat == 2)
					stage = 0
					src.operating = 0
					src.locked = 0
					icon_state = "oven_off"
					update_icon()
					playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
					src.occupant2.ChangeToHusk()
					src.go_out()
				else
					visible_message("\red <b>The Oven</b> states, 'Current temperature is: 150C'")
					message_to_occupants("\red <b> The pain slowly goes away, and your vision starts to fade.")
					message_to_occupants("\red The internal thermometer shows 150C.")
					sleep(20)
					src.occupant.apply_effect(100, AGONY, 0)
					src.occupant.death(1)
					src.occupant2.apply_effect(100, AGONY, 0)
					src.occupant2.death(1)
					stage = 0
					src.operating = 0
					src.locked = 0
					icon_state = "oven_off"
					update_icon()
					playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
					visible_message("\red <b>The Oven</b> states, 'Cooking complete!'")
					src.occupant.ChangeToHusk()
					src.occupant2.ChangeToHusk()
					src.go_out()
	else
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
		icon_state = "oven_on"


		if(isLarkens(src.occupant))
			visible_message("\red <b>The Oven</b> states, 'Larkens make the best food!'")
			message_to_occupants("\blue You hear a faint voice. \red <b>The Oven</b> states, 'Larkens make the best food!'")
			sleep(10)
			message_to_occupants("\red <b>The Oven</b> states over the internal speakers, 'Quiet now, dear.'")
			sleep(10)
			src.occupant.visible_message("\red A muzzle extends and clamps onto your mouth.")
			src.occupant.sdisabilities |= MUTE
			ocmuzzle = 1

		log_debug("Oven: Doing 1user for [src.occupant.ckey]")
		sleep(20)
		visible_message("\red <b>The Oven</b> states, 'Stage 1.' <br> <b>The Oven</b> states, 'Current temperature is: 37C'")
		stage = 1
		src.occupant.visible_message("\blue Is it getting warm in here...?")
		src.occupant.visible_message("\red The internal thermometer shows 37C.")
		if(!src.operating)
			icon_state = "oven_off"
			update_icon()
			return
		while(operating)
			sleep(70)
			visible_message("\red <b>The Oven</b> states, 'Stage 1 heating.'")
			stage = 1.5
			visible_message("\blue The Oven is giving off a nice warmth.")
			src.occupant.visible_message("\red You start sweating.")
			sleep(60)
			visible_message("\red <b>The Oven</b> states, 'Stage 2.' </br> <b>The Oven</b> states, 'Current temperature is: 45C'")
			stage = 2
			visible_message("\blue The Oven is a bit too hot to touch.")
			src.occupant.visible_message("\red Your skin starts burning.")
			src.occupant.visible_message("\red The internal thermometer shows 45C.")
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 2 heating.'</br> <b>The Oven</b> states, 'Current temperature is: 49C'")
			stage = 2.5
			visible_message("\blue The air around the oven is getting unpleasently hot.")
			src.occupant.visible_message("\red It's getting really fucking hot in here.")
			src.occupant.visible_message("\red The internal thermometer shows 49C.")
			src.occupant.apply_damage(5, BURN, "Chest", 0)
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 3.' </br> <b>The Oven</b> states, 'Current temperature is: 64C'")
			stage = 3
			if(!ocmuzzle)
				src.occupant.emote("scream")
			src.occupant.visible_message("\red Your skin is starting to burn badly!")
			src.occupant.visible_message("\red The internal thermometer shows 64C.")
			src.occupant.apply_damage(10, BURN, "Chest", 0)
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 3 heating.'")
			stage = 3.5
			if(!ocmuzzle)
				src.occupant.emote("scream")
			src.occupant.visible_message("\red <b> It burns so badly! </b>")
			src.occupant.visible_message("\red The internal thermometer shows 75C.")
			src.occupant.apply_damage(10, BURN, "l_leg", 0)
			src.occupant.apply_damage(10, BURN, "Chest", 0)
			src.occupant.apply_damage(10, BURN, "r_leg", 0)
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 4.' </br> <b>The Oven</b> states, 'Current temperature is: 82C'")
			stage = 4
			src.occupant.apply_effect(20, AGONY, 0)
			if(!ocmuzzle)
				src.occupant.emote("scream")
			src.occupant.visible_message("\red <b> Your skin feels like it is searing off. </b>")
			src.occupant.visible_message("\red The internal thermometer shows 82C.")
			src.occupant.apply_damage(10, BURN, "l_arm", 0)
			src.occupant.apply_damage(10, BURN, "l_leg", 0)
			src.occupant.apply_damage(10, BURN, "head", 0)
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 4 heating.'")
			stage = 4.5
			if(!ocmuzzle)
				src.occupant.emote("scream")
			src.occupant.apply_effect(40, AGONY, 0)
			src.occupant.visible_message("\red <b> Your skin is burning like hell! </b>")
			src.occupant.visible_message("\red The internal thermometer shows 86C, and is climbing rapidly..")
			sleep(50)
			visible_message("\red <b>The Oven</b> states, 'Stage 5.' </br> <b>The Oven</b> states, 'Current temperature is: 103C'")
			stage = 5
			src.occupant.visible_message("\red <b> Your entire body feels like it is melting! </b>")
			src.occupant.visible_message("\red The internal thermometer shows 103C.")
			if(!ocmuzzle)
				src.occupant.emote("scream")
			src.occupant.apply_effect(40, AGONY, 0)
			src.occupant.apply_damage(20, BURN, "chest", 0)
			src.occupant.apply_damage(10, BURN, "l_arm", 0)
			src.occupant.apply_damage(10, BURN, "l_leg", 0)
			src.occupant.apply_damage(10, BURN, "head", 0)
			sleep(20)
			src.occupant.visible_message("\red You smell a sweet aroma... and realize it is your own cooking flesh!")
			sleep(30)
			visible_message("\red <b>The Oven</b> states, 'Finalizing cook.'")
			src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Oven</b> states, 'Finalizing cook.'")
			src.occupant.apply_damage(50, BURN, "chest", 0)
			if(src.occupant.stat == 2)
				visible_message("\red <b>The Oven</b> states, 'Cooking complete!'")
				stage = 0
				src.operating = 0
				src.locked = 0
				icon_state = "oven_off"
				update_icon()
				playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
				src.occupant.ChangeToHusk()
				src.go_out()
			else
				visible_message("\red <b>The Oven</b> states, 'Engaging heating grille.' </br> <b>The Oven</b> states, 'Current temperature is: 130C'")
				src.occupant.apply_damage(10, BURN, "chest", 0)
				src.occupant.visible_message("\red <b> You hear a faint buzzing noise, and the grille under you starts searing through your flesh.</b>")
				src.occupant.visible_message("\red The internal thermometer shows 130C.")
				sleep(30)
				src.occupant.apply_damage(10, BURN, "l_leg", 0)
				src.occupant.apply_damage(10, BURN, "r_leg", 0)
				if(src.occupant.stat == 2)
					sleep(30)
					stage = 0
					src.operating = 0
					src.locked = 0
					icon_state = "oven_off"
					update_icon()
					visible_message("\red <b>The Oven</b> states, 'Cooking complete!'")
					playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
					src.occupant.ChangeToHusk()
					src.go_out()
				else
					visible_message("\red <b>The Oven</b> states, 'Current temperature is: 150C'")
					src.occupant.visible_message("\red <b> The pain slowly goes away, and your vision starts to fade.")
					src.occupant.visible_message("\red The internal thermometer shows 150C.")
					sleep(20)
					src.occupant.apply_effect(100, AGONY, 0)
					src.occupant.death(1)
					stage = 0
					src.operating = 0
					src.locked = 0
					icon_state = "oven_off"
					update_icon()
					playsound(src.loc, 'sound/machines/ping.ogg', 50, 0)
					visible_message("\red <b>The Oven</b> states, 'Cooking complete!'")
					src.occupant.ChangeToHusk()
					src.go_out()