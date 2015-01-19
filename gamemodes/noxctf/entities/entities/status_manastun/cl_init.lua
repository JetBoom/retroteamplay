include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	if ent:IsInvisible() then return end

	local pos

	if ent == MySelf then
		pos = ent:GetPos() + Vector(0,0,72)
	else
		local attach = ent:GetAttachment(ent:LookupAttachment("eyes"))
		if not attach then return end
		pos = attach.Pos + Vector(0,0,16)
	end

	local emitter = self.Emitter
	for i=1, 9 do
		local particle = emitter:Add("sprites/light_glow02_add", pos)
		particle:SetVelocity(VectorRand() * 40 + Vector(0,0,90))
		particle:SetDieTime(0.3)
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(8)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(20, 20, 255)
		particle:SetAirResistance(50)
	end
end
