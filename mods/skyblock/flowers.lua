local reg_flowers = {"flowers:rose", "flowers:tulip", "flowers:dandelion_yellow", "flowers:geranium",
				"flowers:viola", "flowers:dandelion_white", "flowers:mushroom_brown", "mushroom_red" }

function skyblock.register_flower(name)
	if not name then return end
	reg_flowers[#reg_flowers+1] = name
	unified_inventory.register_craft({
		type="infusion",
		output=name,
		items = {"default:grass_5", "magic:simple_nature"},
	})
end

local function gen_flower(pos, player)
	minetest.swap_node(pos, {name=reg_flowers[math.random(#reg_flowers)]})
end

for i=1,5 do
	magic.register_infusion("default:grass_"..i, {
		mana = 2,
		level = 2,
		action = gen_flower,
	})
end

for _, name in ipairs(reg_flowers) do
	unified_inventory.register_craft({
		type="infusion",
		output=name,
		items = {"default:grass_5", "magic:simple_nature"},
	})
end