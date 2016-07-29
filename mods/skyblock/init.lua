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