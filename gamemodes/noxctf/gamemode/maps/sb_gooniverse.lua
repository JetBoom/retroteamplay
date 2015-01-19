hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")

	for _, ent in pairs(ents.FindByClass("func_*")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("env_*")) do
		ent:Remove()
	end
end)
