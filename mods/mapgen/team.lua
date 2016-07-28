local mapgen = skygen.save
mapgen.team = mapgen.team or {}
local team = mapgen.team
team.teams = team.teams or {}

minetest.register_chatcommand("goto", {
	params = "<playername>",
	description = "Goto players spawn",
	privs = {interact=true},
	func = function(name, param)
		if not name then return end
		local player = minetest.get_player_by_name(name)
		if not player or not param then return end
		local p = mapgen.players[param]
		if p then
			player:setpos(p)
		end
	end,
})

-- Check team of player(name)
local function is_team(name)
	for t, def in pairs(team.teams) do
		if def.players then
			for _, n in ipairs(def.players) do
				if n == name then
					return t
				end
			end
		end
	end
end

local function do_protect(name, spawn)
	skygen.protect[name] = {x=spawn.x-64, y=spawn.z-64}
end

local function join(player, t, pw)
	local name = player:get_player_name()
	if not name then return end
	local def = team.teams[t]
	if not def then return 0, "Team does not exists!" end
	if not def.pw == pw then return 0, "Incorrect password!" end
	for _, n in ipairs(def.players) do
		if n == name then
			return 0, "You are already in this team!"
		end
	end
	def.players[#def.players+1] = name
	mapgen.players[name] = def.spawn
	player:setpos(def.spawn)
	do_protect(name, def.spawn)
	skygen.savedata()
	print(name.." joins team "..t.." using password:"..pw)
	return 0, "You joined the team"
end

local function new(player, t, pw)
	local name = player:get_player_name()
	if not name then return end
	if is_team(name) then return 0, "You are in a team!" end
	if team.teams[t] then return 0, "Team exists!" end
	local new = {}
	new.spawn = mapgen.players[name] or {x=0, y=0, z=0}
	new.pw = pw
	new.players = {name}
	team.teams[t] = new
	print(name.." creates team "..t.." with password:"..pw)
	skygen.savedata()
	return 0, "You have created new team "..t
end

local function leave(player, t)
	local name = player:get_player_name()
	if not name then return end
	local def = team.teams[t]
	if not is_team(name) == t then return 0, "You are not in this team!" end
	if not team.teams[t] or not team.teams[t].players then return 0, "This team does not exist!" end
	for i, p in ipairs(team.teams[t].players) do
		if p==name then
			team.teams[t].players[i] = nil
		end
	end
	def.players[name] = nil
	mapgen.players[name] = nil
	skygen.new_spawn(player)
	print(name.." leaves team "..t)
	return 0, "You leaves this team"
end

minetest.register_chatcommand("team", {
	params = "[new|join|leave] <team> [password]",
	description = "Create, joins or leaves a team\n<team> are only a-zA-z (Hello for example)\n[password] only 0-9 (1234 for example) and only for join and new",
	privs = {interact=true},
	func = function(name, param)
		if not name then return end
		local player = minetest.get_player_by_name(name)
		if not player or not param then return end
		local f, team, pw = param:match("(%a+)%s+(%a+)%s*(%d*)")
		if pw == "" then pw=nil end
		if f == "join" then
			if not team or not pw then return end
			return join(player, team, pw)
		elseif f == "new" then
			if not team or not pw then return end
			return new(player, team, pw)
		elseif f == "leave" then
			if not team or team == "" then return end
			return leave(player, team)
		else
			return 0, "/team [new|join|leave] <team> [password]"
		end
	end,
})