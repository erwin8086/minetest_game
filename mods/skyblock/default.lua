local ores = {
	["default:coal_lump"]=5,
	["default:iron_lump"]=10,
	["default:copper_lump"]=15,
	["default:mese_crystal"]=50,
	["default:gold_lump"]=60,
	["default:diamond"]=80,
}

function skyblock.register_ore(name, chance)
	if not name or not chance then return end
	ores[name] = chance
end

magic.register_infusion("default:stone", {
	level = 0,
	type="earth",
	action = function(pos, player)
		minetest.remove_node(pos)
		local inv = player:get_inventory()
		for ore, chance in pairs(ores) do
			if math.random(chance)==1 and inv:room_for_item("main", ore) then
				inv:add_item("main", ore)
			end
		end
	end,
})

magic.register_transform("default:stone", {
	type="earth",
	output="default:desert_stone",
	mana = 0.5,
})

magic.register_transform("default:desert_stone", {
	type="earth",
	output="default:sandstone",
	mana = 0.5,
})

magic.register_recipe("earth", {
	output = "default:obsidian",
	recipe = {"default:stone", "default:stone", "default:stone",
			"default:stone", "default:sandstone", "default:desert_stone",
			"default:stone", "default:desert_stone", "default:sandstone"},
	mana = 0.5,
})

minetest.register_craft({
	type = "shapeless",
	output = "default:dirt_with_grass",
	recipe = { "default:dirt", "group:grass"} 
})

minetest.register_craft({
	type = "shapeless",
	output = "default:dirt_with_grass",
	recipe = { "default:dirt", "group:dry_grass"} 
})

minetest.register_craft({
	type = "shapeless",
	output = "default:dirt_with_snow",
	recipe = { "default:dirt", "default:snow"} 
})

magic.register_transform("default:sand", {
	type="earth",
	output="default:desert_sand",
	mana = 0.5,
})

magic.register_infusion("default:sand", {
	type="earth",
	output="default:gravel",
	mana = 0.5,
})

magic.register_transform("default:water_source", {
	type="water",
	output="default:ice",
	mana = 0.5,
})

magic.register_transform("default:ice", {
	type="water",
	output="default:snowblock",
	mana = 0.5,
})

magic.register_infusion("skyblock:dryleaves", {
	level = 1,
	output = "default:jungleleaves",
	mana = 0.5,
})

magic.register_transform("skyblock:jungleleaves", {
	level = 1,
	output = "acacia_leaves",
	mana = 0.5,
})

magic.register_transform("skyblock:acacia_levaes", {
	level = 1,
	output = "aspen_leaves",
	mana = 0.5,
})

magic.register_transform("default:aspen_leaves", {
	level = 1,
	output = "default:pine_needles",
	mana = 0.5,
})

magic.register_recipe("nature", {
	output = "default:papyrus",
	recipe = {"group:grass", "group:grass", nil,
			"group:grass", "default:sapling" },
	mana = 2.5,
})

magic.register_transform("default:papyrus", {
	output = "default:cactus",
	mana = 2.5,
	level = 1,
})

for i=1,5 do
	magic.register_transform("default:grass_"..i, {
		output = "default:junglegrass",
		mana = 1.5,
		level = 1,
	})
end

magic.register_infusion("default:water_source", {
	type = "water",
	level = 1,
	mana = 2,
	output = "default:river_water_source",
})

magic.register_recipe("water", {
	output = "default:lava_source",
	recipe = {"default:water_source", "default:cobble", nil,
			"cooking:basic_torch", "cooking:basic_torch"},
	mana = 3,
})

magic.register_transform("default:dirt", {
	action = function(pos, player)
		minetest.remove_node(pos)
		if math.random(3) == 1 then
			local inv = player:get_inventory()
			local stack = "default:cobble 5"
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		end
	end,
	level=1,
})

magic.register_transform("default:leaves", {
	output = "default:dirt",
	mana = 0.5,
})
magic.register_infusion("default:leaves", {
	output = "default:sapling",
})

magic.register_infusion("default:sapling", {
	action = function(pos, player)
		default.grow_tree(pos, true)
	end,
	mana = 2,
})

magic.register_transform("default:sapling", {
	action = function(pos, player)
		default.grow_tree(pos, false)
	end,
})