include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -40), Vector(40, 40, 40))
	self.AmbientSound = CreateSound(self, "ambient/energy/force_field_loop1.wav")
end

function ENT:StatusThink(owner)
	local mult = LocalPlayer() == owner and owner:GetMana() < 20 and 0.33 or 1
	self.AmbientSound:PlayEx(0.4*mult, 60 + math.sin(CurTime()) * 5)
end

function ENT:Draw()
	local owner = self:GetOwner()
	
	if not owner:IsValid() or owner:IsInvisible() or not owner:GetStatus("weapon_spell_saber") then return end

	local bone = owner:LookupBone("valvebiped.bip01_r_hand")
	if bone then
		local pos, ang = owner:GetBonePosition(bone)
		local mult = LocalPlayer() == owner and owner:GetMana() < 20 and 0.33 or 1

		local emitter = ParticleEmitter(self:GetPos())
		emitter:SetNearClip(24, 32)
		for i=1, 3 do
			local startpos = pos + ang:Right() * 1 + ang:Forward() * 4 + VectorRand() * 5 + ang:Up() * math.random(-8,-33)
			local endpos = pos + ang:Right() * 1 + ang:Forward() * 4 + ang:Up() * -20
			local particle = emitter:Add("effects/blueflare1", startpos)
			particle:SetDieTime(0.2)
			particle:SetColor(50*mult,50*mult,255*mult)
			particle:SetStartAlpha(255*mult)
			particle:SetEndAlpha(0)
			particle:SetStartSize(4)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetVelocity(owner:GetVelocity() + (startpos - endpos):GetNormal() * math.Rand(-14, -24))
		end
		emitter:Finish()
	end
end




