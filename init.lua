minetest.register_node("gridgen:center", { -- Marks center of the room
    description = "Center Node",
    drawtype = "airlike",
    walkable = false,
    pointable = false,
    diggable = false,
    buildable_to = true,
    climbable = false,
    sunlight_propagates = true,
    groups = {not_in_creative_inventory=1},
})

A = 8 -- Controlls size of the rooms

local c_stone = minetest.get_content_id("default:stone")
local c_center = minetest.get_content_id("gridgen:center")

minetest.register_on_generated(function(minp, maxp, seed)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for x=minp.x,maxp.x do
	for z=minp.z,maxp.z do
	for y=minp.y,maxp.y do
		local p_pos = area:index(x, y, z)

--		if y >= -1 then break end -- Use to create cross sections (debug)

		-- Walls
		local ax = (y+1)/A
		local bx = (x-A/2)/A
		local cx = (z-A/2)/A

		-- Center node
		local az = (y-A/2+1)/A
		local bz = x/A
		local cz = z/A

		if math.ceil(ax) == ax or math.ceil(bx) == bx or math.ceil(cx) == cx then
			data[p_pos] = c_stone
		elseif math.ceil(az) == az and math.ceil(bz) == bz and math.ceil(cz) == cz
			and not (x==0 and z==0 and y==2+A) then -- Don't create anything at the default spawn cell
			data[p_pos] = c_center
		end
	end
	end
	end

	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()
end)

local freebie = { -- Stuff that is placed in the rooms
		"default:water_source",
		"default:lava_source",
		"default:desert_stone",
		"default:dirt",
		"default:sand",
		"default:desert_sand",
		"default:gravel",
		"default:clay",
		"default:snowblock",
		"default:ice",
		"default:tree",
		"default:leaves",
		"default:jungletree",
		"default:jungleleaves",
		"default:pine_tree",
		"default:pine_needles",
		"default:acacia_tree",
		"default:acacia_leaves",
		"default:stone_with_coal",
		"default:stone_with_iron",
		"default:stone_with_copper",
		"default:stone_with_gold",
		"default:stone_with_mese",
		"default:stone_with_diamond"
		}

local spawns = {{x=0,y=0,z=0}} -- Possible spawn positions with default one

local saved_spawns = minetest.setting_get("spawns")
if saved_spawns then
	spawns = minetest.deserialize(saved_spawns)
end

minetest.register_abm({
    nodenames = {"gridgen:center"}, -- Fills rooms with stuff
    interval = 1.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
	if math.random(2) == 1 then
		minetest.remove_node(pos) -- 50% chanse the room will be free
		table.insert(spawns, pos)
		minetest.setting_set("spawns", minetest.serialize(spawns))
		return
	end

	local block = freebie[math.random(#freebie)]

	for X=-A/4-1,A/4+1 do
	for Y=-A/4-1,A/4+1 do
	for Z=-A/4-1,A/4+1 do
		local pos_n = {x=pos.x+X,y=pos.y+Y,z=pos.z+Z}
		minetest.set_node(pos_n, {name = block})
	end
	end
	end

    end,
})

local function give_initial_stuff(player)
	player:get_inventory():add_item('main', 'default:pick_wood')
	player:get_inventory():add_item('main', 'default:torch 99')
end

local function spawn(player)
	local choice = math.random(#spawns)
	local spawn = spawns[choice]
	table.remove(spawns, choice)
	minetest.setting_set("spawns", minetest.serialize(spawns))
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

minetest.register_chatcommand("killme", { -- For those who are stuck
	params = "",
	description = "Kills yourself.",
	func = function(name, param)
		if(minetest.setting_getbool("enable_damage")==true) then
			local player = minetest.get_player_by_name(name)
			if not player then
				return
			end
			player:set_hp(0)
		else
			minetest.chat_send_player(name, "Damage is disabled on this server. This command does not work when damage is disabled.")
		end
	end,
})
