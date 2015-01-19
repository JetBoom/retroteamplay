ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.RegenerationPerSecond = 3
ENT.NoDrainThreshold = ENT.RegenerationPerSecond
ENT.DrainPerSecond = 40
ENT.LeechPerSecond = 70
ENT.MaxMana = 125
ENT.CanBeManaDrained = true

function ENT:GetMaxMana()
	return self:GetDTFloat(2)
end

function ENT:SetMaxMana(mana)
	self:SetDTFloat(2, mana)
end

function ENT:GetMana()
	return math.Clamp(self:GetDTFloat(0) + (CurTime() - self:GetDTFloat(1)) * self.RegenerationPerSecond, 0, self:GetMaxMana())
end

function ENT:SetMana(mana)
	self:SetDTFloat(0, mana)
	self:SetDTFloat(1, CurTime())
end