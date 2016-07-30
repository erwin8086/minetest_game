unified_inventory.register_craft_type("sticks_byproduct", {
	description = "Cooking Sticks byproduct",
	icon = "default_stick.png",
	width = 1,
	height = 1,
})

unified_inventory.register_craft_type("sticks", {
	description = "Cooking Sticks",
	icon = "default_stick.png",
	width = 1,
	height = 1,
})

for input, def in pairs(cooking.get_recipes()) do
	print("Register "..def[1])
	unified_inventory.register_craft({
		type="sticks",
		output = def[1],
		items = {input},
	})
	if def[2] then
		unified_inventory.register_craft({
			type="sticks_byproduct",
			output = def[2],
			items = {input},
		})
	end
end
local rod = {["nature"] = "magic:simple_nature", ["earth"] = "magic:simple_earth", ["water"] = "magic:simple_water"},

unified_inventory.register_craft_type("transform", {
	description = "Magic Transform",
	icon = "default_stick.png^magic_simple_nature.png",
	width = 1,
	height = 2,
})

for node, def in pairs(magic.trans) do
	if def.output then
		unified_inventory.register_craft({
			type="transform",
			output = def.output,
			items = {node, rod[def.type]},
		})
	end
end

unified_inventory.register_craft_type("infusion", {
	description = "Magic Infusion",
	icon = "default_stick.png^magic_simple_nature.png",
	width = 1,
	height = 2,
})

for node, def in pairs(magic.inf) do
	if def.output then
		unified_inventory.register_craft({
			type="infusion",
			output = def.output,
			items = {node, rod[def.type]},
		})
	end
end
for t, _ in pairs(rod) do
	unified_inventory.register_craft_type("project_"..t, {
		description = "Magic "..t.." Project",
		icon = "default_stick.png^magic_simple_"..t..".png",
		width = 3,
		height = 3,
	})
end

for t, recipes in pairs(magic.get_project_recipes()) do
	for _, def in ipairs(recipes) do
		unified_inventory.register_craft({
			type="project_"..t,
			output = def.output,
			items = def.recipe
		})
	end
end