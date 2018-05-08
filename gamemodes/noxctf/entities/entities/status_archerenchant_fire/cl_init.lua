include("shared.lua")

ENT.NextEmit = 0

function ENT:StatusInitialize()
end

function ENT:StatusThink(owner)
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) or CurTime() < self.NextEmit then return end

	self.NextEmit = CurTime() + 0.02
	
	local emitter = ParticleEmitter(self:GetPos())

	if owner == MySelf and not owner:ShouldDrawLocalPlayer() then
		local aimvec = owner:GetAimVector()
		local aimang = owner:EyeAngles()
		local pos = owner:GetShootPos() + aimvec * 4 + aimang:Right() + aimang:Up() * -0.5

		local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), pos + VectorRand():GetNormalized() * math.Rand(0.1, 0.5))
		particle:SetVelocity(VectorRand() + owner:GetVelocity())
		particle:SetDieTime(0.4)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(1)
		particle:SetEndSize(0.8)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))

	else
		local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		if attach then
			local pos = attach.Pos

			for i=1, 6 do
				local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), pos + VectorRand() * 2)
				particle:SetDieTime(0.4)
				particle:SetStartAlpha(200)
				particle:SetEndAlpha(100)
				particle:SetStartSize(4)
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-20, 20))
			end

		end
	end
	
	emitter:Finish()
end
