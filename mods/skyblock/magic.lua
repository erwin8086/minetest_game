magic.register_transform("skyblock:dryleaves", {
	output = "default:dry_shrub",
	level = 1,
	mana = 0.5,
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

magic.register_transform("default:apple", {
	mana = 0.25,
	action = function(pos, player)
		minetest.remove_node(pos)
		if math.random(5) == 1 then
			local inv = player:get_inventory()
			stack = ItemStack("magic:better_nature")
			if inv:room_for_item("main", stack) then
				inv:add_item("main", stack)
			end
		end
	end
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

magic.register_transform("default:dry_shrub", {
	level=1,
	output = "default:dry_grass_1",
})
for i=1,5 do
	magic.register_infusion("default:dry_grass_"..i, {
		level=1,
		output = "default:grass_"..i
	})
end

magic.register_recipe("nature", {
	output = "default:sand",
	recipe = {"skyblock:dryleaves", "skyblock:dryleaves"}
})