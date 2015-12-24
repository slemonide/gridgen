local SEA = minetest.get_mapgen_params().water_level

local SEED = minetest.get_mapgen_params().seed

local seed_n = math.sin(SEED)

local function get_ws(depth, a, x) -- Used to generate surface
	local y = 0
	for k=1,depth do
		y = y + math.sin(math.pi * k^a * x)/(k^a)
	end
	return y
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
local c_snow = minetest.get_content_id("default:snowblock")
local c_water = minetest.get_content_id("default:water_source")

minetest.register_on_generated(function(minp, maxp, seed)

	local t1 = os.clock()
	local geninfo = "[mg] generates..."
	print(SEED)
	minetest.chat_send_all(geninfo)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for x=minp.x,maxp.x do
		local land_base = get_ws(5, 3, (x - 22200*seed_n)/1000)
		for z=minp.z,maxp.z do
			local land_base = land_base + get_ws(5, 5, (z + 55500*seed_n)/1000)
			land_base = land_base + get_ws(5, 4, (z + x + 36734*seed_n)/2000)
			land_base = land_base + get_ws(5, 3, (z - x - 68933*seed_n)/2000)
			land_base = land_base + get_ws(5, 2, (x - z + 33356*seed_n)/2000)
			local mountain_a = 8*get_ws(5, 3, (z + 36734*seed_n)/2000)
			local mountain_b = 8*get_ws(5, 2, (x - 74927*seed_n)/1000)
			if mountain_a > 0 and mountain_b > 0 then
				land_base = land_base + mountain_a + mountain_b
			end
			land_base = math.floor(50*land_base + SEA)
			for y=minp.y,maxp.y do

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

				if y < land_base - 20 then
					if math.ceil(ax) == ax or math.ceil(bx) == bx or math.ceil(cx) == cx then
						data[p_pos] = c_stone
					elseif math.ceil(az) == az and math.ceil(bz) == bz and math.ceil(cz) == cz
						and not (x==0 and z==0 and y==A/2-1) then -- Don't create anything at the default spawn cell
						data[p_pos] = c_center
					end

				elseif y < land_base then -- Generates surface
					data[p_pos] = c_snow
				elseif y >= land_base and y <= SEA then -- Generates sea
					data[p_pos] = c_water
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
