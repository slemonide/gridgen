local SEA = minetest.get_mapgen_params().water_level
local SURFACE_LEVEL = 0
local DUNGEON_DEPTH = -30 -- Dungeon depth below surface (not below y=0!)
local BEACH_HEIGHT = 5 -- Above sea level
local CRESTS_HEIGHT = 400 -- Distance from y=0 at which crests and valleys start
local SEED = minetest.get_mapgen_params().seed
local seed_n = math.sin(SEED)

gen = {}
local abs = math.abs
local pi = math.pi
local sin = math.sin
local distance = math.hypot

function gen.ws(depth, a, x) -- Weierstrass function is used to generate surface
	local y = 0
	for k=1,depth do
		y = y + math.sin(math.pi * k^a * x)/(k^a)
	end
	return y
end

function gen.landbase(x,z) -- Creates landscape roughness
	local x = x/6
	local z = z/6
	local land_base = gen.ws(4, 3, (x + z - pi/360*seed_n)/500)
	land_base = land_base + gen.ws(4, 3, (z + pi/360*seed_n)/500)
	land_base = land_base*(gen.ws(4, 3, (x - z*land_base - 7*pi/360*seed_n)/600) + gen.ws(4, 3, (z + x + 7*pi/360*seed_n)/600))
	land_base = math.floor(50*land_base*3 + SURFACE_LEVEL - 8)

	if abs(land_base) >= CRESTS_HEIGHT then
		if land_base > 0 then
			land_base = 2*land_base - CRESTS_HEIGHT -- create crests and valleys
		else
			land_base = 2*land_base + CRESTS_HEIGHT
		end
	end

	return land_base
end

function gen.heat(x,y,z) -- Creates temperature map (in Kelvins)
	local heat_due_to_magic = gen.ws(2, 3.2, (x + 13*pi/360*seed_n)/1000) + gen.ws(2, 3.2, (z - 13*pi/360*seed_n)/1000)
	local temperature = math.floor(3*heat_due_to_magic - y/10 + x/400 + 279)
	if temperature < 0 then -- Can't be below absolute zero
		temperature = 0
	end
	return temperature
end

function gen.get_node(x,y,z,land_base,temperature)

	local node = "air"

--	if y >= -1 then break end -- Use to create cross sections (debug)

	-- Helpers for the generation of the dungeons
	-- Walls
	local ax = (y+1)/A
	local bx = (x-A/2)/A
	local cx = (z-A/2)/A
	-- Center node
	local az = (y-A/2+1)/A
	local bz = x/A
	local cz = z/A

	if y < land_base + DUNGEON_DEPTH and abs(y) < CRESTS_HEIGHT + DUNGEON_DEPTH then -- Generates dungeons
		if math.ceil(ax) == ax or math.ceil(bx) == bx or math.ceil(cx) == cx then
			node = "default:stone"
		elseif math.ceil(az) == az and math.ceil(bz) == bz and math.ceil(cz) == cz
			and not (x==0 and z==0 and y==A/2-1) then -- Don't create anything at the default spawn cell
			node = "gridgen:center"
		end
	elseif y == land_base and land_base < BEACH_HEIGHT then -- Generate beach
		node = "default:sand"
	elseif temperature <= 273 then -- Snow
		if y > land_base and y <= SEA then -- Generates sea
			if temperature == 273 and math.random(2) == 1 then
				node = "default:ice"
			elseif temperature < 273 then
				node = "default:ice"
			else
				node = "default:water_source"
			end
		elseif y == land_base then
			node = "default:dirt_with_snow"
		elseif y == land_base - 1 then
			node = "default:dirt"
		elseif y < land_base - 1 then
			node = "default:stone"
		elseif y == land_base + 1 or y == SEA + 1 then
			if temperature <= 267 then
				node = "default:snowblock"
			elseif temperature < 273 then
				node = "default:snow"
			end
		end
	elseif temperature > 283 then -- Deserts
		if y == land_base then
			node = "default:desert_sand"
		elseif y == land_base - 1 then
			node = "default:desert_stone"
		elseif y < land_base - 1 then
			node = "default:stone"
		elseif y > land_base and y <= SEA then -- Generates sea
			node = "default:water_source"
		else
		end
	elseif temperature > 273 then -- Green
		if y > land_base and y <= SEA then -- Generates sea
			node = "default:water_source"
		elseif y == land_base then
			if temperature < 275 or temperature > 280 then -- Below 2°C grass will dry
				node = "default:dirt_with_dry_grass"
			else
				node = "default:dirt_with_grass"
			end
		elseif y == land_base - 1 then
			node = "default:dirt"
		elseif y < land_base - 1 then
			node = "default:stone"
		end
	end

	return node
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

minetest.register_on_generated(function(minp, maxp, seed)

	local t1 = os.clock()
--	local geninfo = "[mg] generates..."
--	minetest.chat_send_all(geninfo)

	local vm, emin, emax = minetest.get_mapgen_object("voxelmanip")
	local data = vm:get_data()
	local area = VoxelArea:new{MinEdge=emin, MaxEdge=emax}

	for x=minp.x,maxp.x do
		for z=minp.z,maxp.z do
			local land_base = gen.landbase(x,z)
			for y=minp.y,maxp.y do
				local temperature = gen.heat(x, y, z)
				local p_pos = area:index(x, y, z)
				local node = gen.get_node(x,y,z,land_base,temperature)
				local c_node = minetest.get_content_id(node)
				data[p_pos] = c_node
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
--	minetest.chat_send_all(geninfo)
end)
