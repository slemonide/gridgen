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
