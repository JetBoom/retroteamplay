hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")

	for _, ent in pairs(ents.FindByClass("func_wall_toggle")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("func_button")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("trigger_push")) do
		ent:Remove()
	end
end)
