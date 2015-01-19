hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")

	for _, ent in pairs(ents.FindByClass("func_physbox")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("trigger_hurt")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("trigger_multiple")) do
		ent:Remove()
	end
end)
