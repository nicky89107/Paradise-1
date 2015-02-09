/obj/structure/dresser
	name = "dresser"
	desc = "A nicely-crafted wooden dresser. It's filled with lots of undies."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "dresser"
	density = 1
	anchored = 1
	var/UWnum = 0
	var/USnum = 0

/obj/structure/dresser/proc/convuwf(uwf)
	if(uwf == "Red")
		UWnum = 1
	else if(uwf == "White")
		UWnum = 2
	else if(uwf == "Yellow")
		UWnum = 3
	else if(uwf == "Blue")
		UWnum = 4
	else if(uwf == "Black")
		UWnum = 5
	else if(uwf == "Thong")
		UWnum = 6
	else if(uwf == "None")
		UWnum = 7
	else
		UWnum = 7
		return

/obj/structure/dresser/proc/convuwm(uwm)
	if(uwm == "White")
		UWnum = 1
	else if(uwm == "Grey")
		UWnum = 2
	else if(uwm == "Green")
		UWnum = 3
	else if(uwm == "Blue")
		UWnum = 4
	else if(uwm == "Black")
		UWnum = 5
	else if(uwm == "Mankini")
		UWnum = 6
	else if(uwm == "None")
		UWnum = 7
	else
		UWnum = 7
		return

/obj/structure/dresser/proc/convus(us)
	if(us == "Black Tank top")
		USnum = 1
	else if(us == "White Tank top")
		USnum = 2
	else if(us == "Black shirt")
		USnum = 3
	else if(us == "White shirt")
		USnum = 4
	else if(us == "None")
		USnum = 5
	else
		USnum = 5
		return

/obj/structure/dresser/attack_hand(mob/user as mob)
	if(!Adjacent(user))//no tele-grooming
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user

		var/choice = input(user, "Underwear, or Undershirt?", "Changing") as null|anything in list("Underwear","Undershirt")

		if(!Adjacent(user))
			return
		switch(choice)
			if("Underwear")
				if(H.gender == FEMALE)
					var/new_undies = input(user, "Select your underwear", "Changing")  as null|anything in underwear_f
					if(new_undies)
						H.underwear = convuwf(new_undies)//because we use numbers here, fuck TG
				else
					var/new_undies = input(user, "Select your underwear", "Changing")  as null|anything in underwear_m
					if(new_undies)
						H.underwear = convuwm(new_undies) //because we use numbers here, fuck TG

			if("Undershirt")
				var/new_undershirt = input(user, "Select your undershirt", "Changing") as null|anything in undershirt_list
				if(new_undershirt)
					H.undershirt = convus(new_undershirt)

		add_fingerprint(H)
		H.update_body()