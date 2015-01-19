include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))
	self.AmbientSound = CreateSound(self, "ambient/fire/fire_med_loop1.wav")
	self.Emitter = ParticleEmitter(self:GetPos())
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(0.4, 70)
end

function ENT:Draw()
	local owner = self:GetOwner()
	if not owner:IsValid() or owner:IsInvisible() or not owner:GetStatus("weapon_spell_saber") then return end
	
	local bone = owner:LookupBone("valvebiped.bip01_r_hand")
	if bone then
		local pos, ang = owner:GetBonePosition(bone)

		local emitter = self.Emitter
		for i=1, 4 do
			local particle = emitter:Add("effects/fire_cloud"..math.random(1,2), pos + ang:Right() * 1 + ang:Forward() * 6 + VectorRand() * 2 + ang:Up() * math.random(-8,-33))
			particle:SetVelocity(owner:GetVelocity())
			particle:SetDieTime(math.Rand(0.3,0.5))
			particle:SetGravity(Vector(0,0,math.random(200,300)))
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(100)
			particle:SetStartSize(2)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle = emitter:Add("particle/particle_smokegrenade", pos + ang:Right() * 1 + ang:Forward() * 6 + VectorRand() * 2 + ang:Up() * math.random(-8,-33))
			particle:SetVelocity(owner:GetVelocity())
			particle:SetColor(50,50,50)
			particle:SetDieTime(math.Rand(0.4,0.6))
			particle:SetGravity(Vector(0,0,math.random(100,200)))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(125)
			particle:SetStartSize(0)
			particle:SetEndSize(6)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
		end
	end
end






