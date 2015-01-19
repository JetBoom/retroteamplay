include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -40), Vector(40, 40, 40))
	self.Emitter = ParticleEmitter(self:GetPos())
	self.AmbientSound = CreateSound(self, "ambient/energy/force_field_loop1.wav")
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
	self.AmbientSound:PlayEx(0.4, 60 + math.sin(CurTime()) * 5)
end

function ENT:Draw()
	local owner = self:GetOwner()
	
	if not owner:IsValid() or owner:IsInvisible() or not owner:GetStatus("weapon_spell_saber") then return end

	local bone = owner:LookupBone("valvebiped.bip01_r_hand")
	if bone then
		local pos, ang = owner:GetBonePosition(bone)

		local emitter = self.Emitter
		for i=1, 3 do
			local startpos = pos + ang:Right() * 1 + ang:Forward() * 4 + VectorRand() * 5 + ang:Up() * math.random(-8,-33)
			local endpos = pos + ang:Right() * 1 + ang:Forward() * 4 + ang:Up() * -20
			local particle = emitter:Add("effects/blueflare1", startpos)
			particle:SetDieTime(0.2)
			particle:SetColor(50,50,255)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(4)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetVelocity(owner:GetVelocity() + (startpos - endpos):GetNormal() * math.Rand(-14, -24))
		end
	end
end




