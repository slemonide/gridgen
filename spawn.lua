local MINIMUM_SPAWNS = 5

spawns = {{x=0,y=0,z=0}} -- Possible spawn positions with default one

local file = io.open(minetest.get_worldpath().."/spawns.txt", "r")
if file then
	local data = minetest.deserialize(file:read("*all"))
	if not data then
		return
	end
	if #data > MINIMUM_SPAWNS then
		spawns = data
	end
	print("Number of spawn points is " .. #data)
	file:close()
end

local function give_initial_stuff(player)
	player:get_inventory():add_item('main', 'default:pick_wood')
	player:get_inventory():add_item('main', 'default:torch 99')
end

local function spawn(player)
	local choice = math.random(#spawns)
	local spawn = spawns[choice]
	if #spawns > 5 then
		table.remove(spawns, choice)
	end
	save_spawns(spawns)
	player:setpos(spawn)
end

minetest.register_on_newplayer(function(player)
	spawn(player)
	give_initial_stuff(player)
end)

minetest.register_on_respawnplayer(function(player)
	spawn(player)
	player:get_inventory():set_list("main", {})
	player:get_inventory():set_list("craft", {})
	give_initial_stuff(player)
	return true
end)
