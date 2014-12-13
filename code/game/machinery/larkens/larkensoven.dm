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
	var/locked = 0 // Is the gibber locked shut?
	var/timer = 0
	var/stage = 0

/obj/machinery/larkens/oven/New()
	..()
	update_icon()

/obj/machinery/larkens/oven/power_change()
	..()
	update_icon()

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
			if(user.ckey == src.occupant.ckey)
				user.visible_message("\red The inside of the oven is completely sealed and cannot be broken open.")
				return
			else
				if(src.stage > 3.5)
					user.visible_message("\red The oven is heating your crowbar too much for you to hold onto it.")
					return
				else
					user.visible_message("\red You shove the crowbar into the door and try to break the lock. (This will take around 5 seconds.)")
					sleep(50)
					user.visible_message("\red You break the lock!")
					user.visible_message("\red <b>The Oven</b> states, 'Error, shutting down for saftey.'")
					if(src.stage > 2.5)
						user.visible_message("\red A burst of hot air surges out of the oven, but you step back and avoid the worst of it.")
						sleep(10)
						src.operating = 0
						src.locked = 0
						src.eject()
					else
						sleep(10)
						src.operating = 0
						src.locked = 0
						src.eject()
		else
			user.visible_message("\red What exactly are you going to do with a crowbar and an oven?")
			return

	else if(istype(G, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = G
		if(WT.remove_fuel(1, user))
			if(operating)
				user.visible_message("\red You start welding through the protective cover. (This will take about 4 seconds.)")
				sleep(40)
				user.visible_message("\red A wave of heat goes past you, but you duck behind the oven before it can burn you.")
				user.visible_message("\red <b>The Oven</b> states, 'Critcal Error, shutting down for maitnance.'")
				src.operating = 0
				src.locked = 0
				src.eject()
				sleep(10)
				playsound(src.loc, 'sound/effects/sparks1.ogg', 50, 0)
				new /obj/effect/decal/cleanable/robot_debris(loc)
				sleep(5)
				del(src)
		else if(WT.remove_fuel(0, user))
			user.visible_message("\red You need more welding fuel to do that!")
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
	var/mob/living/L = O
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
	src.occupant.visible_message("\red You crawl into the oven!")
	update_icon()

/obj/machinery/larkens/oven/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(operating)
		if(user.ckey == src.occupant.ckey)
			user << "\red You hopelessly bang against the door."
			visible_message("\red [src.occupant.name] bangs against the locked oven door!")
		user << "\red It's locked and running"
		return
	if(!src.occupant)
		if(timer)
			visible_message("\red You press the start button. The timer displays : 10 seconds.")
			sleep(100)
			visible_message("\red The oven door shuts and locks.")
			src.occupant.visible_message("\red With a whir, the oven door shuts and locks.")
			sleep(20)
			src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Oven</b> states, 'Engaging.'")
			src.startcooking(user)
		else
			visible_message("\red <b> The Oven </b> states, 'That would be a waste of power, deary!'")
	else
		if(src.occupant.ckey == user.ckey)
			src.occupant.visible_message("\red You can't turn that on from inside!")
			return
		else
			if(timer)
				visible_message("\red You press the start button. The timer displays : 10 seconds.")
				sleep(100)
				visible_message("\red The oven door shuts and locks.")
				src.occupant.visible_message("\red With a whir, the oven door shuts and locks.")
				sleep(20)
				src.occupant.visible_message("\blue You hear a faint voice. \red <b>The Oven</b> states, 'Engaging.'")
				src.startcooking(user)
			else
				if(!locked)
					visible_message("\red You close and lock the oven door.")
					src.occupant.visible_message("\red [user.name] closes and locks the oven door!")
					sleep(20)
					visible_message("\red You turn the dial up to 150C and hit 'Start'.")
					src.occupant.visible_message ("\blue You hear a beep, and then a crackling as the oven turns on. This can't be good.")
					src.startcooking(user)
				else
					sleep(20)
					visible_message("\red You turn the dial up to 150C and hit 'Start'.")
					src.occupant.visible_message ("\blue You hear a beep, and then a crackling as the oven turns on. This can't be good.")
					src.startcooking(user)


/obj/machinery/larkens/oven/verb/eject()
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

/obj/machinery/larkens/oven/relaymove(mob/user as mob)
	if (locked||operating)
		src.occupant.visible_message("\red The oven is locked!")
	else
		src.visible_message("\red [src.occupant.name] starts crawling out of the oven!")
		src.occupant.visible_message("\red You start crawling out of the oven.")
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
	update_icon()
	return

/obj/machinery/larkens/oven/verb/lock()
	set category = "Object"
	set name = "Lock Oven"
	set src in oview(1)
	if (!src.occupant)
		if (src.operating)
			usr.visible_message("\red The oven is running, and won't let you open it!")
			return
		else
			if (!locked)
				locked = 1
				usr.visible_message("\red You close the oven door and lock it.")
			else
				locked = 0
				usr.visible_message("\red You unlock the oven door and open it.")
	else
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

/obj/machinery/larkens/oven/verb/timer()
	set category = "Object"
	set name = "Turn on Oven (Timed)"
	set src in oview(1)

	if(!timer)
		timer = 1
		usr.visible_message("You set the oven to turn on ten seconds after pressing the button.")
	else
		timer = 0
		usr.visible_message("You turn off the oven timer.")


/obj/machinery/larkens/oven/proc/startcooking(mob/user as mob)
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
	icon_state = "oven_on"

	sleep(20)
	visible_message("\red <b>The Oven</b> states, 'Stage 1.' <br> <b>The Oven</b> states, 'Current temperature is: 37C'")
	stage = 1
	src.occupant.visible_message("\blue Is it getting warm in here...?")
	src.occupant.visible_message("\red The internal thermometer shows 37C.")
	if(!src.operating)
		icon_state = "oven_off"
		update_icon()
		sleep(5)
		return
	else
		sleep(70)
		visible_message("\red <b>The Oven</b> states, 'Stage 1 heating.'")
		stage = 1.5
		visible_message("\blue The Oven is giving off a nice warmth.")
		src.occupant.visible_message("\red You start sweating.")
		if(!src.operating)
			src.icon_state = "oven_off"
			src.update_icon()
			sleep(5)
			return
		else
			sleep(60)
			visible_message("\red <b>The Oven</b> states, 'Stage 2.' </br> <b>The Oven</b> states, 'Current temperature is: 45C'")
			stage = 2
			visible_message("\blue The Oven is a bit too hot to touch.")
			src.occupant.visible_message("\red Your skin starts burning.")
			src.occupant.visible_message("\red The internal thermometer shows 45C.")
			if(!src.operating)
				src.icon_state = "oven_off"
				src.update_icon()
				sleep(5)
				return
			else
				sleep(50)
				visible_message("\red <b>The Oven</b> states, 'Stage 2 heating.'</br> <b>The Oven</b> states, 'Current temperature is: 49C'")
				stage = 2.5
				visible_message("\blue The air around the oven is getting unpleasently hot.")
				src.occupant.visible_message("\red It's getting really fucking hot in here.")
				src.occupant.visible_message("\red The internal thermometer shows 49C.")
				src.occupant.apply_damage(5, BURN, "Chest", 0)
				if(!src.operating)
					src.icon_state = "oven_off"
					src.update_icon()
					sleep(5)
					return
				else
					sleep(50)
					visible_message("\red <b>The Oven</b> states, 'Stage 3.' </br> <b>The Oven</b> states, 'Current temperature is: 64C'")
					stage = 3
					src.occupant.emote("scream")
					src.occupant.visible_message("\red Your skin is starting to burn badly!")
					src.occupant.visible_message("\red The internal thermometer shows 64C.")
					src.occupant.apply_damage(10, BURN, "Chest", 0)
					if(!src.operating)
						src.icon_state = "oven_off"
						src.update_icon()
						sleep(5)
						return
					else
						sleep(50)
						visible_message("\red <b>The Oven</b> states, 'Stage 3 heating.'")
						stage = 3.5
						src.occupant.emote("scream")
						src.occupant.visible_message("\red <b> It burns so badly! </b>")
						src.occupant.visible_message("\red The internal thermometer shows 75C.")
						src.occupant.apply_damage(10, BURN, "l_leg", 0)
						src.occupant.apply_damage(10, BURN, "Chest", 0)
						src.occupant.apply_damage(10, BURN, "r_leg", 0)
						if(!src.operating)
							src.icon_state = "oven_off"
							src.update_icon()
							sleep(5)
							return
						else
							sleep(50)
							visible_message("\red <b>The Oven</b> states, 'Stage 4.' </br> <b>The Oven</b> states, 'Current temperature is: 82C'")
							stage = 4
							src.occupant.apply_effect(20, AGONY, 0)
							src.occupant.emote("scream")
							src.occupant.visible_message("\red <b> Your skin feels like it is searing off. </b>")
							src.occupant.visible_message("\red The internal thermometer shows 82C.")
							src.occupant.apply_damage(10, BURN, "l_arm", 0)
							src.occupant.apply_damage(10, BURN, "l_leg", 0)
							src.occupant.apply_damage(10, BURN, "head", 0)
							if(!src.operating)
								src.icon_state = "oven_off"
								src.update_icon()
								sleep(5)
								return
							else
								sleep(50)
								visible_message("\red <b>The Oven</b> states, 'Stage 4 heating.'")
								stage = 4.5
								src.occupant.emote("scream")
								src.occupant.apply_effect(40, AGONY, 0)
								src.occupant.visible_message("\red <b> Your skin is burning like hell! </b>")
								src.occupant.visible_message("\red The internal thermometer shows 86C, and is climbing rapidly..")
								sleep(50)
								visible_message("\red <b>The Oven</b> states, 'Stage 5.' </br> <b>The Oven</b> states, 'Current temperature is: 103C'")
								stage = 5
								src.occupant.visible_message("\red <b> Your entire body feels like it is melting! </b>")
								src.occupant.visible_message("\red The internal thermometer shows 103C.")
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