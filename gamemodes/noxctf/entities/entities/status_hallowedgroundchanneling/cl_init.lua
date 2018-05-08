include("shared.lua")

ENT.NextEmit = 0
function ENT:StatusInitialize()
end

function ENT:StatusThink(owner)
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if CurTime() > self.NextEmit then
		self.NextEmit = CurTime() + 0.5

		local emitter = ParticleEmitter(self:GetPos())
		emitter:SetNearClip(24, 32)

		local pos = owner:GetPos() + Vector(0, 0, 10)

		sound.Play("nox/healringend.ogg", pos)

		for i=1, 360 do
			local particle = emitter:Add("sprites/glow04_noz", pos + Vector(22 * math.cos(i), 22 * math.sin(i), 0))
			particle:SetVelocity(Vector(370 * math.cos(i), 370 * math.sin(i), 0))
			particle:SetDieTime(1)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(42)
			particle:SetEndSize(28)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-16, 16))
			particle:SetColor(180, 255, 180)
		end

		emitter:Finish()
	end
end
