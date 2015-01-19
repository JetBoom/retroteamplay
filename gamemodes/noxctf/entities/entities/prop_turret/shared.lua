ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:EyePos()
	return self:GetPos() + self:GetUp() * 55
end
