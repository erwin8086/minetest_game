-- Sand near water to clay
minetest.register_abm({
	nodenames = {"default:sand"},
	neighbors = {"default:water_source", "default:water_flowing"},
	chance = 20,
	interval = 15,
	action = function(pos, node, active_object_count, active_object_count_wider)
		minetest.swap_node(pos, {name="default:clay"})
	end,
})