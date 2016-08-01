unified_inventory.register_craft({
	type="transform",
	output="magic:simple_nature",
	items = {"default:leaves 12", "default:stick"},
})

magic.register_transform("default:apple", {
	mana = 0.25,
	action = function(pos, player)
		minetest.remove_node(pos)
		if math.random(5) == 1 then
			local inv = player:get_inventory()
			local stack = ItemStack("magic:better_nature")
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		end
	end
})

unified_inventory.register_craft({
	type="transform",
	output="magic:better_nature",
	items = {"default:apple 5", "magic:simple_nature"},
})

magic.register_transform("farming:wheat_8", {
	mana = 1,
	level = 1,
	action = function(pos, player)
		minetest.remove_node(pos)
		if math.random(5) == 1 then
			local inv = player:get_inventory()
			local stack = ItemStack("magic:good_nature")
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		end
	end,
})

unified_inventory.register_craft({
	type="transform",
	output="magic:good_nature",
	items = {"farming:wheat_8 5", "magic:simple_nature"},
})

magic.register_recipe("nature", {
	output = "magic:simple_earth",
	recipe = { "default:stone", "default:stone", "default:stone",
				"default:stone", "magic:better_nature", "default:stone",
				"default:stone", "default:stone", "default:stone" },
	mana = 5,
})

magic.register_infusion("default:coalblock", {
	type="earth",
	mana = 5,
	action = function(pos, player)
		local inv = player:get_inventory()
		local new = ItemStack("magic:better_earth")
		if inv:room_for_item("main", new) then
			inv:add_item("main", new)
			minetest.remove_node(pos)
		end
	end,
})

unified_inventory.register_craft({
	type="infusion",
	output="magic:better_earth",
	items = {"default:coalblock", "magic:simple_earth"},
})


magic.register_infusion("default:diamondblock", {
	type="earth",
	mana = 5,
	level = 1,
	action = function(pos, player)
		local inv = player:get_inventory()
		local new = ItemStack("magic:good_earth")
		if inv:room_for_item("main", new) then
			inv:add_item("main", new)
			minetest.remove_node(pos)
		end
	end,
})

unified_inventory.register_craft({
	type="infusion",
	output="magic:good_earth",
	items = {"default:diamondblock", "magic:simple_earth"},
})

magic.register_recipe("nature", {
	output = "magic:simple_water",
	mana = 5,
	recipe = { "default:water_source", "default:water_source", "default:water_source",
				"default:water_source", "magic:good_nature", "default:water_source", 
				"default:water_source", "default:water_source", "default:water_source" },
})

magic.register_infusion("default:ice", {
	type="water",
	mana = 5,
	level = 0,
	action = function(pos, player)
		minetest.remove_node(pos)
		if math.random(5) ~= 1 then return end
		local inv = player:get_inventory()
		local new = ItemStack("magic:better_water")
		if inv:room_for_item("main", new) then
			inv:add_item("main", new)
		end
	end,
})

unified_inventory.register_craft({
	type="infusion",
	output="magic:better_water",
	items = {"default:ice 5", "magic:simple_water"},
})

magic.register_infusion("default:papyrus", {
	type="water",
	mana = 5,
	level = 1,
	action = function(pos, player)
		minetest.remove_node(pos)
		if math.random(5) ~= 1 then return end
		local inv = player:get_inventory()
		local new = ItemStack("magic:good_water")
		if inv:room_for_item("main", new) then
			inv:add_item("main", new)
		end
	end,
})

unified_inventory.register_craft({
	type="infusion",
	output="magic:good_water",
	items = {"default:papyrus 5", "magic:simple_earth"},
})


magic.register_recipe("nature", {
	output = "default:sand",
	recipe = {"skyblock:dryleaves", "skyblock:dryleaves"}
})