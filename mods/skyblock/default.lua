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