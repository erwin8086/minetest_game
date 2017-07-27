-- Soruce: https://de.wikipedia.org/wiki/Vitamin
vitamins = {}
vitamins.list = {
  {"A", "Vitamin A", {}},
  {"B1", "Vitamin B1", {}},
  {"B2", "Vitamin B2", {}},
  {"B3", "Vitamin B3", {}},
  {"B5", "Vitamin B5", {}},
  {"B6", "Vitamin B6", {}},
  {"B7", "Vitamin B7", {}},
  {"B9", "Vitamin B9", {}},
  {"B12", "Vitamin B12", {}},
  {"C", "Vitamin C", {}},
  {"D", "Vitamin D", {}},
  {"E", "Vitamin E", {}},
  {"K", "Vitamin K", {}},
}

vitamins.index_list = {}

for _, vit in ipairs(vitamins.list) do
	vitamins.index_list[vit[3]] = {vit[1], vit[2]}
end

local vf = io.open(minetest.get_worldpath().."/vitamins.lua", "r")
local vits
if vf then
	vits = minetest.deserialize(vf:read("*all"))
	vf:close()
end

if not vits then
	vits = {}
end

local store = minetest.get_mod_storage()

function vitamins.get_def(def)
	local d = {}
	for n, a in pairs(def) do
		for _, v in ipairs(vitamins.list) do
			if n == v[1] then
				d[#d+1] = {v[3], a}
				break
			end
		end
	end
	return d
end

function vitamins.reset(player)
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
	end

	if not player then return end
	for _, def in ipairs(vitamins.list) do
		-- Start with 200% of each
		store:set_int(player:get_player_name().."_"..def[1], 200)
	end
end

minetest.register_on_newplayer(vitamins.reset)
minetest.register_on_dieplayer(vitamins.reset)

function vitamins.get(player)
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
	end
	if not player then return end

	local r = {}
	for _, def in ipairs(vitamins.list) do
		r[#r+1] = {def[3], store:get_int(player:get_player_name().."_"..def[1])}
	end
	return r
end

local deficits = {}
for _, vit in ipairs(vitamins.list) do
	deficits[vit[3]] = {start = {}, restore = {}}
end

function vitamins.register_deficit(vitamin, start, restore)
	-- Convert vitamin to table if necessary
	-- Exit if not a vitamin
	if type(vitamin) == "string" then
		for _, vit in ipairs(vitamins.list) do
			if vit[1] == vitamin then
				vitamin = vit[3]
				break
			end
		end
		if type(vitamin) ~= "table" then return end
	elseif type(vitamin) ~= "table" then
		return
	elseif not deficits[vitamin] then
		return
	end

	local vit = deficits[vitamin]
	local sta = vit.start
	local sto = vit.stop
	sta[#sta+1] = start
	sto[#sto+1] = stop
end

local is_active = {}

function vitamins.calc(player)
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
	end
	if not player then return end

	local name = player:get_player_name()
	local stat = vitamins.get(player)
	for _, vit in pairs(stat) do
		if vit[2] < 100 then
			if not is_active[name] then
				is_active[name] = {}
			end
			if not is_active[name][vit[1]] then
				is_active[name][vit[1]] = true
				for _, start in ipairs(deficit[vit[1]].start) do
					start(vit[1], vit[2], player)
				end
			end
		elseif vit[2] >= 100 then
			if is_active[name] and is_active[name][vit[1]] then
				is_active[name][vit[1]] = false
				for _, restore in ipairs(deficit[vit[1]].restore) do
					restore(vit[1], vit[2], player)
				end
			end
		end
	end
end

function vitamins.eat(player, item)
	item = ItemStack(item)
	if item:is_empty() then return end
	if type(player) == "string" then
		player = minetest.get_player_by_name(player)
	end
	if not player then return end

	local name = player:get_player_name()
	local stat = {}
	for _, vit in ipairs(vitamins.list) do
		stat[vit[3]] = store:get_int(name.."_"..vit[1])
		stat[vit[3]] = stat[vit[3]] - 5
	end
	if vits[item:get_name()] then
		for _, vit in ipairs(vits[item:get_name()]) do
			stat[vit[1]] = vit[2] + stat[vit[1]] + 5
			if stat[vit[1]] > 200 then
				stat[vit[1]] = 200
			elseif stat[vit[1]] < 0 then
				stat[vit[1]] = 0
			end
		end
	end
	for _, vit in ipairs(vitamins.list) do
		store:set_int(name.."_"..vit[1], stat[vit[3]])
	end
	vitamins.calc(player)
end

minetest.register_chatcommand("vitamins", {
	params = "",
	description = "Show your vitamin status",
	privs = {interact=true},
	func = function(name, param)
		if param == "item" then
			local player = minetest.get_player_by_name(name)
			if not player then return end
			local stack = player:get_wielded_item()
			local v = vits[stack:get_name()]
			local res = ""
			if v then
				for _, d in ipairs(v) do
					res=res..vitamins.index_list[d[1]][2].." = "..tostring(d[2]).."%\n"
				end
				return true, res
			end
			return
		end
		local stat = vitamins.get(name)
		local res = ""
		for _, vit in ipairs(stat) do
			res = res..vitamins.index_list[vit[1]][2].." = "..tostring(vit[2]).."%\n"
		end
		return true, res
	end,
})

-- Taken from xdecor see mods/xdecor
-- Ugly hack to determine if an item has the function `minetest.item_eat` in its definition.
local function eatable(def)
	local on_use_def = def.on_use
	if not on_use_def then return end
	return string.format("%q", string.dump(on_use_def)):find("item_eat")
end

minetest.after(0, function()
	local vf = io.open(minetest.get_worldpath().."/vitamins.lua", "w")
	for name, def in pairs(minetest.registered_items) do
		if eatable(def) then
			if not vits[name] then

				local v = {}
				for _, d in ipairs(vitamins.list) do
					if math.floor(math.random(5)) == 1 then
						v[d[1]] = math.floor(math.random(10)+1)
					end
				end
				vits[name] = v
			end
		end
	end
	vf:write(minetest.serialize(vits))
	vf:close()
	for n, d in pairs(vits) do
		vits[n] = vitamins.get_def(d)
	end
end)
