--[[
	Skyblock a mod for use with magicsky.
	Combines the other mods and adds the recipes.
	It also loads the recipes in unified_inventory.
	
	By erwin8086: WTFPL

]]

skyblock = {}

local path = minetest.get_modpath("skyblock")

dofile(path.."/api.lua")

-- Craftitems and nodes
dofile(path.."/craft.lua")

-- Active block modifiers for transform things near things
dofile(path.."/abm.lua")

-- Makes this mods compatible
dofile(path.."/default.lua")
dofile(path.."/farming.lua")
dofile(path.."/flowers.lua")
dofile(path.."/nyancat.lua")

-- Crafts for new mods
dofile(path.."/cooking.lua")
dofile(path.."/magic.lua")

-- On all finish register crafts
dofile(path.."/craftguide.lua")