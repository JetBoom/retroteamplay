ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.m_IsProjectile = true

util.PrecacheModel("models/props_wasteland/rockcliff01b.mdl")
util.PrecacheModel("models/props_wasteland/rockcliff01c.mdl")
util.PrecacheSound("physics/glass/glass_largesheet_break1.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break2.wav")
util.PrecacheSound("physics/glass/glass_largesheet_break3.wav")

function ENT:SetFreezes(freeze)
	self:SetDTBool(0, freeze)
end

function ENT:GetFreezes()
	return self:GetDTBool(0)
end

ENT.Freezes = ENT.GetFreezes
