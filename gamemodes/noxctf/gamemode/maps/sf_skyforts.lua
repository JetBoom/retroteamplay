hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")

	for _, ent in pairs(ents.FindByName("wall")) do
		ent:SetName("build_wall")
	end
end)
