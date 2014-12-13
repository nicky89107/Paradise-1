/obj/machinery/lobbyimage
	name = "LobbyImage"
	desc = "The name isn't descriptive enough?"
	icon = 'icons/misc/fullscreen_new.dmi'
	icon_state = "rawrcat"
	density = 1
	anchored = 1
	opacity = 1
	layer = FLY_LAYER

/obj/machinery/lobbyimage/New()
	..()
	icon_state = pick("rawrcat","poorcat","mazika","jenny","shadow","squishy")
	slideshow()

/obj/machinery/lobbyimage/proc/slideshow()
	sleep(150)
	icon_state = pick("rawrcat","poorcat","mazika","jenny","shadow","squishy")
	slideshow()

/obj/machinery/lobbyimage/proc/forcenext() //mostly for debugging
	icon_state = pick("rawrcat","poorcat","mazika","jenny","shadow","squishy")
	slideshow()