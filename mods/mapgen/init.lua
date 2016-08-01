--[[
	Map Generator for MagicSky
	You spawn at a single apple tree.
	Provides support for building teams,
	and a protection for your area while you online.
	
	By erwin8086: WTFPL
]]

local mapgen = {}
mapgen.next = {x=-30912, y=-30912}
mapgen.players = {}
skygen = {}
skygen.save = mapgen

local savefile = minetest.get_worldpath().."/skygen.dat"

local function savedata()
	local f = io.open(savefile, "w")
	if f then
		f:write(minetest.serialize(mapgen))
		f:close()
	end
end

skygen.savedata = savedata

local function loaddata()
	local f = io.open(savefile, "r")
	if f then
		mapgen = minetest.deserialize(f:read("*all"))
		f:close()
		skygen.save = mapgen
	end
end

loaddata()

minetest.set_mapgen_params({
	mgname = "singlenode",
})

local function nextspawn()
		local n = mapgen.next
		n.x = n.x + 128
		if n.x > 30912 then
			n.x = -30912
			n.y = n.y + 128
			if n.y > 30912 then
				print("[ERR] No Free spawn reset to start")
				n.x = -30912
				n.y = -30912
			end
		end
end

function skygen.new_spawn(player)
	if not player then return end
	local name = player:get_player_name()
	if not name then return end
	if mapgen.players[name] then return end
	local n = mapgen.next
	-- Calcualte 3d pos from 2d
	local spawn = {x=n.x+64, z=n.y+64, y=64}
	-- Go save and spawn two trees
	default.grow_tree(spawn, true)
	minetest.after(1, function()
		default.grow_tree(spawn, true)
		local pspawn = {x=spawn.x, y=spawn.y, z=spawn.z}
		local node = minetest.get_node(pspawn)
		while node.name == "default:tree" or node.name == "default:leaves" or node.name == "default:apple" do
			pspawn.y = pspawn.y + 1
			node = minetest.get_node(pspawn)
		end	
		mapgen.players[name] = pspawn
		player:setpos(pspawn)
		savedata()
	end)
	nextspawn()
end


minetest.register_on_joinplayer(skygen.new_spawn)

local time = 0
minetest.register_globalstep(function(dtime)
	time = time + dtime
	if time > 5 then
		time = 0
		minetest.after(1, function()
			for _, player in ipairs(minetest.get_connected_players()) do
				if player:getpos().y < 0 then
					if minetest.setting_getbool("enable_damage") == true then
						player:set_hp(0)
					else
						local name = player:get_player_name()
						if not name then return end
						if not mapgen.players[name] then return end
						player:setpos(mapgen.players[name])
					end
				end
			end
		end)
	end
end)

minetest.register_on_respawnplayer(function(player)
	if not player then return end
	local name = player:get_player_name()
	if not name then return end
	if not mapgen.players[name] then return end
	player:setpos(mapgen.players[name])
	return true
end)

local path=minetest.get_modpath("mapgen")
dofile(path.."/protect.lua")
dofile(path.."/team.lua")