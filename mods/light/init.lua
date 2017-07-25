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
		minetest.swap_node(pos, {name=on, param1=node.param1, param2=node.param2})
	elseif node.name == on and input < demand then
		minetest.swap_node(pos, {name=off, param1=node.param1, param2=node.param2})
	end
end

local function fullname(name, reg)
	if xdecor and reg == xdecor.register then
		return "xdecor:"..name
	elseif homedecor and reg == homedecor.register then
		return "homedecor:"..name
	end
	return name
end

function light.register_light(name, def, register)
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

	if not register then
		register = minetest.register_node
	end

	on = def
	off = {}
	for x,y in pairs(def) do
		off[x] = y
	end
	off.light_source = 0
	off.groups = {}
	for x, y in pairs(def.groups) do
		off.groups[x] = y
	end

	local def_state = "off"
	local noff = name
	local non  = name.."_on"
	if power_type == "fuel" then
		def_state = "on"
		non = name
		noff  = name.."_off"
		if not on.drop then
			on.drop = noff
		end
		on.groups.not_in_creative_inventory = 1
	else
		if not on.drop then
			on.drop = noff
		end
		off.groups.not_in_creative_inventory = 1
	end

	-- We need to start fuel timer
	if power_type == "fuel" then
		if def.on_timer then
			print("Warning in mod light/init.lua timer exists overriding")
		end
		-- Turn off if burned down
		on.on_timer = function(pos)
			local node = minetest.get_node(pos)
			node.name = fullname(noff, register)
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
				stack = on_rightclick(pos, node, player, stack, pt, fullname(non, register))
				return old_handler(pos, node, player, stack, pt)
			end
		else
			off.on_rightclick = function(pos, node, player, stack, pt)
				return on_rightclick(pos, node, player, stack, pt, fullname(non, register))
			end
		end
	elseif power_type == "electric" then
		on.technic_run = function(pos, node)
			el_abm(pos, node, fullname(non, register), fullname(noff, register), demand)
		end
		off.technic_run = on.technic_run
	end

	register(noff, off)
	register(non, on)
	if power_type == "electric" then
		minetest.after(0, function()
			technic.register_machine("LV", fullname(non,register), technic.receiver)
			technic.register_machine("LV", fullname(noff,register), technic.receiver)
		end)
	end
end
