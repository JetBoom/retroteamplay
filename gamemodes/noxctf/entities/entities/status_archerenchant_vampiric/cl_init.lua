include("shared.lua")

ENT.NextEmit = 0

function ENT:StatusInitialize()
end

function ENT:StatusThink(owner)
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	
	local emitter = ParticleEmitter(self:GetPos())

	if owner:IsInvisible() or RealTime() < self.NextEmit then return end
	self.NextEmit = RealTime() + 0.03 + EFFECT_IQUALITY * 0.02

	if owner == MySelf and not owner:ShouldDrawLocalPlayer() then
		local aimvec = owner:GetAimVector()
		local aimang = owner:EyeAngles()
		local pos = owner:GetShootPos() + aimvec * 4 + aimang:Right() + aimang:Up() * -0.5

		local particle = emitter:Add("effects/blood", pos + VectorRand():GetNormal())
		particle:SetVelocity(VectorRand() + owner:GetVelocity())
		particle:SetDieTime(0.4)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(1)
		particle:SetEndSize(0.8)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(255, 30, 30)
	else
		local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		if attach then
			local pos = attach.Pos

			for i=1, 3 do
				local particle = emitter:Add("effects/blood", pos + VectorRand():GetNormal())
				particle:SetVelocity(VectorRand() + owner:GetVelocity())
				particle:SetDieTime(0.4)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(3.5)
				particle:SetEndSize(3.5)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetColor(255, 30, 30)
			end
		end
	end
	
	emitter:Finish()
end
