include("shared.lua")

ENT.NextEmit = 0

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	--self.Emitter:SetNearClip(10, 12)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) or CurTime() < self.NextEmit then return end

	self.NextEmit = CurTime() + 0.02

	if owner == MySelf and not owner:ShouldDrawLocalPlayer() then
		local aimvec = owner:GetAimVector()
		local aimang = owner:EyeAngles()
		local pos = owner:GetShootPos() + aimvec * 4 + aimang:Right() + aimang:Up() * -0.5

		local particle = self.Emitter:Add("sprites/light_glow02_add", pos)
		particle:SetVelocity(owner:GetVelocity() + VectorRand():GetNormalized() * math.Rand(1, 3) + Vector(0,0,2))
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(0.5, 2))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(math.cos(RealTime() * 2) * 127.5 + 127.5, math.sin(RealTime() * 2) * 127.5 + 127.5, 50)
	else
		local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		if attach then
			local pos = attach.Pos

			local emitter = self.Emitter
			for i=1, 6 do
				local particle = emitter:Add("sprites/light_glow02_add", pos)
				particle:SetVelocity(owner:GetVelocity() + VectorRand():GetNormalized() * math.Rand(1, 3) + Vector(0,0,2))
				particle:SetDieTime(0.5)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(255)
				particle:SetStartSize(math.Rand(6, 12))
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetColor(math.cos(RealTime() * 2) * 127.5 + 127.5, math.sin(RealTime() * 2) * 127.5 + 127.5, 50)
			end
		end
	end
end
