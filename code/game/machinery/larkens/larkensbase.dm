/obj/machinery/larkens/
	name = "Larkens Base-Machine"
	desc = "You shouldn't be seeing this."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "scanner"

/obj/machinery/larkens/proc/isLarkens(mob/user as mob)
	if(user.name == "Shadow Larkens" || "Jenny Larkens" || "Jennifer Larkens"  ||  "Skye Larkens" || "Violet Larkens" || "Gemma Larkens" || "Bianca Larkens" || "Mazika Larkens" || "Jamie Larkens" || "Haley Larkens")
		return 1
	else
		return 0