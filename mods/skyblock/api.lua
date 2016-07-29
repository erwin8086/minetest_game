local old_craft = minetest.register_craft

function minetest.register_craft(def)
	if def and def.type then
		local t = def.type
		if t == "transform" then
			local trans = {}
			trans.type = def.rod
			trans.level = def.level
			trans.output = def.output
			trans.action = def.action
			trans.mana = def.mana
			trans.level = def.level
			magic.register_transform(def.node, trans)
			return
		elseif t == "infusion" then
			local inf = {}
			inf.type = def.rod
			inf.level = def.level
			inf.output = def.output
			inf.mana = def.mana
			inf.level = def.level
			magic.register_infusion(def.node, inf)
			return
		elseif t == "magic" then
			local m = {}
			m.output = def.output
			m.recipe = def.recipe
			m.mana = def.mana
			magic.register_recipe(def.rod, m)
			return
		elseif t == "sticks" then
			cooking.register_recipe(def.input, def.output, def.byproduct, def.time)
			return
		end
	end
	return old_craft(def)
end

skyblock.use_mana = bars.use_mana