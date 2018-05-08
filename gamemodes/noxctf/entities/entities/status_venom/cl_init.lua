include("shared.lua")

function ENT:StatusInitialize()
end

function ENT:StatusThink(owner)
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or owner:IsInvisible() then return end

	local pos
	if owner ~= MySelf or (owner == MySelf and owner:ShouldDrawLocalPlayer()) then
		local attach = owner:GetAttachment(owner:LookupAttachment("mouth"))
		if attach then
			pos = attach.Pos
		end
	end

	if pos then
		local a = owner:GetVisibility()

		local emitter = ParticleEmitter(self:GetPos())
		for i=1, 2 do
			particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand())
			particle:SetDieTime(0.6)
			particle:SetStartAlpha(a)
			particle:SetEndAlpha(a * 0.25)
			particle:SetStartSize(3)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-0.8, 0.8))
			particle:SetColor(30, 255, 30)
			particle:SetAirResistance(75)
			particle:SetGravity(Vector(0, 0, -200))
			particle:SetCollide(true)
		end
		emitter:Finish()
	end
end
