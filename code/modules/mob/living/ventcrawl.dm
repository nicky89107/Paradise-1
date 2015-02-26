//Disabling this due to.. really fucking weird bugs. :(
/mob/living/proc/handle_ventcrawl()
	for(var/obj/machinery/atmospherics/unary/vent_pump/V in range(src,1))
		if(V.welded) continue
		src.Move(V)
		return
	src << "You can only enter an unwelded vent!"

/obj/machinery/atmospherics/proc/sanitizedir(initdir) //Sanitize initialize directions to be human readable. Probably not correct terms, but fuck it.
	var/directreturn = ""
	if(initdir == 12)
		directreturn = "East, West"
	else if(initdir == 3)
		directreturn = "North, South"
	else if(initdir == 4)
		directreturn = "East, West"
	else if(initdir == 11)
		directreturn = "North, South, West"
	else if(initdir == 7)
		directreturn = "North, South, East"
	else if(initdir == 13)
		directreturn = "North, East, West"
	else if(initdir == 9)
		directreturn = "North, West"
	else if(initdir == 6)
		directreturn = "South, East"
	else if(initdir == 10)
		directreturn = "South, West"
	else if(initdir == 14)
		directreturn = "South, East, West"
	else
		directreturn = "ERROR TIGER DIDN'T CODE THIS SCENARIO. DEBUG-INITDIR: \red [initdir]"

	return directreturn


/obj/machinery/atmospherics/relaymove(mob/user as mob,var/mdir)
	if(!anchored)
		user.loc = get_turf(src.loc)
		return
	if(user.stat || !isturf(src.loc))
		return
	if(!(mdir&initialize_directions))
		user << "That's the side of the pipe, ow." // find the user and /-put a donk on it-\ no, inform them that they ran into the pipe, useless
		user.Stun(1)
		user << "Valid directions are: [sanitizedir(initialize_directions)]" //Inform the user, in human-readable format, which ways they can go from here.
		return
	var/turf/T = get_step(loc,mdir)
	var/fromdir = turn(mdir,180)
	for(var/obj/machinery/atmospherics/OMA in T)
		if(!(OMA.initialize_directions&fromdir))
			continue
		user.Move(OMA)
		return
	user.Move(T) // broken pipe

/obj/machinery/atmospherics/Entered(mob/M)
	if(istype(M) && M.client)
		M.client.perspective = EYE_PERSPECTIVE
		M.client.eye = loc


/obj/machinery/atmospherics/unary/vent_pump/Entered(mob/user, atom/oldloc)
	if(istype(oldloc, /obj/machinery/atmospherics)) // this is a unary device, came from a pipe rather than the world
		if(welded)
			user << "\red [src] is welded shut!"
			return ..()
		user.Move(loc)
		user.visible_message("\blue [user] scrambles out of [src].")
		if(user.client)
			user.client.perspective = MOB_PERSPECTIVE
			user.client.eye = user
	return ..()

/obj/machinery/atmospherics/binary/pump/Enter(mob/M,atom/oldloc)
	if(stat || !on) return 1
	if(get_dir(src,oldloc) == dir) // output
		M << "You can't move against the flow of [src]!"
		return 0
	return 1

/obj/machinery/atmospherics/binary/pump/Entered(mob/living/M as mob)
	if(on)
		M << "[src] spits you violently out the other side!"
		M.apply_damage(5)
		src.relaymove(M,dir)
	return ..()

/obj/machinery/atmospherics/binary/volume_pump/Enter(mob/M,atom/oldloc)
	if(stat || !on) return 1
	if(get_dir(src,oldloc) == dir) // output
		M << "You can't move against the flow of [src]!"
		return 0
	return 1
/obj/machinery/atmospherics/binary/volume_pump/Entered(mob/living/M as mob)
	if(on)
		M << "[src] spits you violently out the other side!"
		M.apply_damage(5)
		src.relaymove(M,dir)
	return ..()

/obj/machinery/atmospherics/valve/Enter(mob/M,atom/oldloc)
	if(!stat && !open)
		M << "You can't get past [src]."
		return 0
	return 1


/obj/machinery/atmospherics/Del()
	for(var/atom/movable/AM in src)
		AM.loc = loc
	..()
