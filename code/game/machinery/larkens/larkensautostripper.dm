/obj/machinery/larkens/autostrip
	name = "Stripping machine"
	desc = "A clothes remover. It removes clothes."
	anchored = 1.0
	density = 0
	icon = 'icons/obj/machines/metal_detector.dmi'
	icon_state = "metaldetector0"
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 250

/obj/machinery/larkens/autostrip/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(H.abiotic(1))
			H.apply_effect(40, STUN, 0)
			H.visible_message("The stripping machine grabs you.")
			for(var/obj/item/W in H)
				H.drop_from_inventory(W)
				H.visible_message("The machine removes your [W.name]")
			sleep(20)
			H.visible_message("The stripping machine removes your clothing and releases you.")
			H.SetStunned(0)
			flick("metaldetector1",src)
		else
			flick("metaldetector1",src)

/obj/machinery/larkens/disposaltran
	name = "Disposals transferal system"
	desc = "Moves living things to different conveyer."
	anchored = 1.0
	density = 0
	icon = 'icons/obj/machines/metal_detector.dmi'
	icon_state = "metaldetector0"
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 250
	var/movedir = "north"

/obj/machinery/larkens/disposaltran/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = AM
		if(H.abiotic(1))
			H.apply_effect(40, STUN, 0)
			H.anchored = 1
			sleep(10)
			H.visible_message("The machine grabs you.")
			for(var/obj/item/W in H)
				H.drop_from_inventory(W)
			sleep(20)
			visible_message("The machine moves [H.name] to another conveyer.")
			H.visible_message("The stripping machine removes your clothing and moves you to another conveyer.")
			H.SetStunned(0)
			if(src.movedir == "north")
				H.x = src.x
				H.y = src.y + 1
				H.z = src.z
			else if(src.movedir == "south")
				H.x = src.x
				H.y = src.y - 1
				H.z = src.z
			else if(src.movedir == "east")
				H.x = src.x + 1
				H.y = src.y
				H.z = src.z
			else if(src.movedir == "west")
				H.x = src.x - 1
				H.y = src.y
				H.z = src.z
			else
				return
			H.anchored = 0
			H.visible_message("\red The stripping machine knocks you over!")
			H.resting = 1
			flick("metaldetector1",src)
		else
			sleep(5)
			flick("metaldetector1",src)
			H.visible_message("The machine moves you to another conveyer")
			visible_message("The machine moves [H.name] to another conveyer.")
			H.visible_message("\red The stripping machine knocks you over!")
			H.resting = 1
			if(src.movedir == "north")
				H.x = src.x
				H.y = src.y + 1
				H.z = src.z
			else if(src.movedir == "south")
				H.x = src.x
				H.y = src.y - 1
				H.z = src.z
			else if(src.movedir == "east")
				H.x = src.x + 1
				H.y = src.y
				H.z = src.z
			else if(src.movedir == "west")
				H.x = src.x - 1
				H.y = src.y
				H.z = src.z
			else
				return

/obj/machinery/larkens/revdisposaltran
	name = "Reversed Disposal Transferal System"
	desc = "Moves non-living things to a different conveyer"
	anchored = 1.0
	density = 0
	icon = 'icons/obj/machines/metal_detector.dmi'
	icon_state = "metaldetector0"
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 250
	var/movedir = "north"

/obj/machinery/larkens/revdisposaltran/Crossed(AM as mob|obj)
	if (istype(AM, /obj/item))
		var/obj/item/I = AM
		if(src.movedir == "north")
			I.x = src.x
			I.y = src.y + 1
			I.z = src.z
		else if(src.movedir == "south")
			I.x = src.x
			I.y = src.y - 1
			I.z = src.z
		else if(src.movedir == "east")
			I.x = src.x + 1
			I.y = src.y
			I.z = src.z
		else if(src.movedir == "west")
			I.x = src.x - 1
			I.y = src.y
			I.z = src.z
		else
			return
		visible_message("The disposal transferal system moves [I.name] to another conveyer!")
	else
		return


/obj/machinery/larkens/disposaltranslime
	name = "Disposals transferal system"
	desc = "Moves living things to different conveyer."
	anchored = 1.0
	density = 0
	icon = 'icons/obj/machines/metal_detector.dmi'
	icon_state = "metaldetector0"
	use_power = 1
	idle_power_usage = 20
	active_power_usage = 250
	var/movedir = "north"

/obj/machinery/larkens/disposaltranslime/Crossed(AM as mob|obj)
	if (istype(AM, /mob/living/carbon/human/slime))
		var/mob/living/carbon/human/slime/H = AM
		if(H.abiotic(1))
			H.apply_effect(40, STUN, 0)
			H.anchored = 1
			sleep(10)
			H.visible_message("The machine grabs you.")
			for(var/obj/item/W in H)
				H.drop_from_inventory(W)
			sleep(20)
			H.visible_message("The stripping machine removes your clothing and moves you to another conveyer.")
			H.SetStunned(0)
			if(src.movedir == "north")
				H.x = src.x
				H.y = src.y + 1
				H.z = src.z
			else if(src.movedir == "south")
				H.x = src.x
				H.y = src.y - 1
				H.z = src.z
			else if(src.movedir == "east")
				H.x = src.x + 1
				H.y = src.y
				H.z = src.z
			else if(src.movedir == "west")
				H.x = src.x - 1
				H.y = src.y
				H.z = src.z
			else
				return
			H.anchored = 0
			H.visible_message("\red The stripping machine knocks you over!")
			H.resting = 1
			flick("metaldetector1",src)
		else
			sleep(5)
			flick("metaldetector1",src)
			H.visible_message("The machine moves you to another conveyer")
			visible_message("The machine moves [H.name] to another conveyer.")
			if(src.movedir == "north")
				H.x = src.x
				H.y = src.y + 1
				H.z = src.z
			else if(src.movedir == "south")
				H.x = src.x
				H.y = src.y - 1
				H.z = src.z
			else if(src.movedir == "east")
				H.x = src.x + 1
				H.y = src.y
				H.z = src.z
			else if(src.movedir == "west")
				H.x = src.x - 1
				H.y = src.y
				H.z = src.z
			else
				return