local modpath = minetest.get_modpath("gridgen")

A = 8 -- Controlls size of the rooms

function save_spawns(spawns)
	local file = io.open(minetest.get_worldpath().."/spawns.txt", "w")
	if file then
		file:write(minetest.serialize(spawns))
		file:close()
	end
end

dofile(modpath .. "/gridgen.lua")
dofile(modpath .. "/spawn.lua")
dofile(modpath .. "/roomgen.lua")
dofile(modpath .. "/commands.lua")
dofile(modpath .. "/traps.lua")
