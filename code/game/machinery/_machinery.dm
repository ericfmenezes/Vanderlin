/**
 * Machines in the world, such as computers, pipes, and airlocks.
 *
 *Overview:
 *  Used to create objects that need a per step proc call.  Default definition of 'Initialize()'
 *  stores a reference to src machine in global 'machines list'.  Default definition
 *  of 'Destroy' removes reference to src machine in global 'machines list'.
 *
 *Class Variables:
 *  use_power (num)
 *     current state of auto power use.
 *     Possible Values:
 *        NO_POWER_USE -- no auto power use
 *        IDLE_POWER_USE -- machine is using power at its idle power level
 *        ACTIVE_POWER_USE -- machine is using power at its active power level
 *
 *  active_power_usage (num)
 *     Value for the amount of power to use when in active power mode
 *
 *  idle_power_usage (num)
 *     Value for the amount of power to use when in idle power mode
 *
 *   power_channel (num)
 *      What channel to draw from when drawing power for power mode
 *      Possible Values:
 *         EQUIP:0 -- Equipment Channel
 *         LIGHT:2 -- Lighting Channel
 *         ENVIRON:3 -- Environment Channel
 *
 *   component_parts (list)
 *      A list of component parts of machine used by frame based machines.
 *
 *   stat (bitflag)
 *      Machine status bit flags.
 *      Possible bit flags:
 *         BROKEN -- Machine is broken
 *         NOPOWER -- No power is being supplied to machine.
 *         MAINT -- machine is currently under going maintenance.
 *         EMPED -- temporary broken by EMP pulse
 *
 *Class Procs:
 *   Initialize()                     'game/machinery/machine.dm'
 *
 *   Destroy()                   'game/machinery/machine.dm'
 *
 *   auto_use_power()            'game/machinery/machine.dm'
 *      This proc determines how power mode power is deducted by the machine.
 *      'auto_use_power()' is called by the 'master_controller' game_controller every
 *      tick.
 *
 *      Return Value:
 *         return:1 -- if object is powered
 *         return:0 -- if object is not powered.
 *
 *      Default definition uses 'use_power', 'power_channel', 'active_power_usage',
 *      'idle_power_usage', 'powered()', and 'use_power()' implement behavior.
 *
 *   powered(chan = EQUIP)         'modules/power/power.dm'
 *      Checks to see if area that contains the object has power available for power
 *      channel given in 'chan'.
 *
 *   use_power(amount, chan=EQUIP)   'modules/power/power.dm'
 *      Deducts 'amount' from the power channel 'chan' of the area that contains the object.
 *
 *   power_change()               'modules/power/power.dm'
 *      Called by the area that contains the object when ever that area under goes a
 *      power state change (area runs out of power, or area channel is turned off).
 *
 *   RefreshParts()               'game/machinery/machine.dm'
 *      Called to refresh the variables in the machine that are contributed to by parts
 *      contained in the component_parts list. (example: glass and material amounts for
 *      the autolathe)
 *
 *      Default definition does nothing.
 *
 *   process()                  'game/machinery/machine.dm'
 *      Called by the 'machinery subsystem' once per machinery tick for each machine that is listed in its 'machines' list.
 *
 *   process_atmos()
 *      Called by the 'air subsystem' once per atmos tick for each machine that is listed in its 'atmos_machines' list.
 *
 *   is_operational()
 *        Returns 0 if the machine is unpowered, broken or undergoing maintenance, something else if not
 *
 *    Compiled by Aygar
*/

/obj/machinery
	name = "machinery"
	icon = 'icons/obj/stationobjs.dmi'
	desc = ""
	verb_say = "beeps"
	verb_yell = "blares"
	pressure_resistance = 15
	max_integrity = 200
	layer = BELOW_OBJ_LAYER //keeps shit coming out of the machine from ending up underneath it.

	anchored = TRUE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT

	var/stat = 0
	var/use_power = IDLE_POWER_USE
		//0 = dont run the auto
		//1 = run auto, use idle
		//2 = run auto, use active
	var/idle_power_usage = 0
	var/active_power_usage = 0
	var/power_channel = EQUIP
		//EQUIP,ENVIRON or LIGHT
	var/wire_compatible = FALSE

	var/list/component_parts = null //list of all the parts used to build it, if made from certain kinds of frames.
	var/panel_open = FALSE
	var/state_open = FALSE
	var/critical_machine = FALSE //If this machine is critical to station operation and should have the area be excempted from power failures.
	var/list/occupant_typecache //if set, turned into typecache in Initialize, other wise, defaults to mob/living typecache
	var/atom/movable/occupant = null
	var/speed_process = FALSE // Process as fast as possible?

	var/interaction_flags_machine = INTERACT_MACHINE_WIRES_IF_OPEN | INTERACT_MACHINE_ALLOW_SILICON | INTERACT_MACHINE_OPEN_SILICON | INTERACT_MACHINE_SET_MACHINE
	var/fair_market_price = 69
	var/market_verb = "Customer"
	var/payment_department = ACCOUNT_ENG

	// For storing and overriding ui id and dimensions
	var/tgui_id // ID of TGUI interface
	var/ui_style // ID of custom TGUI style (optional)
	var/ui_x // Default size of TGUI window, in pixels
	var/ui_y

	var/climb_time = 0
	var/climb_stun = 0
	var/climbable = FALSE
	var/climb_sound = 'sound/foley/woodclimb.ogg'
	var/climb_offset = 0 //offset up when climbed
	var/mob/living/structureclimber

/obj/machinery/Initialize()
	if(!armor)
		armor = list("blunt" = 25, "slash" = 25, "stab" = 25,  "piercing" = 10, "fire" = 50, "acid" = 70)
	. = ..()
	GLOB.machines += src

	if(!speed_process)
		START_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSfastprocess, src)

	if (occupant_typecache)
		occupant_typecache = typecacheof(occupant_typecache)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/Destroy()
	GLOB.machines.Remove(src)
	if(!speed_process)
		STOP_PROCESSING(SSmachines, src)
	else
		STOP_PROCESSING(SSfastprocess, src)
	dropContents()
	if(length(component_parts))
		for(var/atom/A in component_parts)
			qdel(A)
		component_parts.Cut()
	return ..()

/obj/machinery/proc/locate_machinery()
	return

/obj/machinery/process()//If you dont use process or power why are you here
	return PROCESS_KILL

/obj/machinery/proc/process_atmos()//If you dont use process why are you here
	return PROCESS_KILL

/obj/machinery/emp_act(severity)
	. = ..()
	if(use_power && !stat && !(. & EMP_PROTECT_SELF))
		new /obj/effect/temp_visual/emp(loc)

/obj/machinery/proc/open_machine(drop = TRUE)
	state_open = TRUE
	density = FALSE
	if(drop)
		dropContents()
	update_icon()
	updateUsrDialog()

/obj/machinery/proc/dropContents(list/subset = null)
	var/turf/T = get_turf(src)
	for(var/atom/movable/A in contents)
		if(subset && !(A in subset))
			continue
		A.forceMove(T)
		if(isliving(A))
			var/mob/living/L = A
			L.update_mobility()
	occupant = null

/obj/machinery/proc/can_be_occupant(atom/movable/am)
	return occupant_typecache ? is_type_in_typecache(am, occupant_typecache) : isliving(am)

/obj/machinery/proc/close_machine(atom/movable/target = null)
	state_open = FALSE
	density = TRUE
	if(!target)
		for(var/am in loc)
			if (!(can_be_occupant(am)))
				continue
			var/atom/movable/AM = am
			if(AM.has_buckled_mobs())
				continue
			if(isliving(AM))
				var/mob/living/L = am
				if(L.buckled || L.mob_size >= MOB_SIZE_LARGE)
					continue
			target = am

	var/mob/living/mobtarget = target
	if(target && !target.has_buckled_mobs() && (!isliving(target) || !mobtarget.buckled))
		occupant = target
		target.forceMove(src)
	updateUsrDialog()
	update_icon()

/obj/machinery/proc/auto_use_power()
	return 1

/obj/machinery/proc/is_operational()
	return !(stat & (NOPOWER|BROKEN|MAINT))

/obj/machinery/can_interact(mob/user)
	var/silicon = IsAdminGhost(user)
	if((stat & (NOPOWER|BROKEN)) && !(interaction_flags_machine & INTERACT_MACHINE_OFFLINE))
		return FALSE
	if(panel_open && !(interaction_flags_machine & INTERACT_MACHINE_OPEN))
		if(!silicon || !(interaction_flags_machine & INTERACT_MACHINE_OPEN_SILICON))
			return FALSE

	if(silicon)
		if(!(interaction_flags_machine & INTERACT_MACHINE_ALLOW_SILICON))
			return FALSE
	else
		if(interaction_flags_machine & INTERACT_MACHINE_REQUIRES_SILICON)
			return FALSE
	return TRUE

////////////////////////////////////////////////////////////////////////////////////////////

//Return a non FALSE value to interrupt attack_hand propagation to subtypes.
/obj/machinery/interact(mob/user, special_state)
	if(interaction_flags_machine & INTERACT_MACHINE_SET_MACHINE)
		user.set_machine(src)
	. = ..()

/obj/machinery/ui_act(action, params)
	add_fingerprint(usr)
	return ..()

/obj/machinery/Topic(href, href_list)
	..()
	if(!can_interact(usr))
		return 1
	if(!usr.canUseTopic(src))
		return 1
	add_fingerprint(usr)
	return 0

////////////////////////////////////////////////////////////////////////////////////////////

/obj/machinery/attack_paw(mob/living/user)
	if(user.used_intent.type != INTENT_HARM)
		return attack_hand(user)
	else
		user.changeNext_move(CLICK_CD_MELEE)
//		user.do_attack_animation(src, ATTACK_EFFECT_PUNCH)
		user.visible_message("<span class='danger'>[user.name] smashes against \the [src.name] with its paws.</span>", null, null, COMBAT_MESSAGE_RANGE)
		take_damage(4, BRUTE, "melee", 1)

/obj/machinery/_try_interact(mob/user)
	if((interaction_flags_machine & INTERACT_MACHINE_WIRES_IF_OPEN) && panel_open)
		return TRUE
	return ..()

/obj/machinery/CheckParts(list/parts_list)
	..()
	RefreshParts()

/obj/machinery/proc/RefreshParts() //Placeholder proc for machines that are built using frames.
	return

/obj/machinery/proc/default_pry_open(obj/item/I)
	. = !(state_open || panel_open || is_operational() || (flags_1 & NODECONSTRUCT_1)) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		visible_message("<span class='notice'>[usr] pries open \the [src].</span>", "<span class='notice'>I pry open \the [src].</span>")
		open_machine()

/obj/machinery/proc/default_deconstruction_crowbar(obj/item/I, ignore_panel = 0)
	. = (panel_open || ignore_panel) && !(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_CROWBAR
	if(.)
		I.play_tool_sound(src, 50)
		deconstruct(TRUE)

/obj/machinery/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		on_deconstruction()
		if(component_parts && component_parts.len)
			for(var/obj/item/I in component_parts)
				I.forceMove(loc)
			component_parts.Cut()
	qdel(src)

/obj/machinery/obj_break(damage_flag)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(!(stat & BROKEN) && !(flags_1 & NODECONSTRUCT_1))
		stat |= BROKEN
		SEND_SIGNAL(src, COMSIG_MACHINERY_BROKEN, damage_flag)
		update_icon()
		return TRUE

/obj/machinery/contents_explosion(severity, target)
	if(occupant)
		occupant.ex_act(severity, target)

/obj/machinery/handle_atom_del(atom/A)
	if(A == occupant)
		occupant = null
		update_icon()
		updateUsrDialog()

/obj/machinery/proc/default_deconstruction_screwdriver(mob/user, icon_state_open, icon_state_closed, obj/item/I)
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_SCREWDRIVER)
		I.play_tool_sound(src, 50)
		if(!panel_open)
			panel_open = TRUE
			icon_state = icon_state_open
			to_chat(user, "<span class='notice'>I open the maintenance hatch of [src].</span>")
		else
			panel_open = FALSE
			icon_state = icon_state_closed
			to_chat(user, "<span class='notice'>I close the maintenance hatch of [src].</span>")
		return TRUE
	return FALSE

/obj/machinery/proc/default_change_direction_wrench(mob/user, obj/item/I)
	if(panel_open && I.tool_behaviour == TOOL_WRENCH)
		I.play_tool_sound(src, 50)
		setDir(turn(dir,-90))
		to_chat(user, "<span class='notice'>I rotate [src].</span>")
		return 1
	return 0

/obj/proc/can_be_unfasten_wrench(mob/user, silent) //if we can unwrench this object; returns SUCCESSFUL_UNFASTEN and FAILED_UNFASTEN, which are both TRUE, or CANT_UNFASTEN, which isn't.
	if(!(isfloorturf(loc)) && !anchored)
		to_chat(user, "<span class='warning'>[src] needs to be on the floor to be secured!</span>")
		return FAILED_UNFASTEN
	return SUCCESSFUL_UNFASTEN

/obj/proc/default_unfasten_wrench(mob/user, obj/item/I, time = 20) //try to unwrench an object in a WONDERFUL DYNAMIC WAY
	if(!(flags_1 & NODECONSTRUCT_1) && I.tool_behaviour == TOOL_WRENCH)
		var/can_be_unfasten = can_be_unfasten_wrench(user)
		if(!can_be_unfasten || can_be_unfasten == FAILED_UNFASTEN)
			return can_be_unfasten
		if(time)
			to_chat(user, "<span class='notice'>I begin [anchored ? "un" : ""]securing [src]...</span>")
		I.play_tool_sound(src, 50)
		var/prev_anchored = anchored
		//as long as we're the same anchored state and we're either on a floor or are anchored, toggle our anchored state
		if(I.use_tool(src, user, time, extra_checks = CALLBACK(src, PROC_REF(unfasten_wrench_check), prev_anchored, user)))
			to_chat(user, "<span class='notice'>I [anchored ? "un" : ""]secure [src].</span>")
			setAnchored(!anchored)
			playsound(src, 'sound/blank.ogg', 50, TRUE)
			SEND_SIGNAL(src, COMSIG_OBJ_DEFAULT_UNFASTEN_WRENCH, anchored)
			return SUCCESSFUL_UNFASTEN
		return FAILED_UNFASTEN
	return CANT_UNFASTEN

/obj/proc/unfasten_wrench_check(prev_anchored, mob/user) //for the do_after, this checks if unfastening conditions are still valid
	if(anchored != prev_anchored)
		return FALSE
	if(can_be_unfasten_wrench(user, TRUE) != SUCCESSFUL_UNFASTEN) //if we aren't explicitly successful, cancel the fuck out
		return FALSE
	return TRUE

/obj/machinery/proc/display_parts(mob/user)
	. = list()
	. += "<span class='notice'>It contains the following parts:</span>"
	for(var/obj/item/C in component_parts)
		. += "<span class='notice'>[icon2html(C, user)] \A [C].</span>"
	. = jointext(., "")

/obj/machinery/examine(mob/user)
	. = ..()
	if(!(resistance_flags & INDESTRUCTIBLE))
		if(max_integrity)
			var/healthpercent = (obj_integrity/max_integrity) * 100
			switch(healthpercent)
				if(50 to 99)
					. += "It looks slightly damaged."
				if(25 to 50)
					. += "It appears heavily damaged."
				if(0 to 25)
					. += "<span class='warning'>It's falling apart!</span>"
//	if(user.research_scanner && component_parts)
//		. += display_parts(user, TRUE)

//called on machinery construction (i.e from frame to machinery) but not on initialization
/obj/machinery/proc/on_construction()
	return

//called on deconstruction before the final deletion
/obj/machinery/proc/on_deconstruction()
	return

/obj/machinery/proc/can_be_overridden()
	. = 1

/obj/machinery/Exited(atom/movable/AM, atom/newloc)
	. = ..()
	if (AM == occupant)
		occupant = null

/obj/machinery/proc/adjust_item_drop_location(atom/movable/AM)	// Adjust item drop location to a 3x3 grid inside the tile, returns slot id from 0 to 8
	var/md5 = md5(AM.name)										// Oh, and it's deterministic too. A specific item will always drop from the same slot.
	for (var/i in 1 to 32)
		. += hex2num(md5[i])
	. = . % 9
	AM.pixel_x = -8 + ((.%3)*8)
	AM.pixel_y = -8 + (round( . / 3)*8)

/obj/machinery/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM) && !AM.throwing)
		var/mob/living/user = AM
		if(climb_offset)
			user.set_mob_offsets("structure_climb", _x = 0, _y = climb_offset)

/obj/machinery/Uncrossed(atom/movable/AM)
	. = ..()
	if(isliving(AM) && !AM.throwing)
		var/mob/living/user = AM
		if(climb_offset)
			user.reset_offsets("structure_climb")

/obj/machinery/MouseDrop_T(atom/movable/O, mob/user)
	. = ..()
	if(!climbable)
		return
	if(user == O && isliving(O))
		var/mob/living/L = O
		if(isanimal(L))
			var/mob/living/simple_animal/A = L
			if (!A.dextrous)
				return
		if(L.mobility_flags & MOBILITY_MOVE)
			climb_structure(user)
			return
	if(!istype(O, /obj/item) || user.get_active_held_item() != O)
		return
	if(!user.dropItemToGround(O))
		return
	if (O.loc != src.loc)
		step(O, get_dir(O, src))

/obj/machinery/proc/do_climb(atom/movable/A)
	if(climbable)
		density = FALSE
		. = step(A,get_dir(A,src.loc))
		density = TRUE

/obj/machinery/proc/climb_structure(mob/living/user)
	src.add_fingerprint(user)
	var/adjusted_climb_time = climb_time
	if(user.restrained()) //climbing takes twice as long when restrained.
		adjusted_climb_time *= 2
	if(HAS_TRAIT(user, TRAIT_FREERUNNING)) //do you have any idea how fast I am???
		adjusted_climb_time *= 0.8
	adjusted_climb_time -= user.STASPD * 2
	adjusted_climb_time = max(adjusted_climb_time, 0)
//	if(adjusted_climb_time)
//		user.visible_message("<span class='warning'>[user] starts climbing onto [src].</span>", "<span class='warning'>I start climbing onto [src]...</span>")
	structureclimber = user
	if(do_mob(user, user, adjusted_climb_time))
		if(src.loc) //Checking if structure has been destroyed
			if(do_climb(user))
				user.visible_message("<span class='warning'>[user] climbs onto [src].</span>", \
									"<span class='notice'>I climb onto [src].</span>")
				log_combat(user, src, "climbed onto")
//				if(climb_offset)
//					user.set_mob_offsets("structure_climb", _x = 0, _y = climb_offset)
				if(climb_stun)
					user.Stun(climb_stun)
				if(climb_sound)
					playsound(src, climb_sound, 100)
				. = 1
			else
				to_chat(user, "<span class='warning'>I fail to climb onto [src].</span>")
	structureclimber = null
