hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")

	for _, ent in pairs(ents.FindByClass("trigger_multiple")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByName("red*")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByName("blue*")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByName("build_*")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("func_wall*")) do
		ent:Remove()
	end
end)
