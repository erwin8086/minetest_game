--[[
	Protect player spawn while player online
]]

local mapgen = skygen.save

local protect = {}

skygen.protect = protect

minetest.register_on_joinplayer(function(player)
	-- Wait for new player spawn
	minetest.after(2, function()
		local name = player:get_player_name()
		if not name then return end
		local spawn = mapgen.players[name]
		if not spawn then return end
		protect[name] = {x=spawn.x-64, y=spawn.z-64}
	end)
end)

minetest.register_on_leaveplayer(function(player)
	local name = player:get_player_name()
	if not name then return end
	protect[name]=nil
end)

local old_protect = minetest.is_protected
function minetest.is_protected(pos, name)
	local p
	for n, area in pairs(protect) do
		if pos.x >= area.x and pos.x <= area.x+128 and pos.z >= area.y and pos.z <= area.y+128 then
			if n==name then
				p=false
			elseif p==nil then
				p=true
			end
		end
	end
	return (p or old_protect(pos, name)) and not minetest.check_player_privs(name, "protection_bypass")
end

