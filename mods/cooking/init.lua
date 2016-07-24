cooking = {}

local box = {
	
	type = "fixed",
	fixed = { { -0.4, -0.5, -0.4, 0.4, -0.1, 0.4 } }
}

minetest.register_node("cooking:fireplace", {
	description = "Fireplace",
	drawtype = "mesh",
	inventory_image = "default_stick.png",
	mesh = "cooking_fireplace.obj",
	tiles = {"default_tree.png"},
	groups = {crumbly=3},
	paramtype="light",
	selection_box = box,
	collision_box = box,
	drop = "default:stick",
})

local function formspec(pos) return "size[8,7]"..
				"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";output;2,0;1,1;1]"..
				"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";output;4,1;1,1]"..
				"list[nodemeta:"..pos.x..","..pos.y..","..pos.z..";input;2,1;1,1]"..
				"image[3,1;1,1;gui_furnace_arrow_fg.png^[transformR270]"..
				"list[current_player;main;0,3;8,4]" end
				
local recipes = {}

function cooking.register_recipe(input, output, byproduct, time)
	if not input or not output then return end
	recipes[input] = {[1]=output, [2]=byproduct, [3]=time or 1}
end

minetest.register_node("cooking:stick", {
	description = "Cooking Stick",
	drawtype = "mesh",
	inventory_image = "default_stick.png",
	mesh = "cooking_stick.obj",
	tiles = {"default_wood.png"},
	groups = {crumbly=3},
	paramtype="light",
	drop = "default:stick",
	
	-- Workaround: on construct not worked
	on_rightclick= function(pos, node, player, stack, pt)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 1)
		inv:set_size("output", 2)
		if not player then return end
		local name=player:get_player_name()
		if not name then return end
		minetest.show_formspec(name, "cooking:show", formspec(pos))
	end,
	
	-- Allow only place on fireplace
	on_place = function(stack, placer, pt)
		if pt.type ~= "node" then return end
		local node = minetest.get_node(pt.under)
		if not (node.name == "cooking:fireplace" or node.name == "cooking:fireplace_burn") then return end
		return minetest.item_place(stack, placer, pt)
	end,
	
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "input" then
			local name = stack:get_name()
			if recipes[name] then
				local timer = minetest.get_node_timer(pos)
				timer:start(recipes[name][3])
			end
		end
	end,
	
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		if listname == "output" then
			return 0
		else
			return stack:get_count()
		end
	end,
	
	on_timer = function(pos, time)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local input = inv:get_stack("input", 1)
		if input and not input:is_empty() then
			local n = input:get_name()
			local r = recipes[n]
			if not r then return false end
			local output = inv:get_stack("output", 1)
			local byproduct = inv:get_stack("output", 2)
			
			local times = math.floor(time/r[3])
			if not output or output:is_empty() then
				output = ItemStack(r[1])
				output:set_count(0)
			else
				if r[1] ~= output:get_name() then return true end
			end
			
			if byproduct and not byproduct:is_empty() and r[2] ~= byproduct:get_name() then
				return true
			elseif not byproduct or byproduct:is_empty() then
				if r[2] then
					byproduct = ItemStack(r[2])
					byproduct:set_count(0)
				end
			end
			
			local under = {x=pos.x, y=pos.y-1, z=pos.z}
			local node = minetest.get_node(under)
			if node.name ~= "cooking:fireplace_burn" then return true end
			
			for i=1,times do
				if input:take_item():is_empty() then break end
				if r[2] and math.random(15) == 1 and byproduct:item_fits(r[2]) then
					byproduct:add_item(r[2])
				end
				if output:item_fits(r[1]) then
					output:add_item(r[1])
				end
			end

			inv:set_stack("input", 1, input)
			inv:set_stack("output", 1, output)
			if byproduct then
				inv:set_stack("output", 2, byproduct)
			end
			if not input:is_empty() then
				return true
			else
				return false
			end
		end
	end,
	
})

minetest.register_node("cooking:fireplace_burn", {
	description = "Fireplace",
	drawtype = "mesh",
	inventory_image = "default_stick.png",
	mesh = "cooking_fireplace_burn.obj",
	tiles = {"default_tree.png", "fire_basic_flame.png"},
	groups = {crumbly=3},
	paramtype="light",
	light_source=20,
	drop = "",
	selection_box = box,
	collision_box = box,
	after_dig_node = function(pos, oldnode, oldmetadata, digger)
		if digger and digger:is_player() then
			digger:set_hp(digger:get_hp()-4)
			local name = digger:get_player_name()
			if name then
				minetest.chat_send_player(name, "This was hot!")
			end
		end
	end,
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		meta:set_int("burn", 6)
		local timer = minetest.get_node_timer(pos)
		timer:start(6)
	end,
	on_timer = function(pos, elapsed)
		local meta = minetest.get_meta(pos)
		local burn = meta:get_int("burn")
		if burn then
			burn = burn - elapsed
			if burn > 0 then
				meta:set_int("burn", math.floor(burn))
				local timer = minetest.get_node_timer(pos)
				timer:start(math.floor(burn))
			else
				minetest.remove_node(pos)
			end
		else
			minetest.remove_node(pos)
		end
		return false
	end,
})

minetest.register_craftitem("cooking:basic_lighter", {
	description = "Basic Ligther",
	inventory_image = "default_stick.png^cooking_basic_lighter.png",
	on_use = function(stack, user, pt)
		if pt.type ~= "node" then return end
		local node = minetest.get_node(pt.under)
		local ndef = minetest.registered_nodes[node.name]
		if (not ndef or not ndef.set_fire) and node.name ~= "cooking:fireplace" then return end
		stack:take_item()
		if math.random(10) == 1 then
			if ndef.set_fire then
				ndef.set_fire(pt.under)
			else
				minetest.add_node(pt.under, {name="cooking:fireplace_burn"})
			end
		end
		return stack
	end,
	
})

local fuels = {}

local function add_fuel(stack, user, pt)
	if pt.type ~= "node" then return end
	local node = minetest.get_node(pt.under)
	local ndef = minetest.registered_nodes[node.name]
	if ndef and ndef.on_punch then
		local new = ndef.on_punch(pt.under, node, user, pt)
		if new then return new end
	end
	if node.name ~= "cooking:fireplace_burn" then return end
	local n = stack:get_name()
	if not fuels[n] then return end
	local meta = minetest.get_meta(pt.under)
	local burn = meta:get_int("burn")
	if not burn then return end
	-- Max Burntime 20m
	if burn > 60*20 then return end
	burn = burn + fuels[n]
	meta:set_int("burn", burn)
	stack:take_item()
	return stack
end

function cooking.register_fireplace_fuel(name, burn)
	if name and burn then
		fuels[name] = burn
		local old_use = minetest.registered_items[name].on_use
		minetest.override_item(name, {
			on_use = function(stack, user, pt)
				local new = add_fuel(stack, user, pt)
				if new then return new end
				if old_use then
					return old_use(stack, user, pt)
				end
			end,
		})
	end
end



local old_stick_use = minetest.registered_items["default:stick"].on_use
local old_stick_place = minetest.registered_items["default:stick"].on_place
fuels["default:stick"] = 6
minetest.override_item("default:stick", {
	on_use = function(stack, user, pt)
		if pt.type == "node" then
			local new = add_fuel(stack, user, pt)
			if new then return new end
			local node = minetest.get_node(pt.under)
			if node.name == "default:cobble" then
				stack:take_item()
				if math.random(15) == 1 then
					local new = pt.under
					new.y = new.y + 1
					if minetest.get_node(new).name == "air" then
						minetest.add_node(new, {name="cooking:fireplace"})
					end
				end
				return stack
			end
		end
		if old_stick_use then
			return old_stick_use(stack, user, pt)
		end
	end,
	on_place = function(stack, user, pt)
		if pt.type == "node" then
			local node = minetest.get_node(pt.under)
			if node.name == "cooking:fireplace_burn" or node.name == "cooking:firebox_open_burn" then
				local torch = ItemStack("cooking:basic_torch")
				-- Torch burns 10m
				torch:set_metadata(minetest.get_gametime() + 10*60)
				torch:set_count(stack:get_count())
				return torch
			end
		end
		if old_stick_place then
			old_stick_place(stack, user, pt)
		end
	end,
})

cooking.register_fireplace_fuel("default:wood", 24)
cooking.register_fireplace_fuel("default:tree", 60)


-- Copy of the default torch (moded)
minetest.register_node("cooking:basic_torch", {
	description = "Basic Torch",
	drawtype = "torchlike",
	drop = "",
	tiles = {
		{
			name = "default_torch_on_floor_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0
			},
		},
		{
			name="default_torch_on_ceiling_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0
			},
		},
		{
			name="default_torch_animated.png",
			animation = {
				type = "vertical_frames",
				aspect_w = 16,
				aspect_h = 16,
				length = 3.0
			},
		},
	},
	inventory_image = "default_torch_on_floor.png",
	wield_image = "default_torch_on_floor.png",
	paramtype = "light",
	paramtype2 = "wallmounted",
	sunlight_propagates = true,
	is_ground_content = false,
	walkable = false,
	light_source = default.LIGHT_MAX - 1,
	selection_box = {
		type = "wallmounted",
		wall_top = {-0.1, 0.5 - 0.6, -0.1, 0.1, 0.5, 0.1},
		wall_bottom = {-0.1, -0.5, -0.1, 0.1, -0.5 + 0.6, 0.1},
		wall_side = {-0.5, -0.3, -0.1, -0.5 + 0.3, 0.3, 0.1},
	},
	groups = {choppy = 2, dig_immediate = 3, flammable = 1, attached_node = 1},
	legacy_wallmounted = true,
	sounds = default.node_sound_defaults(),
	after_place_node = function(pos, placer, stack, pt)
		local burn = stack:get_metadata()
		burn = burn or "-1"
		if burn == "" then burn="-1" end
		burn = tonumber(burn)
		local timer = minetest.get_node_timer(pos)
		if burn > 0 then
			burn = burn - minetest.get_gametime()
			if burn > 0 then
				timer:start(burn)
			else
				minetest.remove_node(pos)
			end
		else
			timer:start(6)
		end
	end,
	on_timer = function(pos, time)
		minetest.remove_node(pos)
		return false
	end,
	
	on_use = function(stack, user, pt)
		if pt.type ~= "node" then return end
		local node = minetest.get_node(pt.under)
		local ndef = minetest.registered_nodes[node.name]
		if (not ndef or not ndef.set_fire) and node.name ~= "cooking:fireplace" then return end
		if not stack or stack:is_empty() then return end
		local meta = stack:get_metadata()
		if not meta or meta == "" then return end
		local burn = tonumber(meta)
		if burn > minetest.get_gametime() then
			if ndef.set_fire then
				ndef.set_fire(pt.under)
			else
				minetest.add_node(pt.under, {name="cooking:fireplace_burn"})
			end
			stack:take_item()
			return stack
		else
			return ItemStack()
		end
	end,
})

magic.register_infusion("cooking:fireplace_burn", {
	level=1,
	mana=1.5,
	action = function(pos, player)
		local meta = minetest.get_meta(pos)
		local timer = minetest.get_node_timer(pos)
		local burn = meta:get_int("burn")
		burn = math.floor(burn-timer:get_elapsed())
		if burn > 0 then
			timer:stop()
			minetest.swap_node(pos, {name="cooking:fireplace"})
			meta:set_int("burn", burn)
		end
	end,
})

magic.register_infusion("cooking:fireplace", {
	mana = 0.5,
	action = function(pos, player)
		local meta = minetest.get_meta(pos)
		local burn = meta:get_int("burn")
		if burn and burn > 0 then
			local timer = minetest.get_node_timer(pos)
			minetest.swap_node(pos, {name="cooking:fireplace_burn"})
			timer:start(burn)
		end
	end,
})

dofile(minetest.get_modpath("cooking").."/recipes.lua")
dofile(minetest.get_modpath("cooking").."/better.lua")