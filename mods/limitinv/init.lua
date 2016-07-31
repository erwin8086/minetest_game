--[[
	Limit space in invetory based on clothings
]]

local old_update = clothing.update_inventory
function clothing.update_inventory(self, player)
	if player then
		local inv = player:get_inventory()
		local clothes = inv:get_list("clothing")
		local space=8
		for _, c in ipairs(clothes) do
			if minetest.get_item_group(c:get_name(), "clothing") > 0 then
				space=space+4
			end
		end
		local m = inv:get_list("main")
		inv:set_size("main", space)
		inv:set_list("main", {})
		for _, s in ipairs(m) do
			if inv:room_for_item("main", s) then
				inv:add_item("main", s)
			else
				minetest.item_drop(s, player, player:getpos())
			end
		end
	end
	return old_update(self, player)
end

minetest.register_on_joinplayer(function(player)
	clothing:update_inventory(player)
end)

function unified_inventory.get_player_main(player, formspec, ui_peruser, n)
	local inv = player:get_inventory()
	local block = inv:get_size("main")
	local row = block%8
	block = math.floor(block/8)
	-- Player inventory
	formspec[n] = "listcolors[#D8D8D8;#E5E5E5]"
	formspec[n+1] = "list[current_player;main;0,"..(ui_peruser.formspec_y + 3.5)..";8,"..block..";]"
	formspec[n+2] = "list[current_player;main;0,"..(ui_peruser.formspec_y + 3.5)+block..";"..row..",1;"..(block*8).."]"
	
	return formspec, n+3
end