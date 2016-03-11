/* ==================================================== */
/* --------------------- Machine ---------------------- */
/* ==================================================== */
/obj/machinery/espresso_machine/
	name = "espresso machine"
	desc = "It's top of the line NanoTrasen espresso technology! Featuring 100% Organic Locally-Grown espresso beans!" //haha no
	icon = 'icons/obj/foodNdrink/zecoffee.dmi'
	icon_state = "funny" //change
	var/icon_base = "funny" //change
	density = 1
	anchored = 1
	flags = FPRINT
	mats = 30
	var/machine_name = "Espresso Machine"
	var/doing_a_thing = 0
	var/cupinside = 0 //true or false
	var/top_on = 1 //screwed on or screwed off
	var/water_level = 100 //water level, used to press the coffee
	var/water_level_max = 100 //max ammount of water that can go in
	var/cup = null
	var/cup_name = "espresso cup"
	// super frankencode

	New()
		UnsubscribeProcess()

	attackby(var/obj/item/W as obj, var/mob/user as mob)
		if (istype(W, /obj/item/reagent_containers/food/drinks/espressocup))
			if (src.cupinside == 1)
				user.show_text("The [src] can't hold any more [src.cup_name]s, doofus!")
			if (src.cupinside == 0)
				user.drop_item()
				src.cupinside = 1
				W.set_loc(src)
				user.show_text ("You place the [src.cup_name] into the [src].")
				src.update()
		// if (istype(W, /obj/item/reagent_containers/glass/))	//	pour contents of the reagent_container inside and set water level
		// 	var/datum/reagents/R = W:reagents
		// 	W:reagents.isolate_reagent("water")
		// 	current_reagent.volume
		// 	W:reagents.del_reagent("water")
		// 	user.show_text("You dumped [src.wateramt] into the [src].")
		// 	return

	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		if (src.cupinside == 1)
			if(!stat & (NOPOWER|BROKEN))
				switch(alert("What would you like to do with [src]?",,"Make espresso","Remove cup","Nothing"))
					if ("Make espresso")
						if (src.water_level >= 10)
							src.water_level -= 10
							var/drink_choice = input(user, "What kind of espresso do you want to make?", "Selection") as null|anything in list("Espresso","Latte","Mocha","Cappuchino","Americano")
							if (!drink_choice)
								return
							switch (drink_choice)  //finds cup in contents and adds chosen drink to it
								if ("Espresso")
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso",10)
									return
								if ("Latte") // 5:1 milk:espresso
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso", 1.6)
										C.reagents.add_reagent("milk", 8.4)
									return
								if ("Mocha") // 3:1:3 espresso:milk:chocolate
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso", 4.3)
										C.reagents.add_reagent("milk", 1.4)
										C.reagents.add_reagent("chocolate", 4.3)
									return
								if ("Cappuchino") // 1:1:1 milk foam:milk:espresso
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso", 3.5)
										C.reagents.add_reagent("milk", 6.5)
									return
								if ("Americano") // 3:2 water:espresso
									for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
										C.reagents.add_reagent("espresso", 4)
										C.reagents.add_reagent("water", 6)
									return
						else
							user.show_text("You don't have enough water in the machine to do that!")
							return ..()
					if ("Remove espresso cup")
						src.cupinside = 0
						for(var/obj/item/reagent_containers/food/drinks/espressocup/C in src.contents)
							C:set_loc(src.loc)
						user.show_text("You have removed the [src.cup_name] from the [src].")
						src.update()
						return ..()
						//remove cup from contents
					if ("Nothing")
						return ..()
			else
				return ..()
		if (src.cupinside == 0 && top_on == 1)
			user.show_text("You begin unscrewing the top of the [src].")
			if (!do_after(user, 30))
				boutput(user, "<span style=\"color:red\">You were interrupted!</span>")
				return ..()
			else
				src.top_on = 0
				user.show_text("You have unscrewed the top of the [src].")
				return ..()
		if (src.cupinside == 0 && top_on == 0)
			user.show_text("You begin screwing the top of the [src] back on.")
			if (!do_after(user, 30))
				boutput(user, "<span style=\"color:red\">You were interrupted!</span>")
				return ..()
			else
				src.top_on = 1
				user.show_text("You have screwed the top of the [src] back on.")
				return ..()
		else return ..()

	ex_act(severity)
		switch(severity)
			if(1.0)
				qdel(src)
				return
			if(2.0)
				if (prob(50))
					qdel(src)
					return

	blob_act(var/power)
		if (prob(25 * power/20))
			qdel(src)

	meteorhit()
		qdel(src)
		return

	proc/update()
//		src.icon_state = "espresso_machine[src.cupinside]" //i switch this over after i get icons done
		src.icon_state = "syndie"
		return

/* ===================================================== */
/* ---------------------- Cup Rack --------------------- */
/* ===================================================== */
/obj/cup_rack
	name = "coffee cup rack"
	desc = "It's a rack to hang your fancy coffee cups." //*tip
	icon = 'icons/obj/foodNdrink/zecoffee.dmi'
	icon_state = "cuprack7" //changes based on cup_ammount
	var/cup_amount = 7
	var/contained_cup = /obj/item/reagent_containers/food/drinks/espressocup
	var/contained_cup_name = "espresso cup"

	get_desc(dist, mob/user)
		if (dist <= 2)
			. += "There's [(src.cup_amount > 0) ? src.cup_amount : "no" ] [src.contained_cup_name][s_es(src.cup_amount)] on \the [src]."

	attackby(obj/item/W as obj, mob/user as mob)
		if (istype(W, src.contained_cup) & src.cup_amount < 7)
			user.drop_item()
			qdel(W)
			src.cup_amount ++
			boutput(user, "You place \the [src.contained_cup_name] back onto \the [src].")
			src.updateicon()
		else return ..()

	attack_hand(mob/user as mob)
		src.add_fingerprint(user)
		if (src.cup_amount <= 0)
			user.show_text("\The [src] doesn't have any [src.contained_cup_name]s left, doofus!", "red")
		else
			boutput(user, "You take \an [src.contained_cup_name] off of \the [src].")
			src.cup_amount--
			var/obj/item/reagent_containers/food/drinks/espressocup/P = new /obj/item/reagent_containers/food/drinks/espressocup
			user.put_in_hand_or_drop(P)
			src.updateicon()

	proc/updateicon()
		src.icon_state = "cuprack[src.cup_amount]" //sets the icon_state to the ammount of cups on the rack
		return