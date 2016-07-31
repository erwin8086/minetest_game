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



magic.register_recipe("nature", {
	output = "default:sand",
	recipe = {"skyblock:dryleaves", "skyblock:dryleaves"}
})