include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))
	
	self.AmbientSound = CreateSound(self, "ambient/levels/canals/toxic_slime_loop1.wav")

	self.NextEmit = 0
end

function ENT:StatusThink(owner)
	local mult = LocalPlayer() == owner and owner:GetMana() < 25 and 0.33 or 1
	self.AmbientSound:PlayEx(0.6*mult, 90)
end

function ENT:Draw()
	local owner = self:GetOwner()
	
	if not owner:IsValid() or owner:IsInvisible() or not owner:GetStatus("weapon_spell_saber") then return end

	local bone = owner:LookupBone("valvebiped.bip01_r_hand")
	if bone then
		local pos, ang = owner:GetBonePosition(bone)
		local mult = LocalPlayer() == owner and owner:GetMana() < 25 and 0.33 or 1

		local emitter = ParticleEmitter(self:GetPos())
		emitter:SetNearClip(24, 32)
		for i=1, 12 do
			local particle = emitter:Add("effects/blood2", pos + ang:Right() * 1 + ang:Forward() * 4 + VectorRand() * 2 + ang:Up() * math.random(-8,-33))
			particle:SetDieTime(0.2)
			particle:SetColor(math.random(90,125)*mult,0,0)
			particle:SetStartAlpha(255*mult)
			particle:SetEndAlpha(255*mult)
			particle:SetStartSize(2)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetVelocity(owner:GetVelocity())
		end
		if self.NextEmit < CurTime() then
			self.NextEmit = CurTime() + math.Rand(0.05,0.2)
			for i=1, 2 do
				local particle = emitter:Add("effects/blood_core", pos + ang:Right() * 1 + ang:Forward() * 4 + ang:Up() * math.random(-8,-33))
				particle:SetDieTime(1.5)
				particle:SetColor(130*mult,0,0)
				particle:SetStartAlpha(255*mult)
				particle:SetEndAlpha(255*mult)
				particle:SetStartLength(7)
				particle:SetEndLength(1)
				particle:SetStartSize(2)
				particle:SetEndSize(0)
				particle:SetGravity(Vector(0,0,-400))
				particle:SetVelocity(owner:GetVelocity())
			end
		end
		emitter:Finish()
	end
end
