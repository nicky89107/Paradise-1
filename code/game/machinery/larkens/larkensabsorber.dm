/obj/machinery/larkens/absorber
	name = "Larkens Absorber"
	desc = "For when you want them to suffer."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner"
	layer = 2.9
	density = 1
	anchored = 1
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 500
	var/operating = 0 //Is it on?
	var/mob/living/occupant // Mob who has been put inside
	var/locked = 0
	var/cycles = 1 //used for amount of times heal cycle goes for
	var/aftercycles = 0
	var/mode = 1 //used for absorb or heal mode. 1 is heal, 2 is dissect
	var/toolate = 0 //used for triggering the emergency eject on and off
	var/allowfun = 0 //Used for "pleasure" mode



/obj/machinery/larkens/absorber/New()
	..()

/obj/machinery/larkens/absorber/update_icon()


/obj/machinery/larkens/absorber/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/larkens/absorber/relaymove(mob/user as mob)
	src.go_out()
	return

/obj/machinery/larkens/absorber/attack_hand(mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	if(!isLarkens(user))
		if(operating)
			user << "\red It's locked and running"
			return
		if(src.occupant.ckey == user.ckey)
			src.occupant.visible_message ("There is no button inside!")
			return
		else
			visible_message("\red You hit the big red flashing 'Start' button.")
			src.occupant.visible_message ("\blue You hear a beep, and then a hum as the absorber starts up.")
			src.startmode(user)
	else
		if(operating)
			if(toolate)
				user << "\red The goo-matrix informs you that the emergency eject cannot be used once dissectors have been engaged."
				return
			else
				user << "\red You interface with the goo-matrix and trigger the emergency release."
				src.operating = 0
				src.locked = 0
				src.go_out()
				sleep(10)
				user << "\red The absorbtion goo retracts from your intestines and goes back into the machine from your mouth."
		if(src.occupant.ckey == user.ckey)
			src.occupant.visible_message ("You interface with the goo-matrix and turn the absorber on.")
			src.startmode(user)
		else
			visible_message("\red You hit the big red flashing 'Start' button.")
			src.occupant.visible_message ("\blue You hear a beep, and then a hum as the absorber starts up.")
			src.startmode(user)

/obj/machinery/larkens/absorber/attackby(obj/item/weapon/grab/G as obj, mob/user as mob)
	if(src.occupant)
		user << "\red The absorber is full, empty it first!"
		return
	if (!( istype(G, /obj/item/weapon/grab)) || !(istype(G.affecting, /mob/living/carbon/human)))
		user << "\red This item is not suitable for the Absorber!"
		return
	if(G.affecting.abiotic(1))
		user << "\red Subject may not have abiotic items on."
		return

	user.visible_message("\red [user] starts to put [G.affecting] into the absorber!")
	src.add_fingerprint(user)
	if(do_after(user, 30) && G && G.affecting && !occupant)
		user.visible_message("\red [user] stuffs [G.affecting] into the absorber!")
		var/mob/M = G.affecting
		if(M.client)
			M.client.perspective = EYE_PERSPECTIVE
			M.client.eye = src
		M.loc = src
		src.occupant = M
		del(G)
		update_icon()


/obj/machinery/larkens/absorber/MouseDrop_T(atom/movable/O as mob|obj, mob/user as mob)
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
		user << "The Absorber is full! You can't fit in there!"
		visible_message ("\blue The Absorber rejects [user.name].")
	var/mob/living/L = O
	if(L.ckey != user.ckey)
		return
	if(!istype(L) || L.buckled)
		return
	if(L.abiotic(1))
		visible_message ("\blue <B>The Absorber states, 'Subject cannot have abiotic items on.'</B>")
		return
	if(!L)
		return
	if(L.client)
		L.client.perspective = EYE_PERSPECTIVE
		L.client.eye = src
	L.loc = src
	src.occupant = L
	src.occupant.visible_message("\blue You enter the goo.")
	src.add_fingerprint(user)
	update_icon()

/obj/machinery/larkens/absorber/verb/mode()
	if(src.isLarkens(usr))
		set category = "Object"
		set name = "Change Mode"
		set src in oview(1)

		if (usr.stat != 0)
			return
		if(operating||locked)
			usr.visible_message("\red You cannot change the mode while it is being used!")
		if(allowfun)
			if(src.mode == 1)
				usr.visible_message("\red You set it to absorb.")
				src.mode = 2
			else if (src.mode == 3)
				usr.visible_message("\red You set it to heal.")
				src.mode = 1
			else if (src.mode == 2)
				usr.visible_message("\red You set it to pleasure.")
				src.mode = 3
		else
			if(src.mode == 1)
				usr.visible_message("\red You set it to absorb.")
				src.mode = 2
			else if (src.mode == 2)
				usr.visible_message("\red You set it to heal.")
				src.mode = 1
	else
		usr.visible_message("\red You have no idea how this thing works.")
		return

/obj/machinery/larkens/absorber/verb/eject()
	set category = "Object"
	set name = "Empty Absorber"
	set src in oview(1)

	if (usr.stat != 0)
		return
	if(operating||locked)
		usr.visible_message("\red The Absorber is locked.")
		return
	else
		src.go_out()
		add_fingerprint(usr)
		update_icon()
		return

/obj/machinery/larkens/absorber/verb/lock()
	set category = "Object"
	set name = "Lock Absorber"
	set src in oview(1)

	if (src.isLarkens(src.occupant))
		if (usr.ckey != src.occupant.ckey)
			if (!locked)
				locked = 1
				usr.visible_message("\red You close the Absorber door and lock it.")
			else
				locked = 0
				usr.visible_message("\red You unlock the Absorber door and open it.")
		else
			if (!locked)
				locked = 1
				usr.visible_message("\red You interface with the slime and lock the Absorber door.")
			else
				locked = 0
				usr.visible_message("\red You interface with the slime and unlock the Absorber door.")
	else
		if (usr.ckey != src.occupant.ckey)
			if (!locked)
				locked = 1
				usr.visible_message("\red You close the Absorber door and lock it.")
			else
				locked = 0
				usr.visible_message("\red You unlock the Absorber door and open it.")

		else
			if (!locked)
				usr.visible_message("You can't lock the door from inside!")
			else
				usr.visible_message("You can't unlock the door from inside!")
			return

/obj/machinery/larkens/absorber/verb/setcycle()
	if(src.isLarkens(usr))
		set category = "Object"
		set name = "Set Cycles"
		set src in oview(1)

		if (usr.ckey != src.occupant.ckey)
			return
		else
			if(!cycles)
				src.occupant.visible_message("You set the healing cycles to 2.")
				cycles = 2
				aftercycles = 1
			else if (cycles == 1)
				src.occupant.visible_message("You set the healing cycles to 3.")
				cycles = 3
				aftercycles = 2
			else if (cycles == 3)
				src.occupant.visible_message("You set the healing cycles to 5.")
				cycles = 5
				aftercycles = 4
			else
				src.occupant.visible_message("You reset the healing cycles to 1.")
				cycles = 1
				aftercycles = 0
	else
		usr.visible_message("You don't know how to interact with this machine.")
		return


/obj/machinery/larkens/absorber/proc/go_out()
	if (!src.occupant)
		return
	if(locked||operating)
		src.occupant.visible_message("\red The absorber is locked!")
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

/obj/machinery/larkens/absorber/proc/startmode(mob/user/ as mob)
	if(src.mode == 1)
		user.visible_message("\red <b>The Absorber</b> states, 'Starting healing procedure.'")
		src.starthealing(user)
	else if (src.mode == 2)
		user.visible_message("\red <b>The Absorber</b> states, 'Starting dissection procedure.'")
		src.startabsorbtion(user)
	else if (src.mode == 3)
		user.visible_message("\red <b>The Absorber</b> states, 'Starting pleasure procedure.'")
		src.startfun(user)

/obj/machinery/larkens/absorber/proc/starthealing(mob/user/ as mob)
	if(src.operating)
		return
	use_power(1000)
	src.operating = 1
	update_icon()
	visible_message("\red The door closes and locks.")
	src.occupant.visible_message("\blue The door closes and locks, sealing you into the peaceful goo.")
	sleep(10)
	src.occupant.visible_message("The goo gently coats over your wounds.")
	var/i //our counter
	for(i=0,i<cycles,i++)
		sleep(20)
		src.occupant.heal_overall_damage(10, 10)
		src.occupant.visible_message("You feel slightly better.")
		if(i==aftercycles)
			src.operating = 0
			src.locked = 0
			update_icon()
			src.occupant.visible_message("The door unlocks.")
			visible_message("\red <b>The Absorber</b>'s door unlocks.")
			src.occupant.visible_message("The goo retracts from you.")

/obj/machinery/larkens/absorber/proc/startfun(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("\red <b>The Absorber</b> states, 'No Subject.'")
		return
	if(src.isLarkens(src.occupant))
		use_power(1000)
		src.operating = 1
		update_icon()
		sleep(10)

		if(src.occupant.get_species() == "Slime People")
			src.occupant.visible_message("\blue The goo pushes and mixes with your own slime. It is very pleasent.")
			sleep(10)
			src.occupant.visible_message("\blue The goo makes it's way into your slime core, and starts gently carressing it.")
			sleep(20)
			src.occupant.visible_message("\blue Your slime core is pulsating pleasently.")
			sleep(20)
			src.occupant.visible_message("\blue The goo carresses your backslime, and tightens around you like a hug.")
			sleep(20)
			src.occupant.visible_message("\blue The goo slowly un-mixes with your slime.")
			sleep(20)
			src.occupant.visible_message("\blue The door unlatches.")
			src.operating = 0
			src.locked = 0

		else if (src.occupant.get_species() == "Human")
			if(src.occupant.gender == FEMALE) //I am going to hell. And so is adr. -Tigercat2000
				src.occupant.visible_message("\blue The goo playfully carresses your crotch.") //Yep.
				sleep(20)
				src.occupant.visible_message("\blue The slime delicately opens the lips on your crotch. The goo gets warmer") //My eyes are on fire.
				sleep(20)
				src.occupant.visible_message("\blue The slime gently oozes inside of you.") //I am going to have to burn my computer after this.
				sleep(20)
				src.occupant.visible_message("\blue The soft slime slowly but surely massages your crotch, both outside and inside of you, causing an intense pleasure. You feel the soft slime slowly slithering deeper.") //Nevermind, going to have to burn the house down.
				sleep(20)
				src.occupant.visible_message("\blue The slime grows pleasently warmer, pushing in and out.") //Please kill me.
				sleep(20)
				src.occupant.visible_message("\blue The warm slime inside you gradually thickens as it thrusts, pushing against the walls of your uterus. The slime grabs your ankles to keep your legs open.") //Jesus christ, why
				sleep(20)
				src.occupant.visible_message("\blue The slime around your body tightens, gently hugging you. The slime continues slowly increasing in speed.") //this is definately worse than blue
				sleep(20)
				src.occupant.visible_message("\blue You gasp as the hardened slime slips a bit deeper with every thrust, increasing the blissful pleasure and the hot feeling all over your body") //I just want to set the world on fire, world on fire!
				sleep(20)
				src.occupant.visible_message("\blue The goo welcomingly hugs tighter around you and continues to make it's way deeper inside you.") //Where did I put my fucking flamethrower?
				sleep(20)
				src.occupant.visible_message("\blue The intense feeling makes you try to close your legs, but the slime keeps them tightly in place. You squirm as you feel the massaging slime drive you close to your climax.") //Oh, it's in the corner... now just fuel...
				sleep(20)
				src.occupant.visible_message("\blue The slime tightens more around your body as it pushes in and out, making you closer and closer to the end.") //Ahah, found a gas tank, wonderful
				sleep(20)
				src.occupant.visible_message("\blue You emit a bubbly moan and your muscles tighten as you reach the pleasure peak. The hot sensation almost makes you pass out. Your body goes limp as you relax and the slime slowly slips out, giving a last massage to your oversensitive skin.")
				sleep(20)//It still lights, wonderful
				src.occupant.visible_message("\blue The slime releases the tight grip around you and the door unlatches.") //Yep, going to go set myself on fire.
				src.operating = 0
				src.locked = 0
			else
				src.occupant.visible_message("\red Go away...")
				src.operating = 0
				return
		else
			src.occupant.visible_message("\red Error: Incompatible genetics.")
			src.operating = 0
			src.locked = 0
			sleep(10)
			src.occupant.visible_message("\blue The door unlatches.")

	else
		visible_message("\red <b>The Absorber</b> states, 'ONLY LARKENS HAVE FUN MODE!'")
		src.occupant.visible_message("\red Unable to start.")
		src.operating = 0
		src.locked = 0
		src.go_out()

/obj/machinery/larkens/absorber/proc/startabsorbtion(mob/user as mob)
	if(src.operating)
		return
	if(!src.occupant)
		visible_message("\red <b>The Absorber</b> states, 'No Subject.'")
		return
	use_power(1000)
	src.operating = 1
	update_icon()
	src.occupant.attack_log += "\[[time_stamp()]\] Was Larken-Absorbered by <b>[user]/[user.ckey]</b>" //One shall not simply gib a mob unnoticed!
	user.attack_log += "\[[time_stamp()]\] Larken-Absorbered <b>[src.occupant]/[src.occupant.ckey]</b>"
	if(src.occupant.ckey)
		msg_admin_attack("[user.name] ([user.ckey]) Larken-Absorbered [src.occupant] ([src.occupant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[user.x];Y=[user.y];Z=[user.z]'>JMP</a>)")
	if(!iscarbon(user))
		src.occupant.LAssailant = null
	else
		src.occupant.LAssailant = user
	sleep(10)
	if(src.isLarkens(src.occupant))
		visible_message("\red The door closes and locks.")
		visible_message("\red <b>The Absorber</b> states, 'Stage 1: Data Gathering'")
		src.occupant.visible_message("\red The door closes and locks behind you.")
		src.occupant.visible_message("\red The goo starts pushing against you, and the interface informs you that the absorb mode has been triggered.")
		sleep(10)
		src.occupant.visible_message("\blue The absorbtion goo seems to be sizing you up. It enters into your ears and nostrils.")
		sleep(20)
		src.occupant.visible_message("\blue The absorbtion goo slowly oozes into your mouth, and down your throat. The sensation is pleasant.")
		sleep(20)
		visible_message("\red <b>The Absorber</b> states, 'Species Identified. Species is: [src.occupant.get_species()]'")
		src.occupant.visible_message("\blue The absorbtion goo gently pushes open your mouth.")
		src.occupant.sdisabilities |= MUTE
		sleep(20)
		src.occupant.visible_message("\blue More and more goo goes down your throat. It seems to be providing you oxygen.")
		sleep(20)
		src.occupant.visible_message("\blue You can feel the goo going down through your stomach, and into your intestines.")
		sleep(20)
		src.occupant.visible_message("\blue The goo gently caresses your back. It is completely encasing you, but it feels quite pleasant.")
		if(!operating)
			return
		else
			sleep(20)
			visible_message("\red <b>The Absorber</b> states, 'Gender identified. Gender is [src.occupant.get_gender()]'")
			sleep(20)
			visible_message("\red <b>The Absorber</b> states, 'Stage 2: Break-down.'")
			src.occupant.visible_message("\blue Something seems to be happening with the goo. It is growing warmer. The Goo matrix informs you that it is starting the breakdown procedure.")
			if(!operating)
				return
			else
				sleep(20)
				visible_message("\red <b>The Absorber</b> states, 'Engaging molecular-debonders.'")
				src.occupant.visible_message("\red The goo is growing slightly unpleasent, and is quite warm.")
				sleep(20)
				src.occupant.visible_message("\red You attempt to speak, but cannot, due to the goo lining your esphogus.")
				sleep(20)
				src.occupant.visible_message("\red The goo is getting very warm.")
				sleep(20)
				src.occupant.visible_message("\red The goo is starting to burn your skin.")
				src.occupant.apply_damage(10, BURN, "chest", 0)
				if(!operating)
					return
				else
					sleep(10)
					src.occupant.visible_message("\red You attempt to move, but the goo seems to have solidified around you.")
					sleep(10)
					src.occupant.visible_message("\red The goo is really starting to hurt, especially the goo inside of you.")
					src.occupant.apply_damage(10, BURN, "chest", 0)
					sleep(10)
					visible_message("<b>The Absorber</b> states, 'Molecular disbonders at 60% efficency.'")
					src.occupant.visible_message("\red The goo matrix informs you that Molecular disbonders are at 60% efficency.")
					src.occupant.apply_damage(20, BURN, "chest", 0)
					if(!operating)
						return
					else
						sleep(20)
						src.occupant.visible_message("\red The goo gets to a moderate level of burning, and seems to stop getting worse. The goo matrix informs you that Molecular Disbonders are at 100% efficency.")
						visible_message("<b>The Absorber</b> states, 'Molecular disbonders at 100% efficeny. Engaging dissecters.'")
						src.toolate = 1
						sleep(20)
						src.occupant.visible_message("\red The goo inside of you starts pushing your innards towards your skin. It is very unpleasant. The goo matrix informs you that dissection has begun.")
						src.occupant.apply_damage(10, BRUTE, "chest", 0)
						sleep(10)
						src.occupant.visible_message("\red The goo inside you starts pushing against your skeleton firmly. <b> It hurts a lot. </b>")
						src.occupant.apply_damage(15, BRUTE, "chest", 0)
						sleep(20)
						src.occupant.visible_message("\red Your skeleton starts to crack under the pressure. <b>It is extremely painful</b>.")
						src.occupant.apply_damage(25, BRUTE, "chest", 0)
						sleep(10)
						src.occupant.visible_message("\red <b>More and more goo starts flooding down your throat, filling your innards to capacity. It hurts very badly.</b>")
						src.occupant.apply_damage(10, BRUTE, "chest", 0)
						sleep(20)
						src.occupant.visible_message("\red The once gentle outer-goo shell starts pushing hard against your skin. It is quite painful.")
						src.occupant.apply_damage(10, BRUTE, "head", 0)
						src.occupant.apply_damage(10, BRUTE, "groin", 0)
						sleep(10)
						src.occupant.visible_message("\red The oxygen supply abrubtly cuts off.")
						src.occupant.apply_damage(10, OXY)
						sleep(20)
						src.occupant.visible_message("\red You gasp for breath, but only get the slime filling into your lungs. It feels quite a lot like drowning.")
						src.occupant.apply_damage(20, OXY)
						sleep(20)
						src.occupant.visible_message("\red The goo rips through your skin, and tears you apart. <b> You have never felt this much pain before in your life.</b>")
						src.occupant.apply_damage(70, BRUTE, "chest", 0)
						visible_message("<b>The Absorber</b> states, 'Dissectors complete. Engaging Full-breakdown.'")
						sleep(10)
						src.occupant.visible_message("\red The goo starts fiercly burning through your remaining skin and organs.")
						src.occupant.apply_damage(50, BURN, "groin", 0)
						sleep(10)
						src.occupant.visible_message("\blue Your vision starts to fade, and you realize you are dying.")
						src.occupant.death(1)
						src.occupant.ghostize()
						del(src.occupant)
						src.operating = 0
						update_icon()
	else
		visible_message("\red The door closes and locks.")
		src.occupant.visible_message("\red The door closes and locks behind you.")
		sleep(20)
		visible_message("\red <b>The Absorber</b> states, 'Stage 1: Data Gathering'")
		src.occupant.visible_message("\blue The strange goo around you suddenly starts gently pushing against you.")
		sleep(20)
		src.occupant.visible_message("\blue The strange goo seems to be sizing you up. It enters into your ears and nostrils.")
		sleep(20)
		src.occupant.visible_message("\blue The strange goo slowly oozes into your mouth, and down your throat. The sensation is suprisingly pleasant.")
		sleep(20)
		visible_message("\red <b>The Absorber</b> states, 'Species Identified. Species is: [src.occupant.get_species()]'")
		src.occupant.visible_message("\blue The strange goo gently pushes open your mouth.")
		src.occupant.sdisabilities |= MUTE
		sleep(20)
		src.occupant.visible_message("\blue More and more goo goes down your throat. It seems to be providing you oxygen.")
		sleep(20)
		src.occupant.visible_message("\blue You can feel the goo going down through your stomach, and into your intestines.")
		sleep(20)
		src.occupant.visible_message("\blue The goo gently caresses your back. It is completely encasing you, but it feels quite pleasant.")
		sleep(10)
		visible_message("\red <b>The Absorber</b> states, 'Gender identified. Gender is [src.occupant.get_gender()]'")
		sleep(20)
		visible_message("\red <b>The Absorber</b> states, 'Stage 2: Break-down.'")
		src.occupant.visible_message("\blue Something seems to be happening with the goo. It is growing warmer.")
		sleep(20)
		visible_message("\red <b>The Absorber</b> states, 'Engaging molecular-debonders.'")
		src.occupant.visible_message("\red The goo is growing slightly unpleasent, and is quite warm.")
		sleep(20)
		src.occupant.visible_message("\red You attempt to speak, but cannot, due to the goo lining your esophagus.")
		sleep(10)
		src.occupant.visible_message("\red The goo is getting very warm.")
		sleep(10)
		src.occupant.visible_message("\red The goo is starting to burn your skin.")
		src.occupant.apply_damage(10, BURN, "chest", 0)
		sleep(10)
		src.occupant.visible_message("\red You attempt to move, but the goo seems to have solidified around you.")
		sleep(10)
		src.occupant.visible_message("\red The goo is really starting to hurt, especially the goo inside of you.")
		src.occupant.apply_damage(10, BURN, "chest", 0)
		sleep(10)
		visible_message("<b>The Absorber</b> states, 'Molecular disbonders at 60% efficency.'")
		src.occupant.visible_message("\red You attempt to fight against the goo. In response, it starts burning more fiercly than before.")
		src.occupant.apply_damage(20, BURN, "chest", 0)
		sleep(20)
		src.occupant.visible_message("\red The goo gets to a moderate level of burning, and seems to stop getting worse. That's good, right?")
		visible_message("<b>The Absorber</b> states, 'Molecular disbonders at 100% efficeny. Engaging dissecters.'")
		sleep(20)
		src.occupant.visible_message("\red The goo inside of you starts pushing your innards towards your skin. It is very unpleasant.")
		src.occupant.apply_damage(10, BRUTE, "chest", 0)
		sleep(10)
		src.occupant.visible_message("\red The goo inside you starts pushing against your skeleton firmly. <b> It hurts a lot. </b>")
		src.occupant.apply_damage(15, BRUTE, "chest", 0)
		sleep(20)
		src.occupant.visible_message("\red Your skeleton starts to crack under the pressure. <b>It is extremely painful</b>.")
		src.occupant.apply_damage(25, BRUTE, "chest", 0)
		sleep(10)
		src.occupant.visible_message("\red <b>More and more goo starts flooding down your throat, filling your innards to capacity. It hurts very badly.</b>")
		src.occupant.apply_damage(10, BRUTE, "chest", 0)
		sleep(20)
		src.occupant.visible_message("\red The once gentle outter-goo shell starts pushing hard against your skin. It is quite painful.")
		src.occupant.apply_damage(10, BRUTE, "head", 0)
		src.occupant.apply_damage(10, BRUTE, "groin", 0)
		sleep(10)
		src.occupant.visible_message("\red The oxygen supply abrubtly cuts off.")
		src.occupant.apply_damage(10, OXY)
		sleep(20)
		src.occupant.visible_message("\red You gasp for breath, but only get the slime filling into your lungs. It feels quite a lot like drowning.")
		src.occupant.apply_damage(20, OXY)
		sleep(20)
		src.occupant.visible_message("\red The goo rips through your skin, and tears you apart. <b> You have never felt this much pain before in your life.</b>")
		src.occupant.apply_damage(70, BRUTE, "chest", 0)
		visible_message("<b>The Absorber</b> states, 'Dissectors complete. Engaging Full-breakdown.'")
		sleep(10)
		src.occupant.visible_message("\red The goo starts fiercly burning through your remaining skin and organs.")
		src.occupant.apply_damage(50, BURN, "groin", 0)
		sleep(10)
		src.occupant.visible_message("\blue Your vision starts to fade, and you realize you are dying.")
		src.occupant.death(1)
		src.occupant.ghostize()
		del(src.occupant)
		src.operating = 0
		update_icon()