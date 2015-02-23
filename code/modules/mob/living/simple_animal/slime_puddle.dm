/mob/living/simple_animal/slime_puddle
	name = "puddle of slime"
	desc = "It's a large puddle of a strange slime."
	icon_state = "slime_puddle"
	icon_living = "slime_puddle"
	icon_dead = "slime_puddle"
	speak_chance = 0
	turns_per_move = 5
	maxHealth = 100
	health = 100
	density = 0
	response_help  = "pokes the"
	response_disarm = "pokes the"
	response_harm   = "pokes the"
	harm_intent_damage = 0
	pass_flags = PASSTABLE
	can_hide = 1
	layer = TURF_LAYER+0.2
	wander = 0
	var/mob/living/carbon/trappedh = null

/mob/living/simple_animal/slime_puddle/Life()
	..()

/mob/living/simple_animal/slime_puddle/attackby(var/obj/item/O as obj, var/mob/user as mob)
	usr << "\red The [O] bounces off the slime!"
	for (var/mob/M in viewers(src, null))
		M.show_message("\red \b [user] hits [src] with the [O], but it bounces off!")
	return

/mob/living/simple_animal/slime_puddle/verb/door_crawl()
	set name = "Slime under door"
	set desc = "Move underneath a door, to catch your prey!"
	set category = "Puddle"


	if(src.stat != CONSCIOUS)	return

	var/obj/machinery/door/dinrange

	for(var/obj/machinery/door/d in range(1,src))
		dinrange = d
		break

	if(dinrange)
		src << "\blue You start sliming under the door."
		spawn(60)
			src << "\blue You slime underneath the door!"
			src.loc = dinrange.loc
			return

/mob/living/simple_animal/slime_puddle/verb/trap_above()
	set name = "Trap"
	set desc = "Trap anyone foolish enough to step in your slime!"
	set category = "Puddle"

	if(src.stat != CONSCIOUS)	return

	var/mob/living/carbon/human/stupid

	for(var/mob/living/carbon/human/H in src.loc)
		if(H.loc == src)
			break
		else
			if(H.loc == src.loc)
				stupid = H
				break
			else
				break

	if(stupid)
		src.visible_message("\red [src] suddenly rises up and latches onto the legs of [stupid]!","\red You quickly slime over the legs of [stupid]!","\red You hear a strange squishing noise.")
		stupid << "\red You legs are coated with a strange goo!"
		src << "\red You realize that you cannot move while around [stupid]'s legs."

		stupid.apply_effect(200, STUN, 0)
		src.trappedh = stupid
		src.canmove = 0

	else
		src << "\red There is no fool standing in your slime!"

/mob/living/simple_animal/slime_puddle/verb/untrap()
	set name = "Release Trapped Person"
	set desc = "Let go of anyone you have trapped."
	set category = "Puddle"

	if(src.stat != CONSCIOUS)	return

	if(src.trappedh)
		trappedh.SetStunned(0)
		src.visible_message("\red [src] retracts it's slime from [trappedh]'s legs, freeing them.","\red You release the legs of [trappedh]","\red You hear a slurping noise.")
		trappedh << "\red You can move again!"
		src << "You can move away from [trappedh] now."
		trappedh = null
		src.canmove = 1

	else
		src << "\red You have not trapped anyone yet!"

/mob/living/simple_animal/slime_puddle/verb/reform()
	set name = "Reform"
	set desc = "Reform into your humanoid form."
	set category = "Puddle"
	var/didcontents = 0

	if(src.stat != CONSCIOUS)	return


	for(var/mob/living/carbon/human/slime/S in contents)
		if(trappedh)
			didcontents = 1

		if(didcontents)
			src.visible_message("\red [src] starts to reform into a slime person around [trappedh]!","\blue You start to reform into a slime person around [trappedh]! (This will take about 10 seconds)")
		else
			src.visible_message("\red [src] starts to reform into a slime person!","\blue You start to reform into a slime person! (This will take about 10 seconds)")
		spawn(100)
			if(trappedh)
				S.slime_contents.Add(trappedh)
				trappedh.insidemob = 1
				trappedh.loc = S
				trappedh.SetStunned(0)

			S.loc = src.loc
			S.key = src.key
			if(didcontents)
				src.visible_message("\red [src] reforms into a slime person around [trappedh], trapping them!")
			else
				src.visible_message("\red [src] reforms into a slime person!")
			del(src)
			break
