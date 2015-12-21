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

minetest.register_abm({
    nodenames = {"gridgen:center"}, -- Fills rooms with stuff
    interval = 1.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
	if math.random(2) == 1 then
		minetest.remove_node(pos) -- 50% chanсe the room will be free
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
