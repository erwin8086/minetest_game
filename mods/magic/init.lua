magic = {}

magic.trans = {}
magic.inf = {}

local function do_transform(stack, user, pt)
	if not user then return end
	if not user:is_player() then return end
	if pt.type ~= "node" then return end
	local node = minetest.get_node(pt.under)
	local recipe = magic.trans[node.name]
	if recipe then
		local def = stack:get_definition()
		if not def.magic_rod then return end
		local rod = def.magic_rod
		if rod.type == recipe.type and rod.level >= recipe.level then
			local cost = recipe.mana * rod.mana
			if bars.use_mana(cost, user) then
				if recipe.action then
					recipe.action(pt.under, user)
				else
					minetest.add_node(pt.under, {name=recipe.output})
				end
				stack:add_wear(rod.uses)
				return stack
			end
		end
	end
end

local function do_infusion(stack, user, pt)
if not user then return end
	if not user:is_player() then return end
	if pt.type ~= "node" then return end
	local node = minetest.get_node(pt.under)
	local recipe = magic.inf[node.name]
	if recipe then
		local def = stack:get_definition()
		if not def.magic_rod then return end
		local rod = def.magic_rod
		if rod.type == recipe.type and rod.level >= recipe.level then
			local cost = recipe.mana * rod.mana
			if bars.use_mana(cost, user) then
				if recipe.action then
					recipe.action(pt.under, user)
				else
					minetest.add_node(pt.under, {name=recipe.output})
				end
				stack:add_wear(rod.uses)
				return stack
			end
		end
	end
end

function magic.register_rod(name, def)
	def.level = def.level or 0
	def.type = def.type or "nature"
	def.uses = def.uses or 1000
	def.mana = def.mana or 3
	def.description = def.description or "Magic Rod"
	def.image = def.image or "unknown.png"
	minetest.register_tool(name, {
		magic_rod = {
			uses = def.uses,
			type = def.type,
			level = def.level,
			mana = def.mana,
		},
		description = def.description,
		inventory_image = def.image,
		on_use = do_transform,
		on_place = do_infusion,
	})
end

function magic.register_transform(node, recipe)
	if not node or not recipe then return end
	if not recipe.output and not recipe.action then return end
	recipe.type = recipe.type or "nature"
	recipe.mana = recipe.mana or 1
	recipe.level = recipe.level or 0
	magic.trans[node] = recipe
end

function magic.register_infusion(node, recipe)
	if not node or not recipe then return end
	if not recipe.output and not recipe.action then return end
	recipe.type = recipe.type or "nature"
	recipe.mana = recipe.mana or 1
	recipe.level = recipe.level or 0
	magic.inf[node] = recipe
end

magic.register_rod("magic:simple_nature", {
	description = "Simple Nature Road uses energy from Leaves",
	image="default_stick.png^magic_simple_nature.png",
})

magic.register_rod("magic:better_nature", {
	description = "Better Nature Road uses energy from Apples",
	image="default_stick.png^magic_better_nature.png",
	level=1,
	uses = 500,
	mana = 2,
})

dofile(minetest.get_modpath("magic").."/recipes.lua")

local old_stick_use = minetest.registered_items["default:stick"].on_use

minetest.override_item("default:stick", {
	on_use = function(stack, user, pt)
		if pt.type == "node" then
			local node = minetest.get_node(pt.under)
			if node.name == "default:leaves" then
				minetest.remove_node(pt.under)
				if stack:get_count() == 1 then
					local meta = stack:get_metadata()
					if meta == "" then
						stack:set_metadata("0")
					elseif tonumber(meta) >= 10 then
						stack = ItemStack("magic:simple_nature")
					else
						stack:set_metadata(tonumber(meta) + 1)
					end
					return stack
				end
			end
		end
		if old_stick_use then
			return old_stick_use(stack, user, pt)
		end
	end,
})

-- Magic project bench
dofile(minetest.get_modpath("magic").."/project.lua")