local function switch(pos, node)
	local meta = minetest.get_meta(pos)
	if node.name == "cooking:smelter_open" then
		minetest.swap_node(pos, {name="cooking:smelter_close"})
		meta:set_string("formspec", "")
	else
		minetest.swap_node(pos, {name="cooking:smelter_open"})
		meta:set_string("formspec", "size[8,9]list[current_player;main;0,5;8,4;]"..
			"list[context;input;1,1;1,1;]list[context;output;3,1;2,2;]")
	end
end

local function on_put(pos, listname, index, stack, player)
	if listname == "input" then
		local o = minetest.get_craft_result({
			method = "cooking",
			width = 1,
			items = {stack},
		})
		if o and o.time > 0 then
			local timer = minetest.get_node_timer(pos)
			timer:start(o.time)
		end
	end
end

local function on_take(pos, listname, index, stack, player)
	if listname == "input" then
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		local input = inv:get_stack("input", 1)
		if input and not input:is_empty() then return end
		local timer = minetest.get_node_timer(pos)
		timer:stop()
	end
end

local function is_fire(p)
	for i=1,2 do
		local under = {x=p.x, y=p.y-i, z=p.z}
		local node = minetest.get_node(under)
		if node.name == "cooking:firebox_open_burn" or node.name == "cooking:firebox_close_burn" then
			return true
		end
	end
end

local function on_timer(pos, time)
	if not is_fire(pos) then return true end
	local node = minetest.get_node(pos)
	if node.name ~= "cooking:smelter_close" then return true end
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	local input = inv:get_stack("input", 1)
	local o = minetest.get_craft_result({
		method = "cooking",
		width = 1,
		items = {input},
	})
	if o and o.time>0 and time >= o.time then
		if o.item and not o.item:is_empty() and inv:room_for_item("output", o.item) then
			input:take_item()
			inv:add_item("output", o.item)
			inv:set_stack("input", 1, input)
			if not input:is_empty() then return true end
		end
	end
end

local function construct(pos)
	local meta = minetest.get_meta(pos)
	local inv = meta:get_inventory()
	inv:set_size("input", 1)
	inv:set_size("output", 4)
	meta:set_string("formspec", "size[8,9]list[current_player;main;0,5;8,4;]"..
			"list[context;input;1,1;1,1;]list[context;output;3,1;2,2;]")
end

minetest.register_node("cooking:smelter_open", {
	description = "Smelter",
	drawtype = "mesh",
	inventory_image = "default_brick.png",
	mesh = "cooking_smelter_open.obj",
	tiles = {"default_brick.png"},
	groups = {cracky=3},
	paramtype="light",
	selection_box = box,
	collision_box = box,
	drop = "default:brick",
	on_punch = switch,
	on_construct = construct,
	on_timer=on_timer,
	on_metadata_inventory_put = on_put,
})

minetest.register_node("cooking:smelter_close", {
	description = "Smelter",
	drawtype = "mesh",
	inventory_image = "default_brick.png",
	mesh = "cooking_smelter_close.obj",
	tiles = {"default_brick.png"},
	groups = {cracky=3},
	paramtype="light",
	selection_box = box,
	collision_box = box,
	drop = "default:brick",
	on_punch = switch,
	on_construct = construct,
	on_timer=on_timer,
	on_metadata_inventory_put = on_put,
})