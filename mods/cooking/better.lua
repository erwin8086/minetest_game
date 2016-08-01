local function get_switch(alt)
	return function(pos, node, player, itemstack, pointed_thing)
		minetest.swap_node(pos, {name=alt})
	end
end

local function on_timer(pos, time)
	local meta = minetest.get_meta(pos)
	local burn = meta:get_int("burn")
	burn = math.floor(burn-time)
	if burn > 0 then
		local timer = minetest.get_node_timer(pos)
		if burn < 60 then
			timer:start(burn)
		else
			timer:start(60)
		end
		meta:set_int("burn", burn)
	else
		local node = minetest.get_node(pos)
		if node.name == "cooking:firebox_open_burn" then
			minetest.add_node(pos, {name="cooking:firebox_open"})
		else
			minetest.add_node(pos, {name="cooking:firebox_close"})
		end
		return false
	end
end

local function on_construct(pos)
	local meta = minetest.get_meta(pos)
	local timer = minetest.get_node_timer(pos)
	meta:set_int("burn", 6)
	timer:start(6)
end

local function on_punch(pos, node, player, pointed_thing)
	if not player or not player:is_player() then return end
	local meta = minetest.get_meta(pos)
	local stack = player:get_wielded_item()
	local burn = minetest.get_craft_result({
		method="fuel",
		width=1,
		items={stack},
	})
	if burn and burn.time > 0 then
		local b = meta:get_int("burn")
		if b < 60*60 then
			meta:set_int("burn", b + burn.time)
			stack:take_item()
		end
	end
	player:set_wielded_item(stack)
	return stack
end

local function hot(pos, oldnode, oldmetadata, digger)
	if digger and digger:is_player() then
		digger:set_hp(digger:get_hp()-4)
		minetest.chat_send_player(digger:get_player_name(), "This was Hot!")
	end
end



minetest.register_node("cooking:firebox_close", {
	description = "Firebox",
	drawtype = "mesh",
	inventory_image = "default_brick.png",
	mesh = "cooking_firebox_close.obj",
	tiles = {"default_steel_block.png", "default_obsidian_glass.png", "default_tree.png", "default_brick.png"},
	groups = {cracky=3},
	paramtype="light",
	drop = "default:brick",
	on_rightclick = get_switch("cooking:firebox_open"),
})

minetest.register_node("cooking:firebox_open", {
	description = "Firebox",
	drawtype = "mesh",
	inventory_image = "default_brick.png",
	mesh = "cooking_firebox_open.obj",
	tiles = {"default_steel_block.png", "default_obsidian_glass.png", "default_tree.png", "default_brick.png"},
	groups = {cracky=3},
	paramtype="light",
	drop = "default:brick",
	on_rightclick = get_switch("cooking:firebox_close"),
	set_fire = function(pos)
		minetest.add_node(pos, {name="cooking:firebox_open_burn"})
	end,
})

minetest.register_node("cooking:firebox_close_burn", {
	description = "Firebox",
	drawtype = "mesh",
	inventory_image = "default_brick.png",
	mesh = "cooking_firebox_close_burn.obj",
	tiles = {"fire_basic_flame.png", "default_tree.png", "default_steel_block.png", "default_obsidian_glass.png", "default_brick.png"},
	groups = {cracky=3},
	paramtype="light",
	drop = "default:brick",
	on_rightclick = get_switch("cooking:firebox_open_burn"),
	light_source=15,
	on_construct = on_construct,
	on_timer=on_timer,
	after_dig_node=hot,
})

minetest.register_node("cooking:firebox_open_burn", {
	description = "Firebox",
	drawtype = "mesh",
	inventory_image = "default_brick.png",
	mesh = "cooking_firebox_open_burn.obj",
	tiles = {"fire_basic_flame.png", "default_tree.png", "default_steel_block.png", "default_obsidian_glass.png", "default_brick.png"},
	groups = {cracky=3},
	paramtype="light",
	drop = "default:brick",
	on_rightclick = get_switch("cooking:firebox_close_burn"),
	light_source=15,
	on_construct = on_construct,
	on_timer=on_timer,
	on_punch=on_punch,
	after_dig_node=hot,
})