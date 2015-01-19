hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")

	for _, ent in pairs(ents.FindByClass("env_steam")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("env_embers")) do
		ent:Remove()
	end
end)
