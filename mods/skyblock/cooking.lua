cooking.register_recipe("default:leaves", "skyblock:dryleaves", "default:water_source", 4)
cooking.register_fireplace_fuel("skyblock:dryleaves", 4)
cooking.register_recipe("default:clay_lump", "default:clay_brick", nil, 20)
minetest.register_craft({
	output = "cooking:firebox_close",
	recipe = {
		{"default:clay_brick", "default:clay_brick", "default:clay_brick"},
		{"default:clay_brick", "default:stick", "default:clay_brick"},
		{"default:clay_brick", "default:clay_brick", "default:clay_brick"}
	}
})

minetest.register_craft({
	output = "cooking:smelter_close",
	recipe = {
		{"default:clay_brick", "default:clay_brick", "default:clay_brick"},
		{"default:clay_brick", "", "default:clay_brick"},
		{"default:clay_brick", "default:clay_brick", "default:clay_brick"}
	}
})

minetest.register_craft({
	output = "cooking:basic_lighter 10",
	recipe = {
		{"default:stick"},
		{"default:wood"}	
	}
})

minetest.register_craft({
	output = "cooking:stick",
	recipe = {
		{"", "default:stick", ""},
		{"default:stick", "", "default:stick"},
		{"default:stick", "", "default:stick"}
	}
})