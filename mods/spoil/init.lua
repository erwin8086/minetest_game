spoil = {}
local spoilables = {}
local check_time = 5

minetest.after(0, function()
	for name, def in pairs(minetest.registered_items) do
		if (def.spoil or 0) > 0 then
			spoilables[name] = def.spoil
		end
	end
end)

local function check_list(inv, list)
	local l = inv:get_list(list)
	if not l then
		return
	end
	for i, item in ipairs(l) do
		local n = item:get_name()
		if spoilables[n] then
			local day = minetest.get_day_count()
			local meta = item:get_meta()
			local mhd = meta:get_int("mhd")
			if (mhd or 0) > 0 then
				mhd = mhd - day
				if mhd > 0 then
					meta:set_string("description", minetest.registered_items[n].description.."\nGood for "..tostring(mhd).." days")
				else
					item:clear()
				end
			else
				mhd = spoilables[n]
				meta:set_int("mhd", mhd + day)
				meta:set_string("description", minetest.registered_items[n].description.."\nGood for "..tostring(mhd).." days")
			end
			l[i] = item
		end
	end
	inv:set_list(list, l)
end

function spoil.register_inv(node, lists)
	local function check(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		for _, list in ipairs(lists) do
			check_list(inv, list)
		end	
	end
	minetest.register_abm({
		label = "spoil:inv_"..node,
		nodenames = {node},
		interval = check_time,
		chance   = 2,
		catch_up=false,
		action = check,
	})
	minetest.register_lbm({
		name = ":spoil:inv_"..node:gsub(":", "_"),
		nodenames = {node},
		run_at_every_load=true,
		action = check,
	})
end

local player_inv = {"main", "bag1contents", "bag2contents", "bag3contents","bag4contents"}
local time = 0
local list_player
minetest.register_globalstep(function(dtime)
	time = time + dtime
	if time > check_time then
		time = 0
		if list_player and #list_player > 0 then
			local player = list_player[#list_player]
			list_player[#list_player] = nil
			local inv = player:get_inventory()
			for _, list in ipairs(player_inv) do
				check_list(inv, list)
			end
		else
			list_player = minetest.get_connected_players()
		end
	end
end)
