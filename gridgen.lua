local SEA = minetest.get_mapgen_params().water_level
local SURFACE_LEVEL = 0
local DUNGEON_DEPTH = -30 -- Dungeon depth below surface (not below y=0!)
local BEACH_HEIGHT = 5 -- Above sea level
local SEED = minetest.get_mapgen_params().seed
local seed_n = math.sin(SEED)

gen = {}

function gen.ws(depth, a, x) -- Weierstrass function is used to generate surface
	local y = 0
	for k=1,depth do
		y = y + math.sin(math.pi * k^a * x)/(k^a)
	end
	return y
end

function gen.sign(x) -- sign(x) function
	if x > 0 then
		return 1
	elseif x < 0 then
		return -1
	else
		return 0
	end
end

function gen.landbase(x,z) -- Creates landscape roughness
	local land_base = gen.ws(5, 4, (x - 22200*seed_n)/1000)
	land_base = land_base + gen.ws(5, 5, (z + 55500*seed_n)/1000)
	land_base = land_base + gen.ws(5, 4, (z + x + 36734*seed_n)/2000)
	land_base = land_base + gen.ws(5, 2, (z - x - 68933*seed_n)/2000)
	land_base = land_base + gen.ws(5, 2, (x - z + 33356*seed_n)/2000)
	land_base = math.floor(50*land_base + SURFACE_LEVEL)
	return land_base
end

function gen.heat(x,y,z) -- Creates temperature map (in Kelvins)
	local heat_due_to_magic = gen.ws(2, 3, (z - 1234*seed_n)/200) + gen.ws(2, 3, (x + 122*seed_n)/200) -- 2 is there so heat is always > 0
	local temperature = math.floor(6*heat_due_to_magic - y/10 + 280) -- 280 is there to make temperature equal 5°C in the average
	return temperature
end

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

local c_stone = minetest.get_content_id("default:stone")
local c_center = minetest.get_content_id("gridgen:center")
local c_snowblock = minetest.get_content_id("default:snowblock")
local c_snow = minetest.get_content_id("default:snow")
local c_water = minetest.get_content_id("default:water_source")
local c_ice = minetest.get_content_id("default:ice")
local c_dirt = minetest.get_content_id("default:dirt")
local c_dirt_with_grass = minetest.get_content_id("default:dirt_with_grass")
local c_dirt_with_snow = minetest.get_content_id("default:dirt_with_snow")
local c_sand = minetest.get_content_id("default:sand")
local c_sandstone = minetest.get_content_id("default:sandstone")

minetest.register_on_generated(function(minp, maxp, seed)

	local t1 = os.clock()
	local geninfo = "[mg] generates..."
	minetest.chat_send_all(geninfo)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for x=minp.x,maxp.x do
		for z=minp.z,maxp.z do
			local land_base = gen.landbase(x,z)
--			local beach = math.floor(100/97*math.cos((x - z)*10/(100)))
--			local land_base = math.floor(4*(math.sin(x/60) + math.sin(z/60)) + 280)
			for y=minp.y,maxp.y do
				local temperature = gen.heat(x, y, z)
				local p_pos = area:index(x, y, z)

--				if y >= -1 then break end -- Use to create cross sections (debug)

				-- Walls
				local ax = (y+1)/A
				local bx = (x-A/2)/A
				local cx = (z-A/2)/A

				-- Center node
				local az = (y-A/2+1)/A
				local bz = x/A
				local cz = z/A

				if y < land_base + DUNGEON_DEPTH then -- Generates dungeons
					if math.ceil(ax) == ax or math.ceil(bx) == bx or math.ceil(cx) == cx then
						data[p_pos] = c_stone
					elseif math.ceil(az) == az and math.ceil(bz) == bz and math.ceil(cz) == cz
						and not (x==0 and z==0 and y==A/2-1) then -- Don't create anything at the default spawn cell
						data[p_pos] = c_center
					end
				elseif land_base < BEACH_HEIGHT and y == land_base then -- Generate beach
					data[p_pos] = c_sand
				elseif temperature <= 273 then
					if y > land_base and y <= SEA then -- Generates sea
						if temperature == 273 and math.random(2) == 1 then
							data[p_pos] = c_ice
						elseif temperature < 273 then
							data[p_pos] = c_ice
						end
					elseif y == land_base then
						data[p_pos] = c_dirt_with_snow
					elseif y == land_base - 1 then
						data[p_pos] = c_dirt
					elseif y < land_base - 1 then
						data[p_pos] = c_stone
					elseif y == land_base + 1 or y == SEA + 1 then
						if temperature <= 267 then
							data[p_pos] = c_snowblock
						elseif temperature < 273 then
							data[p_pos] = c_snow
						end
					end
				elseif temperature > 273 then
					if y > land_base and y <= SEA then -- Generates sea
						data[p_pos] = c_water
					elseif y == land_base then
						data[p_pos] = c_dirt_with_grass
					elseif y == land_base - 1 then
						data[p_pos] = c_dirt
					elseif y < land_base - 1 then
						data[p_pos] = c_stone
					end
				end
			end
		end
	end

	local t2 = os.clock()
	local calcdelay = string.format("%.2fs", t2 - t1)

	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()

	local t3 = os.clock()
	local geninfo = "[mg] done after ca.: "..calcdelay.." + "..string.format("%.2fs", t3 - t2).." = "..string.format("%.2fs", t3 - t1)
	print(geninfo)
	minetest.chat_send_all(geninfo)
end)
