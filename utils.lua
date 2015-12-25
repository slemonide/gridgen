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
