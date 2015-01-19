hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")

	for _, ent in pairs(ents.FindByClass("trigger_multiple")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("func_door")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByName("field")) do
		ent:SetName("build_wall")
	end
end)
