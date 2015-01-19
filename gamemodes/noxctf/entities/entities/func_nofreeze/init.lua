ENT.Type = "brush"

function ENT:Initialize()
end

function ENT:Think()
end

function ENT:KeyValue(key, value)
	if string.lower(key) == "buildonly" then
		self.BuildOnly = tonumber(value) == 1
		return true
	end
end

function ENT:StartTouch(ent)
	if ent.PHealth then
		ent.NoFreeze = true
	end
end

function ENT:EndTouch(ent)
	if ent.NoFreeze then
		ent.NoFreeze = nil
	end
end

function ENT:Touch(ent)
end
