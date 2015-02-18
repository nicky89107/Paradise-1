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
	var/trappedh = null

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

	for(var/mob/living/carbon/human/H in range(0,src))
		if(H.loc == src)
			break
		else
			stupid = H
			break

	if(stupid)
		src << "\red You quickly slime over the legs of [stupid]!"
		stupid << "\red The puddle of goo under you rises up and grabs ahold of your legs!"
		for(var/mob/O in oviewers())
			if ((O.client && !( O.blinded )))
				O << "\red [src] suddenly rises up and latches onto the legs of [stupid]!"

		stupid.apply_effect(200, STUN, 0)
		trappedh = stupid

	else
		src << "\red There is no fool standing in your slime!"

/mob/living/simple_animal/slime_puddle/verb/reform()
	set name = "Reform"
	set desc = "Reform into your humanoid form."
	set category = "Puddle"

	if(src.stat != CONSCIOUS)	return

	for(var/mob/living/carbon/human/slime/S in contents)
		S.loc = src.loc
		S.key = src.key
		del(src)
		break