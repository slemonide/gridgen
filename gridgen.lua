local SEA = 50

local function get_ws(depth, a, x) -- Used to generate surface
	local y = 0
	for k=1,depth do
		y = y + math.sin(math.pi * k^a * x/1000)/(k^a)
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

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for x=minp.x,maxp.x do
		local land_base = get_ws(5, 3, x)
		for z=minp.z,maxp.z do
			local land_base = land_base + get_ws(5, 5, z)
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

				if y < land_base - 10 then
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

	vm:set_data(data)
	vm:set_lighting({day=0, night=0})
	vm:calc_lighting()
	vm:update_liquids()
	vm:write_to_map()
end)
