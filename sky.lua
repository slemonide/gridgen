minetest.register_on_joinplayer(function(player)
      minetest.setting_set("enable_clouds", 0)
end)
--[[
function set_skybox()
	for _,player in ipairs(minetest.get_connected_players()) do
	local pos = player:getpos()

	local y = pos.y
	local l = 200 -- skybox length
	local r = 200 -- distance to skybox
	local R = 500 -- distance to horizon

	local n = 100*(0.5*l - y*r/R)/l -- % of sea on the skybox

	local skytextures = {
		"sky_top.png", -- +y
		"sky_water.png", -- -y
		"sky_top.png^[lowpart:".. n ..":sky_water.png", -- +z
		"sky_top.png^[lowpart:".. n ..":sky_water.png", -- -z
		"sky_top.png^[lowpart:".. n ..":sky_water.png", -- -x
		"sky_top.png^[lowpart:".. n ..":sky_water.png", -- +x
	}
	player:set_sky({}, "skybox", skytextures)
	end
end

local timer = 0
minetest.register_globalstep(function(dtime)
	timer = timer + dtime;
	if timer >= 0.5 then
		set_skybox()
	end
end)
--]]
