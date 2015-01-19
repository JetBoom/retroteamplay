hook.Add("InitPostEntity", "Adding", function()
	hook.Remove("InitPostEntity", "Adding")

	for _, ent in pairs(ents.FindByClass("func_dustcloud")) do ent:Remove() end
	for _, ent in pairs(ents.FindByClass("prop_dynamic")) do if not string.find(ent:GetModel(), "shell", 1, true) then ent:Remove() end end
end)
