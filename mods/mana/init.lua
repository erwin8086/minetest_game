local utils = {
	["mana:simple_storage"] = {action="store", value=2},
	["mana:simple_healer"] = {action="healer", value=3},
	["mana:better_storage"] = {action="store", value=3},
	["mana:better_healer"] = {action="healer", value=2},
	["mana:good_storage"] = {action="store", value=4},
	["mana:good_healer"] = {action="healer", value=1},
	["mana:night_keeper"] = {action="keeper", value=1},
	["mana:night_healer"] = {action="keeper", value=2},
}

local old_tick = bars.mana_tick
function bars.mana_tick(time, player, name)
	local inv = player:get_inventory()
	local mana = inv:get_list("mana")
	local store = 1
	local heal = 4
	local keep=false
	local keep_heal=1
	for _, stack in ipairs(mana) do
		if not stack:is_empty() then
			local n = stack:get_name()
			local util = utils[n]
			if util then
				if util.action == "store" then
					store = util.value
				elseif util.action == "healer" then
					heal = util.value
				elseif util.action == "keeper" then
					keep=true
					keep_heal=util.value
				end
			end
		end
	end
	bars.stat[name].mmana = store
	if keep and not (time >= 5500 and time <= 18500) then
		bars.stat[name].mana = bars.stat[name].mana + (bars.MAX_MANA/20)*keep_heal
	end
	local node = minetest.get_node(player:getpos())
	if node.name == "cooking:basic_torch" then
		bars.stat[name].mana = bars.stat[name].mana + (bars.MAX_MANA/20)*3
	end
	old_tick(time, player, name)
	return heal
end

minetest.register_on_joinplayer(function(player)
	local inv = player:get_inventory()
	inv:set_size("mana", 6)
end)

minetest.register_on_respawnplayer(function(player)
	local inv = player:get_inventory()
	inv:set_list("mana", {})
end)

unified_inventory.register_page("mana", {
	get_formspec = function(player, perplayer_formspec)
		return {formspec="list[current_player;mana;1,1;2,3]"}
	end
})

unified_inventory.register_button("mana", {
	type="image",
	image="bars_mana.png",
	tooltip = "Mana Utils",
})

minetest.register_craftitem("mana:simple_storage", {
	description = "Simple Storage for Mana",
	inventory_image="default_leaves.png^(default_stick.png^magic_simple_nature.png)",
})


minetest.register_craftitem("mana:better_healer", {
	description = "Simple Healer for Mana",
	inventory_image="default_wood.png^(default_stick.png^magic_simple_nature.png)",
})

minetest.register_craftitem("mana:better_storage", {
	description = "Better Storage for Mana",
	inventory_image="default_leaves.png^(default_stick.png^magic_better_nature.png)",
})


minetest.register_craftitem("mana:good_healer", {
	description = "Good Healer for Mana",
	inventory_image="default_wood.png^(default_stick.png^magic_good_nature.png)",
})

minetest.register_craftitem("mana:good_storage", {
	description = "Good Storage for Mana",
	inventory_image="default_leaves.png^(default_stick.png^magic_good_nature.png)",
})


minetest.register_craftitem("mana:simple_healer", {
	description = "Better Healer for Mana",
	inventory_image="default_wood.png^(default_stick.png^magic_better_nature.png)",
})

minetest.register_craftitem("mana:night_keeper", {
	description = "Keeps mana at night",
	inventory_image="default_steel_block.png^(default_stick.png^magic_better_earth.png)",
})

minetest.register_craftitem("mana:night_healer", {
	description = "Heals mana at night",
	inventory_image="default_gold_block.png^(default_stick.png^magic_good_earth.png)",
})