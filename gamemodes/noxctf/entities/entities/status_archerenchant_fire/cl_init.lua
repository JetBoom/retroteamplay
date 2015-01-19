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

		local particle = self.Emitter:Add("effects/fire_cloud"..math.random(1,2), pos + VectorRand():GetNormalized() * math.Rand(0.1, 0.5))
		particle:SetVelocity(VectorRand() + owner:GetVelocity())
		particle:SetDieTime(0.4)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(0.9)
		particle:SetEndSize(0.8)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-20, 20))

		if EFFECTDLIGHTS then
			local dlight = DynamicLight(math.random(1, 999999))
			if dlight then
				dlight.Pos = pos
				dlight.r = 255
				dlight.g = 230
				dlight.b = 30
				dlight.Brightness = 6
				dlight.Decay = 50
				dlight.Size = 64
				dlight.DieTime = CurTime() + 0.3
			end
		end
	else
		local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		if attach then
			local pos = attach.Pos

			local emitter = self.Emitter
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

			if EFFECTDLIGHTS then
				local dlight = DynamicLight(math.random(1, 999999))
				if dlight then
					dlight.Pos = pos
					dlight.r = 255
					dlight.g = 230
					dlight.b = 30
					dlight.Brightness = 6
					dlight.Decay = 50
					dlight.Size = 64
					dlight.DieTime = CurTime() + 0.3
				end
			end
		end
	end
end
