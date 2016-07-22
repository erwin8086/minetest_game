minetest.register_node("cooking:dryleaves", {
	description = "Dry Leaves",
	drawtype = "allfaces_optional",
	tiles = {"default_leaves.png^[colorize:#5C1F15"},
	groups = {snappy=3},
	paramtype = "light",
	drop = "",
})

cooking.register_recipe("default:leaves", "cooking:dryleaves", "default:water_source", 4)
cooking.register_fireplace_fuel("cooking:dryleaves", 4)

magic.register_transform("cooking:dryleaves", {
	output = "default:dry_shrub",
	level = 1,
	mana = 0.5,
})