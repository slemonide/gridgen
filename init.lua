modpath = minetest.get_modpath("gridgen")

A = 8 -- Controlls size of the dungeon rooms

function save_spawns(spawns)
	local file = io.open(minetest.get_worldpath().."/spawns.txt", "w")
	if file then
		file:write(minetest.serialize(spawns))
		file:close()
	end
end

minetest.register_on_mapgen_init(function(params) -- Automatically turn on singlenode generator
	minetest.set_mapgen_params({
		mgname = "singlenode"
	})
end)

dofile(modpath .. "/gridgen.lua")
dofile(modpath .. "/spawn.lua")
dofile(modpath .. "/undergroundgen.lua")
dofile(modpath .. "/utils.lua")
dofile(modpath .. "/nodes.lua")
