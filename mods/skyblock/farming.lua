magic.register_transform("skyblock:dryleaves", {
	output = "default:dry_shrub",
	level = 1,
	mana = 0.5,
})

magic.register_transform("default:dry_shrub", {
	level=1,
	output = "default:dry_grass_1",
})

for i=1,5 do
	magic.register_infusion("default:dry_grass_"..i, {
		level=1,
		output = "default:grass_"..i
	})
end
