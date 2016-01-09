minetest.register_abm({
	nodenames = {"group:suffocate"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local all_objects = minetest.get_objects_inside_radius(pos, 1)
		for _,obj in ipairs(all_objects) do
			obj:set_hp(obj:get_hp() - 4)
			local message = "You are suffocating!"
			if obj:is_player() then
				local name = obj:get_player_name()
				minetest.chat_send_player(name, message)
			end
		end
	end,
})
-- Falling stone
minetest.register_node("gridgen:falling_stone", {
	description = "Falling Stone",
	tiles = {"default_stone.png".."^[brighten"},
	groups = {cracky=3, stone=1, suffocate=1},
	drop = 'gridgen:falling_stone',
})

minetest.register_abm({
	nodenames = {"gridgen:falling_stone"},
	neighbors = {"air"},
	interval = 3,
	chance = 3,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local under = {x=pos.x, y=pos.y-1, z=pos.z}
		if minetest.get_node(under).name ~= "air" then
			return
		end
		local median = {x=pos.x, y=pos.y-A/2, z=pos.z} -- A/2 -- center of the cell
		local all_objects = minetest.get_objects_inside_radius(median, A/2)
		for _,obj in ipairs(all_objects) do
			local pos_o = obj:getpos()
			if pos_o.y < pos.y
			and pos.x - 0.5 < pos_o.x and pos_o.x < pos.x + 0.5
			and pos.z - 0.5 < pos_o.z and pos_o.z < pos.z + 0.5 then
				local current = {}
				while minetest.get_node(under).name == "air" do
					current = under
					under = {x=under.x, y=under.y-1, z=under.z}
				end
				minetest.set_node(current, {name = "gridgen:falling_stone"})
			end
		end
	end,
})
-- Chlorine gas
minetest.register_node("gridgen:chlorine_gas", {
	description = "Chlorine Gas",
	alpha = 100,
	tiles = {"default_cobble.png".."^[makealpha:128,128,128".."^[brighten"},
	groups = {cracky=3, stone=1, suffocate=1},
})

minetest.register_node("gridgen:chlorine_gas_percipitate", {
	description = "Chlorine Gas Percipirtate",
	tiles = {"default_dirtn.png".."^[brighten"},
	groups = {cracky=3, stone=1},
})
