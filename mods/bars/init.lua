--[[
	Hud Bars [bars]
	Displays bars for water, food, energy and mana
	Add sprinting and water glass.
	Makes food useable for regen food bar.
	By erwin8086: WTFPL
]]

bars = {}
bars.stat = {}
bars.hud  = {}
local save = minetest.get_worldpath().."/bars"

if minetest.setting_getbool("enable_damage") ~= true then
	bars.use_mana = function() return true end
	return
end

local function load_stat(name)
	minetest.mkdir(save)
	local f = io.open(save.."/"..name, "r")
	local stat = {}
	if f then
		stat = minetest.deserialize(f:read("*all"))
		f:close()
		if not stat then stat = {} end
	end
	stat.food = stat.food or 20
	stat.mana = stat.mana or 20
	stat.water = stat.water or 20
	stat.energy = stat.energy or 20
	stat.mmana = stat.mmana or 1
	bars.stat[name] = stat
end

local function save_stat(name)
	minetest.mkdir(save)
	local stat = bars.stat[name]
	if not stat then
		stat = {}
	end
	stat.food = stat.food or 20
	stat.mana = stat.mana or 20
	stat.water = stat.water or 20
	stat.energy = stat.energy or 20
	stat.mmana = stat.mmana or 1
	local f = io.open(save.."/"..name, "w")
	if f then
		f:write(minetest.serialize(bars.stat[name]))
		f:close()
	end
	
end

local function update_bars(player, name)
	if player and name then
		local hud = bars.hud[name]
		local stat = bars.stat[name]
		if not hud then
			hud = {}
			bars.hud[name] = hud
		end
		if not stat then
			stat = {}
			bars.stat[name] = stat
		end
		if hud.food and hud.water and hud.energy and hud.mana and stat then
			-- Minimal value
			if (stat.food or -1) < 0 then stat.food = 0 end
			if (stat.water or -1) < 0 then stat.water = 0 end
			if (stat.energy or -1) < 0 then stat.energy = 0 end
			if (stat.mana or -1) < 0 then stat.mana = 0 end
			-- Maximial value
			if (stat.food or 21) > 20 then stat.food = 20 end
			if (stat.water or 21) > 20 then stat.water = 20 end
			if (stat.energy or 21) > 20 then stat.energy = 20 end
			if (stat.mana or 21) > 20 then stat.mana = 20 end
			
			player:hud_change(hud.water, "number", bars.stat[name].water or 20)
			player:hud_change(hud.food, "number", bars.stat[name].food or 20 )
			player:hud_change(hud.mana, "number", bars.stat[name].mana or 20 )
			player:hud_change(hud.energy, "number", bars.stat[name].energy or 20 )
			
			save_stat(name)
		end
	end
end

local food = 0
local mana = 0
minetest.register_globalstep(function(dtime)
	food = food + dtime
	if food > 5 then
		food = 0
		for _, player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if name then
				if not bars.stat[name] then return end
				-- Consume energy
				if (math.random(14) == 1 and bars.stat[name].food > 0 and bars.stat[name].water > 0) or
						(math.random(4) == 1 and bars.stat[name].food > 15 and bars.stat[name].water > 15) then
					if bars.stat[name].energy < 20 then
						bars.stat[name].energy = (bars.stat[name].energy or 0) + 3
						if bars.stat[name].energy > 20 then bars.stat[name].energy = 20 end
						update_bars(player, name)
					end
				end
				
				-- Consume food and water
				if math.random(40) == 1 or (bars.stat[name].energy < 20 and math.random(15) == 1) then
					bars.stat[name].food = bars.stat[name].food - 1
					update_bars(player, name)
				elseif math.random(30) == 1 or (bars.stat[name].energy < 20 and math.random(10) == 1) then
					bars.stat[name].water = bars.stat[name].water - 1
					update_bars(player, name)
				end

				-- Use Energy for work
				local c = player:get_player_control()
				if ( c.jump or c.up or c.LMB or c.RMB ) and math.random(2) == 1 then
					bars.stat[name].energy = (bars.stat[name].energy or 0) - 1
					update_bars(player, name)
				end
				
				-- Set Speed
				if c.aux1 and (bars.stat[name].energy or 0) > 3 then
					bars.stat[name].energy = bars.stat[name].energy - 1
					player:set_physics_override({
						speed = 1.5
					})
				elseif (bars.stat[name].energy or 0) > 0 then
					player:set_physics_override({
						speed = 1
					})
				else
					player:set_physics_override({
						speed = 0.1
					})
				end
				
				-- Regen Healt
				if bars.stat[name].energy > 15 and bars.stat[name].water > 15 and
					bars.stat[name].food > 15 and math.random(2) == 1 then
					local hp = player:get_hp()
					if hp < 20 then
						player:set_hp(hp+1)
					end
				end
				
				-- Starve if no water or food
				if bars.stat[name].water <= 0 or bars.stat[name].food <= 0 then
					local hp = player:get_hp()
					if hp >= 2 then
						player:set_hp(hp-1)
					end
				end
			end
		end
	end
	
	mana = mana + dtime
	if mana > 30 then
		mana = 0
		local time = minetest.get_timeofday()*24000
		for _, player in ipairs(minetest.get_connected_players()) do
			local name = player:get_player_name()
			if not name then return end
			if not bars.stat[name] then return end
			if time > 5500 and time < 18500 then
				if bars.stat[name].mana < 20 then
					bars.stat[name].mana = bars.stat[name].mana + 1
					update_bars(player, name)
				end
			else
				if bars.stat[name].mana > 0 then
					bars.stat[name].mana = bars.stat[name].mana - 1
					update_bars(player, name)
				end
			end
		end
	end
end)

minetest.register_on_dignode(function(pos, oldnode, digger)
	if not digger then return end
	if math.random(10) == 1 then
		if not digger:is_player() then return end
		local name = digger:get_player_name()
		if not name then return end
		if not bars.stat[name] then return end
		bars.stat[name].energy = bars.stat[name].energy - 1
		update_bars(digger, name)
	end
end)

minetest.register_on_craft(function(stack, player, old, inv)
	if not player then return end
	local name = player:get_player_name()
	if not name then return end
	if not bars.stat[name] then return end
	bars.stat[name].energy = (bars.stat[name].energy or 0) - 1
end)

minetest.register_on_joinplayer(function(player)
	if not player then return end
	local name = player:get_player_name()
	if not name then return end
	load_stat(name)
	minetest.after(2, function()
		bars.hud[name] = {}
		bars.hud[name].food = player:hud_add({
			hud_elem_type = "statbar",
			position = {x=0, y=0},
			size = "",
			text = "farming_bread.png",
			number = 20,
			alignment = {x=0, y=0},
			offset = {x=0, y=0},
		})
		bars.hud[name].water = player:hud_add({
			hud_elem_type = "statbar",
			position = {x=0, y=0},
			size = "",
			text = "bars_water.png^vessels_drinking_glass.png",
			number = 20,
			alignment = {x=0, y=0},
			offset = {x=0, y=20},
		})
		bars.hud[name].energy = player:hud_add({
			hud_elem_type = "statbar",
			position = {x=1, y=0},
			size = "",
			text = "bars_energy.png",
			number = 20,
			alignment = {x=0, y=0},
			offset = {x=-160, y=0},
		})
		bars.hud[name].mana = player:hud_add({
			hud_elem_type = "statbar",
			position = {x=1, y=0},
			size = "",
			text = "bars_mana.png",
			number = 20,
			alignment = {x=0, y=0},
			offset = {x=-160, y=20},
		})
		minetest.after(1, function()
			update_bars(player, name)
		end)
	end)
end)

local function calc_stack(stack, replace, user)
	stack:take_item()
	if replace then
		local inv = user:get_inventory()
		if inv:room_for_item("main", replace) then
			inv:add_item("main", replace)
		else
			minetest.item_drop(ItemStack(replace), user, user:getpos())
		end
	end
	return stack
end

minetest.register_on_item_eat(function(hp, replace, stack, user, pt)
	if not user then return end
	if not user:is_player() then return end
	local name = user:get_player_name()
	if not name then return end
	if hp < 0 then
		user:set_hp(user:get_hp() + hp)
		return calc_stack(stack, replace, user)
	else
		if not bars.stat[name] then return end
		if bars.stat[name].food < 20 then
			bars.stat[name].food = bars.stat[name].food + hp
			update_bars(user, name)
			return calc_stack(stack, replace, user)
		else
			return stack
		end
	end
end)

function bars.drink(amount, replace)
	return function(stack, user, pt)
		if not user then return end
		local name = user:get_player_name()
		if not name then return end
		if not bars.stat[name] then return end
		if amount > 0 and bars.stat[name].water < 20 then
			bars.stat[name].water = bars.stat[name].water + amount
			update_bars(user, name)
			return calc_stack(stack, replace, user)
		end
	end
end

function bars.use_mana(amount, player)
	if not player then return end
	local name = player:get_player_name()
	if not name then return end
	if not bars.stat[name] then return end
	if amount > 0 then
		local mana = bars.stat[name].mana * bars.stat[name].mmana
		mana = mana - amount
		if mana >= 0 then
			bars.stat[name].mana = math.floor(mana/bars.stat[name].mmana)
			update_bars(player, name)
			return true
		else
			return false
		end
	end
end

minetest.register_craftitem("bars:water_glass", {
	description = "Water Glass",
	inventory_image = "bars_water.png^vessels_drinking_glass.png",
	on_use = bars.drink(1, "vessels:drinking_glass")
})

minetest.override_item("vessels:drinking_glass", {
	liquids_pointable = true,
	on_use = function(stack, user, pt)
		if pt.type == "node" then
			local node = minetest.get_node(pt.under)
			if node.name == "default:water_source" then
				return calc_stack(stack, "bars:water_glass", user)
			end
		end
	end,
})

minetest.override_item("default:stick", {
	liquids_pointable = true,
	on_use = function(stack, user, pt)
		if pt.type == "node" then
			local node = minetest.get_node(pt.under)
			if node.name == "default:water_source" then
				bars.drink(1)(stack, user, pt)
			end
		end
	end,
	-- Function to test bars.use_mana
	--[[on_place = function(stack, user, pt)
		bars.use_mana(2, user)
	end,]]
})

minetest.register_chatcommand("bars_heal", {
	description = "Heal all Bars",
	privs = {give=true},
	func = function(name, param)
		if not name then return end
		if not bars.stat[name] then return end
		bars.stat[name].water = 20
		bars.stat[name].food = 20
		bars.stat[name].energy = 20
		bars.stat[name].mana = 20
		local player = minetest.get_player_by_name(name)
		if not player then return end
		player:set_hp(20)
		update_bars(player, name)
		minetest.chat_send_player(name, "You heal'ed")
	end,
})
