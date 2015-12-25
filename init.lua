modpath = minetest.get_modpath("gridgen")

A = 8 -- Controlls size of the rooms
MAX_SPAWNS = 3000
MIN_SPAWNS = 5

function save_spawns(spawns)
	local file = io.open(minetest.get_worldpath().."/spawns.txt", "w")
	if file then
		if #spawns > MAX_SPAWNS then -- Delete old spawns if too many spawn points
		
		end
		file:write(minetest.serialize(spawns))
		file:close()
	end
end

dofile(modpath .. "/gridgen.lua")
dofile(modpath .. "/spawn.lua")
dofile(modpath .. "/roomgen.lua")
dofile(modpath .. "/utils.lua")
dofile(modpath .. "/traps.lua")
