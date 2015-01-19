ENT.Type = "anim"
ENT.Base = "status__base"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
--ENT.DieTime = 10

function ENT:GetBlades()
	return self:GetDTInt(0)
end

function ENT:SetBlades(blades)
	self:SetDTInt(0, blades)
end
