/obj/machinery/larkens/
	name = "Larkens Base-Machine"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner"


/obj/machinery/larkens/proc/isLarkens(mob/M as mob)
	if(M.real_name == "Shadow Larkens")
		return 1
	else if(M.real_name == "Jenny Larkens")
		return 1
	else if(M.real_name == "Jennifer Larkens" )
		return 1
	else if(M.real_name == "Skye Larkens")
		return 1
	else if(M.real_name == "Violet Larkens")
		return 1
	else if(M.real_name == "Gemma Larkens")
		return 1
	else if(M.real_name == "Bianca Larkens")
		return 1
	else if(M.real_name == "Mazika Larkens")
		return 1
	else if(M.real_name == "Jamie Larkens")
		return 1
	else if(M.real_name == "Haley Larkens")
		return 1
	else if(M.real_name == "Squishy Larkens")
		return 1
	else
		return 0
