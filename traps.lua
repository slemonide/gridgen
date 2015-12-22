minetest.register_abm({
	nodenames = {"group:suffocate"},
	interval = 1,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local all_objects = minetest.get_objects_inside_radius(pos, 1)
		for _,obj in ipairs(all_objects) do
			obj:set_hp(obj:get_hp() - 4)
		end
	end,
})

minetest.register_node("gridgen:falling_stone", {
	description = "Falling Stone",
	tiles = {"default_stone.png".."^[brighten"},
	groups = {cracky=3, stone=1, suffocate=1},
	drop = 'gridgen:falling_stone',
})

minetest.register_abm({
	nodenames = {"gridgen:falling_stone"},
	interval = 2,
	chance = 1,
	action = function(pos, node, active_object_count, active_object_count_wider)
		local under = {x=pos.x, y=pos.y-1, z=pos.z}
		if minetest.get_node(under).name ~= "air" then
			return
		end
		local median = {x=pos.x, y=pos.y-A/2, z=pos.z} -- A/2 -- center of the cell
		local all_objects = minetest.get_objects_inside_radius(median, A/2)
		for _,obj in ipairs(all_objects) do
			local pos_o = obj:getpos()
			if pos_o.y < pos.y then
				minetest.set_node(under, {name = "gridgen:falling_stone"})
			end
		end
	end,
})
