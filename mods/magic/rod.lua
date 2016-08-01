magic.register_rod("magic:simple_nature", {
	description = "Simple Nature Rod uses energy from Leaves",
	image="default_stick.png^magic_simple_nature.png",
})

magic.register_rod("magic:better_nature", {
	description = "Better Nature Rod uses energy from Apples",
	image="default_stick.png^magic_better_nature.png",
	level=1,
	uses = 500,
	mana = 2,
})

magic.register_rod("magic:good_nature", {
	description = "Good Nature Rod uses energy from Wheat",
	image="default_stick.png^magic_good_nature.png",
	level=2,
	uses = 300,
	mana = 1,
})

magic.register_rod("magic:simple_earth", {
	description = "Simple Earth Rod uses energy from Stone",
	image="default_stick.png^magic_simple_earth.png",
	type="earth",
})

magic.register_rod("magic:better_earth", {
	description = "Better Earth Rod uses energy from Coal",
	image="default_stick.png^magic_better_earth.png",
	type="earth",
	level=1,
	uses = 500,
	mana = 2,
})

magic.register_rod("magic:good_earth", {
	description = "Good Earth Rod uses energy from Diamond",
	image="default_stick.png^magic_good_earth.png",
	type="earth",
	level=2,
	uses = 300,
	mana = 1,
})

magic.register_rod("magic:simple_water", {
	description = "Simple Water Rod uses energy from Water",
	image="default_stick.png^magic_simple_water.png",
	type="water",
	liquids_pointable = true,
})

magic.register_rod("magic:better_water", {
	description = "Better Water Rod uses energy from Ice",
	image="default_stick.png^magic_better_water.png",
	type="water",
	level=1,
	uses = 500,
	mana = 2,
	liquids_pointable = true,
})

magic.register_rod("magic:good_water", {
	description = "Good Water Rod uses energy from Papyrus",
	image="default_stick.png^magic_good_water.png",
	type="water",
	level=2,
	uses = 300,
	mana = 1,
	liquids_pointable = true,
})
