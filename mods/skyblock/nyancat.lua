nyancat.generate = function() end

magic.register_infusion("default:diamondblock", {
	level = 2,
	type = "earth",
	mana = 200,
	output = "nyancat:nyancat",	
})

magic.register_transform("nyancat:nyancat", {
	level = 2,
	type="earth",
	mana = 20,
	action = function(pos, player)
		local new = ItemStack("nyancat:nyancat_rainbow 10")
		local inv = player:get_inventory()
		if inv:room_for_item("main", new) then
			inv:add_item("main", new)
			minetest.remove_node(pos)
		else
			minetest.swap_node(pos, {name="nyancat:nyancat_rainbow"})
		end
	end
})