--[[
How rooms are selected:
	25% -- free
	25% -- filled with constructions and traps (currently free)
	50% -- resources (50% fields, 50% filled completely)
--]]

local freebie_blocks = { -- Stuff that fills the room completely
		"default:water_source",
		"default:lava_source",
		"default:desert_stone",
		"default:sand",
		"default:gravel",
		"default:clay",
		"default:ice",
		"default:tree",
		"default:jungletree",
		"default:pine_tree",
		"default:acacia_tree",
		"default:stone_with_coal",
		"default:stone_with_iron",
		"default:stone_with_copper",
		"default:stone_with_gold",
		"default:stone_with_mese",
		"default:stone_with_diamond"
		}

local freebie_plants = { -- Plants that are placed on the grass
		"flowers:rose",
		"flowers:tulip",
		"flowers:dandelion_yellow",
		"flowers:geranium",
		"flowers:viola",
		"flowers:dandelion_white",
		"default:junglegrass"
		}

local freebie_plants_desert = { -- Plants that are placed on the sand
		"default:cactus",
		"default:papyrus",
		"default:dry_shrub"
		}

minetest.register_abm({
    nodenames = {"gridgen:center"}, -- Fills rooms with stuff
    interval = 1.0,
    chance = 1,
    action = function(pos, node, active_object_count, active_object_count_wider)
	minetest.remove_node(pos) -- Delete node so rooms won't overgenerate
	if math.random(2) == 1 then -- 50% of a free room, room with constructions or room with traps
		if math.random(2) == 1 then -- 50% * 50% free rooms
			table.insert(spawns, pos)
			save_spawns(spawns)
		else
			local random = math.random(4)
			if random == 1 then -- 50% * 25% nyancat will spawn
				if math.random(2) == 1 then -- another 50%
					minetest.set_node(pos, {name = "default:nyancat"})
					for Y=-4,-1 do
						local pos_n = {x=pos.x,y=pos.y+Y,z=pos.z}
						minetest.set_node(pos_n, {name = "default:nyancat_rainbow"})
					end
				end
			elseif random == 2 then -- 50% * 25% falling ceiling trap
				for X=-A/4-1,A/4+1 do
				for Z=-A/4-1,A/4+1 do
					local pos_a = {x=pos.x+X,y=pos.y+A/4+1,z=pos.z+Z}
					minetest.set_node(pos_a, {name = "gridgen:falling_stone"})
				end
				end				
			end
		end
		return
	end

	if math.random(2) == 1 then -- 50% * 25% chance of a completely filled room
		local block = freebie_blocks[math.random(#freebie_blocks)]
		for X=-A/4-1,A/4+1 do
		for Y=-A/4-1,A/4+1 do
		for Z=-A/4-1,A/4+1 do
			local pos_n = {x=pos.x+X,y=pos.y+Y,z=pos.z+Z}
			minetest.set_node(pos_n, {name = block})
		end
		end
		end
		return
	end

	local random = math.random(3) -- 33% * 50% * 25% chance of a particular field
	if random == 1 then
		for X=-A/4-1,A/4+1 do
		for Z=-A/4-1,A/4+1 do
			local pos_a = {x=pos.x+X,y=pos.y-A/4-1,z=pos.z+Z}
			minetest.set_node(pos_a, {name = "default:dirt_with_grass"})
			local plant = freebie_plants[math.random(#freebie_plants)]
			local pos_b = {x=pos.x+X,y=pos.y-A/4,z=pos.z+Z}
			minetest.set_node(pos_b, {name = plant})
		end
		end
		return
	end

	if random == 2 then
		for X=-A/4-1,A/4+1 do
		for Z=-A/4-1,A/4+1 do
			local pos_a = {x=pos.x+X,y=pos.y-A/4-1,z=pos.z+Z}
			minetest.set_node(pos_a, {name = "default:desert_sand"})
			local plant = freebie_plants_desert[math.random(#freebie_plants_desert)]
			local pos_b = {x=pos.x+X,y=pos.y-A/4,z=pos.z+Z}
			minetest.set_node(pos_b, {name = plant})
		end
		end
		return
	end

	if random == 3 then
		for X=-A/4-1,A/4+1 do
		for Z=-A/4-1,A/4+1 do
			local pos_a = {x=pos.x+X,y=pos.y-A/4-1,z=pos.z+Z}
			minetest.set_node(pos_a, {name = "default:dirt_with_grass"})
			local plant = freebie_plants_desert[math.random(#freebie_plants_desert)]
			local pos_b = {x=pos.x+X,y=pos.y-A/4,z=pos.z+Z}
			minetest.set_node(pos_b, {name = plant})
		end
		end
		return
	end
    end,
})
