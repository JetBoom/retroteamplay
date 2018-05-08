ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.CanTakeMana = true

function ENT:SetImmunity(time)
	self:SetDTFloat(0, time)
end

function ENT:GetImmunity()
	return self:GetDTFloat(0)
end
