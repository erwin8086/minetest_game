local recipes = {}

function magic.get_project_recipes()
	return recipes
end

-- Register types
do
	local types = {"nature"}
	for _, t in ipairs(types) do
		recipes[t] = {}
	end
end

function magic.register_bench_type(name)
	if recipes[name] then return end
	recipes[name] = {}
end

function magic.register_recipe(t, def)
	if not t or not def then return end
	if not recipes[t] then return end
	if not def.output then return end
	if not def.recipe then return end
	def.type = def.type or ""
	def.mana = def.mana or 1
	recipes[t][#recipes[t]+1] = def
end

-- From lua-users.org
function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function magic.get_output(inv, rod)
		local t = rod:get_definition()
		if not t.magic_rod then return end
		t = t.magic_rod.type
		if not recipes[t] then return end
		for _, r in ipairs(recipes[t]) do
			if r.type == "" then
				local ok=true
				for i=1,9 do
					if r.recipe[i] and string.starts(r.recipe[i], "group:") and minetest.get_item_group(inv[i], r.recipe[i]:sub(7,-1)) > 0 then
						
					elseif r.recipe[i] ~= inv[i] then
						ok=false
						break
					end
				end
				if ok then return r end
			end
		end
		return false
end

minetest.register_node("magic:project", {
	description = "Magic Project Table",
	tiles = {"default_wood.png", "default_tree_top.png", "default_tree.png"},
	groups = {choppy=3, oddly_breakable_by_hand=1},
	drop = "default:wood",
	on_construct = function(pos)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		inv:set_size("input", 9)
		inv:set_size("rod", 1)
		inv:set_size("output", 1)
		meta:set_string("formspec", "size[8,9]list[current_player;main;0,5;8,4]"..
					"image[6,1;1,1;gui_furnace_arrow_fg.png^[transformR270]"..
					"list[context;input;3,0;3,3]list[context;rod;0,1;1,1]list[context;output;7,1;1,1]")
	end,
	allow_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "output" then
			return 0
		elseif listname == "input" then
			local is = inv:get_stack(listname, index)
			if not is or is:is_empty() then
				return 1
			else
				return 0
			end
		elseif listname == "rod" then
			return 1
		end
	end,
	on_metadata_inventory_put = function(pos, listname, index, stack, player)
		local meta = minetest.get_meta(pos)
		local inv = meta:get_inventory()
		if listname == "rod" then
			local input = {}
			for i, stack in ipairs(inv:get_list("input")) do
				if stack and not stack:is_empty() then
					input[i] = stack:get_name()
				end
			end
			local out = magic.get_output(input, stack)
			if out then
				local rod = stack:get_definition().magic_rod
				if rod and bars.use_mana(out.mana * rod.mana, player) then
					inv:set_list("input", {})
					inv:set_stack("output", 1, ItemStack(out.output))
					stack:add_wear(rod.uses)
					local pinv = player:get_inventory()
					if pinv:room_for_item("main", stack) then
						pinv:add_item("main", stack)
						inv:set_stack(listname, index, nil)
					else
						inv:set_stack(listname, index, stack)
					end
				end
			end
		end
	end,
	
})

magic.register_infusion("default:tree", {
	mana=1.5,
	output="magic:project",
})


