dofile(modpath .. "/gridgen.lua") -- Need this to get land_base

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

local monitor_mod_name = "hud_monitor" -- Load following modules only if hud_monitor is installed
local modnames = minetest.get_modnames()
local is_monitor = false
for i, name in ipairs(modnames) do
	if monitor_mod_name == name then
		is_monitor = true
	end
end

if is_monitor then
function print_player_elevation()
	for _,player in ipairs(minetest.get_connected_players()) do
		local pos = player:getpos()

		-- Displacement from the surface
		local elevation = math.ceil(pos.y - gen.landbase(pos.x,pos.z))
		local wording = {"above", "below"}
		local word = ""
		if elevation == 0 then
			local text = "You are at the surface level."
			hud_monitor.place(text, "elevation", player)
			break
		elseif elevation > 0 then
			word = wording[1]
		else
			word = wording[2]
		end
		local text = "You are " .. math.abs(elevation) .. " blocks " .. word .. " surface"
		hud_monitor.place(text, "elevation", player)

		-- Temperature
		local temperature = gen.heat(pos.x, pos.y, pos.z)
		hud_monitor.place("The temperature is " .. temperature .. " K or " .. temperature - 273 .. "°C", "temperature", player)
	end
	minetest.after(0.5, print_player_elevation)
end
minetest.after(0.5, print_player_elevation)
end

-- Map explorer (thanks to Echo for original code)
local explore_players = {}
local explore_steps_wait = 1*50 -- 1 second
local explore_steps_width = 50 -- jump 50 nodes

minetest.register_chatcommand('explore_start',{
    description = 'Begin map exploration',
    privs = {privs=false},
    func = function(name, params)
		local player = minetest.env:get_player_by_name(name)
		local pos = player:getpos()
		table.insert(explore_players, {name = name, x = pos.x, y = pos.y, z = pos.z, wait = 0, c = 0, l = 0, d = -90})
    end
})

minetest.register_chatcommand('explore_end',{
    description = 'End map exploration',
    privs = {privs=false},
    func = function(name, params)
		for i,v in ipairs(explore_players) do
			if v.name == name then 
				local player = minetest.env:get_player_by_name(name)
				player:setpos({x = v.x, y = v.y, z = v.z})
				table.remove(explore_players, i)
			end
		end
    end
})

minetest.register_globalstep(function(dtime)
	local players  = minetest.get_connected_players()
	for i,player in ipairs(players) do
		local player_name = player:get_player_name()
		for j,v in ipairs(explore_players) do
			if v.name == player_name then
				if v.wait == 0 then
					v.wait = explore_steps_wait
					-- turn
					if v.c == 0 then
						v.d = v.d + 90
						if v.d == 360 then v.d = 0 end
						if v.d == 0 or v.d == 180 then v.l = v.l + 1 end
						v.c = v.l
					end
					local dx = math.sin(math.rad(v.d))
					local dz = math.cos(math.rad(v.d))
					local player_pos = player:getpos()
					local x = player_pos.x + explore_steps_width * dx
					local z = player_pos.z + explore_steps_width * dz
					local y = gen.landbase(x,z) + 20
					if minetest.get_mapgen_params().water_level > y then -- Don't drown player under water
						y = minetest.get_mapgen_params().water_level
					end
					pos = {x = x, y = y, z = z}
					-- player:setpos(pos)
					player:moveto(pos)
					v.c = v.c - 1
				end
				v.wait = v.wait - 1
			end
		end
	end
end)
