// simple is_type and similar inline helpers


#define in_range(source, user) (get_dist(source, user) <= 1 && (get_step(source, 0)?:z) == (get_step(user, 0)?:z))

#define ismovableatom(A) ismovable(A)


#define isatom(A) (isloc(A))

#define isweakref(D) (istype(D, /datum/weakref))

#define isdatum(D) (istype(D, /datum))
//Turfs
//#define isturf(A) (istype(A, /turf)) This is actually a byond built-in. Added here for completeness sake.

GLOBAL_LIST_INIT(turfs_without_ground, typecacheof(list(
	/turf/open/lava,
	/turf/open/water,
	/turf/open/transparent/openspace
	)))

GLOBAL_LIST_INIT(our_forest_sex, typecacheof(list(
	/area/rogue/outdoors/woods,
	/area/rogue/indoors/shelter/woods,
	/area/rogue/outdoors/river,
	/area/rogue/outdoors/bog,
	/area/rogue/indoors/shelter/bog,
	/area/rogue/outdoors/rtfield,
	/area/rogue/indoors/shelter/rtfield
	)))

#define isforestsex(A) (is_type_in_typecache(A, GLOB.our_forest_sex))

#define isgroundlessturf(A) (is_type_in_typecache(A, GLOB.turfs_without_ground))

#define isopenturf(A) (istype(A, /turf/open))

#define isindestructiblefloor(A) (istype(A, /turf/open/indestructible))

#define isfloorturf(A) (istype(A, /turf/open/floor))

#define isclosedturf(A) (istype(A, /turf/closed))

#define isindestructiblewall(A) (istype(A, /turf/closed/indestructible))

#define iswallturf(A) (istype(A, /turf/closed/wall))

#define ismineralturf(A) (istype(A, /turf/closed/mineral))

#define islava(A) (istype(A, /turf/open/lava))

#define ischasm(A) (istype(A, /turf/open/chasm))

#define isplatingturf(A) (istype(A, /turf/open/floor/plating))

#define istransparentturf(A) (istype(A, /turf/open/transparent) || istype(A, /turf/closed/transparent))

//Mobs
#define isliving(A) (istype(A, /mob/living))

#define isbrain(A) (istype(A, /mob/living/brain))

//Carbon mobs
#define iscarbon(A) (istype(A, /mob/living/carbon))

#define ishuman(A) (istype(A, /mob/living/carbon/human))

//Human sub-species
#define isabductor(A) (is_species(A, /datum/species/abductor))
#define isgolem(A) (is_species(A, /datum/species/golem))
#define islizard(A) (is_species(A, /datum/species/lizard))
#define isplasmaman(A) (is_species(A, /datum/species/plasmaman))
#define ispodperson(A) (is_species(A, /datum/species/pod))
#define isflyperson(A) (is_species(A, /datum/species/fly))
#define isjellyperson(A) (is_species(A, /datum/species/jelly))
#define isslimeperson(A) (is_species(A, /datum/species/jelly/slime))
#define isluminescent(A) (is_species(A, /datum/species/jelly/luminescent))
#define iszombie(A) (is_species(A, /datum/species/zombie))
#define isskeleton(A) (is_species(A, /datum/species/skeleton))
#define ismoth(A) (is_species(A, /datum/species/moth))
#define ishumanbasic(A) (is_species(A, /datum/species/human))
#define isfelinid(A) (is_species(A, /datum/species/human/felinid))
#define isethereal(A) (is_species(A, /datum/species/ethereal))
#define isvampire(A) (is_species(A,/datum/species/vampire))

//RT species
#define ishumannorthern(A) (is_species(A, /datum/species/human/northern))
#define isdwarf(A) (is_species(A, /datum/species/dwarf))
#define isdwarfmountain(A) (is_species(A, /datum/species/dwarf/mountain))
#define iself(A) (is_species(A, /datum/species/elf))
#define isdarkelf(A) (is_species(A, /datum/species/elf/dark))
#define issnowelf(A) (is_species(A, /datum/species/elf/snow))
#define ishalfelf(A) (is_species(A, /datum/species/human/halfelf))
#define istiefling(A) (is_species(A, /datum/species/tieberian))

//more carbon mobs
#define ismonkey(A) (istype(A, /mob/living/carbon/monkey))

#define istruedevil(A) (istype(A, /mob/living/carbon/true_devil))

//Simple animals
#define isanimal(A) (istype(A, /mob/living/simple_animal))

#define isshade(A) (istype(A, /mob/living/simple_animal/shade))

#define ismouse(A) (istype(A, /mob/living/simple_animal/mouse))

#define iscow(A) (istype(A, /mob/living/simple_animal/cow))

#define iscat(A) (istype(A, /mob/living/simple_animal/pet/cat))

#define isdog(A) (istype(A, /mob/living/simple_animal/pet/dog))

#define iscorgi(A) (istype(A, /mob/living/simple_animal/pet/dog/corgi))

#define ishostile(A) (istype(A, /mob/living/simple_animal/hostile))

#define isclown(A) (istype(A, /mob/living/simple_animal/hostile/retaliate/clown))


//Misc mobs
#define isobserver(A) (istype(A, /mob/dead/observer))

#define isdead(A) (istype(A, /mob/dead))

#define isnewplayer(A) (istype(A, /mob/dead/new_player))

#define isovermind(A) (istype(A, /mob/camera/blob))

#define iscameramob(A) (istype(A, /mob/camera))

#define isaicamera(A) (istype(A, /mob/camera/aiEye))

//Objects
#define isobj(A) istype(A, /obj) //override the byond proc because it returns true on children of /atom/movable that aren't objs

#define isitem(A) (istype(A, /obj/item))

#define isidcard(I) (istype(I, /obj/item/card/id))

#define isstructure(A) (istype(A, /obj/structure))

#define ismachinery(A) (istype(A, /obj/machinery))

#define is_cleanable(A) (istype(A, /obj/effect/decal/cleanable)) //if something is cleanable

#define isorgan(A) (istype(A, /obj/item/organ))

#define isclothing(A) (istype(A, /obj/item/clothing))

#define iscash(A) (istype(A, /obj/item/stack/spacecash) || istype(A, /obj/item/holochip))

GLOBAL_LIST_INIT(pointed_types, typecacheof(list(
	/obj/item/kitchen/fork)))

#define is_pointed(W) (is_type_in_typecache(W, GLOB.pointed_types))

#define isbodypart(A) (istype(A, /obj/item/bodypart))

#define isprojectile(A) (istype(A, /obj/projectile))

#define isgun(A) (istype(A, /obj/item/gun))


#define iseffect(O) (istype(O, /obj/effect))

#define isblobmonster(O) (istype(O, /mob/living/simple_animal/hostile/blob))

#define isshuttleturf(T) (length(T.baseturfs) && (/turf/baseturf_skipover/shuttle in T.baseturfs))

GLOBAL_LIST_INIT(RATS_DONT_EAT, typecacheof(list(
	/obj/item/reagent_containers/food/snacks/smallrat,
	/obj/item/reagent_containers/food/snacks/produce/onion,
	/obj/item/reagent_containers/food/snacks/produce/jacksberry/poison
	)))
