hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")

	for _, ent in pairs(ents.FindByClass("env_smokestack")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("func_button")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("func_door")) do
		ent:Remove()
	end
end)
