light = {}

local function on_construct(pos, burntime)
	local timer = minetest.get_node_timer(pos)
	timer:start(burntime * 100)
end

local function on_rightclick(pos, node, player, stack, pt, on)
	local fuel = stack:get_name()
	local burntime = minetest.get_craft_result({
		method = "fuel",
		width = 0,
		items = { fuel },
	}).time * 100 -- Bruns 100 times of burntime in furnace -> 66mins for coal
	if burntime > 0 then
		stack:take_item()
		node.name = on
		minetest.swap_node(pos, node)
		local timer = minetest.get_node_timer(pos)
		timer:start(burntime)
	end
	return stack
end

local function el_abm(pos, node, on, off, demand)
	local meta = minetest.get_meta(pos)
	meta:set_int("LV_EU_demand", demand)
	local input = meta:get_int("LV_EU_input") or 0
	meta:set_int("LV_EU_input", 0)
	if node.name == off and input >= demand then
		node.name = on
		minetest.swap_node(pos, node)
	elseif node.name == on and input < demand then
		node.name = off
		minetest.swap_node(pos, node)
	end
	print("technic_run input="..tostring(input).." demand="..tostring(demand))
end

function light.register_light(name, def)
	local on, off
	local power_type = def.power_type
	def.power_type = nil
	local burntime = def.burntime or 3 -- 5 mins
	def.burntime = nil
	local demand = def.eu_demand or 10
	def.eu_demand = nil

	if power_type == "electric" then
		def.groups["technic_lv"] = 1
		--def.groups["technic_machine"] = 1
	end

	on = def
	off = {}
	for x,y in pairs(def) do
		off[x] = y
	end
	off.light_source = 0

	local def_state = "off"
	local noff = name
	local non  = name.."_on"
	if power_type == "fuel" then
		def_state = "on"
		non = name
		noff  = name.."_off"
		on.drop = noff
	else
		on.drop = noff
	end

	-- We need to start fuel timer
	if power_type == "fuel" then
		if def.on_timer then
			print("Warning in mod light/init.lua timer exists overriding")
		end
		-- Turn off if burned down
		on.on_timer = function(pos)
			local node = minetest.get_node(pos)
			node.name = noff
			minetest.swap_node(pos, node)
		end

		if on.on_construct then
			local old_handler = on.on_construct
			on.on_construct = function(pos)
				on_construct(pos, burntime)
				return old_handler(pos)
			end
		else
			on.on_construct = function(pos)
				on_construct(pos, burntime)
			end
		end

		if off.on_rightclick then
			local old_handler = off.on_rightclick
			off.on_rightclick = function(pos, node, player, stack, pt)
				stack = on_rightclick(pos, node, player, stack, pt, non)
				return old_handler(pos, node, player, stack, pt)
			end
		else
			off.on_rightclick = function(pos, node, player, stack, pt)
				return on_rightclick(pos, node, player, stack, pt, non)
			end
		end
	elseif power_type == "electric" then
		on.technic_run = function(pos, node)
			el_abm(pos, node, non, noff, demand)
		end
		off.technic_run = on.technic_run
	end

	minetest.register_node(noff, off)
	minetest.register_node(non, on)
	if power_type == "electric" then
		minetest.after(0, function()
			technic.register_machine("LV", non, technic.receiver)
			technic.register_machine("LV", noff, technic.receiver)
		end)
	end
end
