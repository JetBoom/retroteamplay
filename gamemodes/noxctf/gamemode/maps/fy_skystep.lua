hook.Add("InitPostEntity", "Removing", function()
	for _, ent in pairs(ents.FindByClass("func_tracktrain")) do
		ent:Remove()
	end
end)