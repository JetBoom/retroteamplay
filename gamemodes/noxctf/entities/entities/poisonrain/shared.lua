ENT.Type = "anim"

function ENT:SetStartTime(time)
	self:SetDTFloat(0, time)
end

function ENT:GetStartTime()
	return self:GetDTFloat(0)
end