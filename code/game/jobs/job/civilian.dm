/datum/job/civilian
	title = "Larkens"
	flag = CIVILIAN
	department_flag = SUPPORT
	total_positions = -1
	spawn_positions = -1
	supervisors = "No one."
	selection_color = "#dddddd"
	idtype = /obj/item/weapon/card/id/larkens
	access = list()			//See /datum/job/assistant/get_access()
	minimal_access = list()	//See /datum/job/assistant/get_access()

/datum/job/civilian/equip(var/mob/living/carbon/human/H)
	if(!H)	return 0
	H.equip_or_collect(new /obj/item/clothing/under/larkens(H), slot_w_uniform)
	H.equip_or_collect(new /obj/item/clothing/shoes/black(H), slot_shoes)
	if(H.backbag == 1)
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H), slot_r_hand)
	else
		H.equip_or_collect(new /obj/item/weapon/storage/box/survival(H.back), slot_in_backpack)
	return 1

/datum/job/civilian/get_access()
	return get_all_accesses()
