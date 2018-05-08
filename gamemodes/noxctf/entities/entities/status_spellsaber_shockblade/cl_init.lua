include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))
	
	self.AmbientSound = CreateSound(self, "weapons/physcannon/energy_sing_loop4.wav")
end

function ENT:StatusThink(owner)
	local mult = LocalPlayer() == owner and owner:GetMana() < 15 and 0.33 or 1
	self.AmbientSound:PlayEx(0.5*mult, 80)
end

function ENT:Draw()
	local owner = self:GetOwner()
	
	if not owner:IsValid() or owner:IsInvisible() or not owner:GetStatus("weapon_spell_saber") then return end

	local bone = owner:LookupBone("valvebiped.bip01_r_hand")
	if bone then
		local pos, ang = owner:GetBonePosition(bone)
		local mult = LocalPlayer() == owner and owner:GetMana() < 15 and 0.66 or 1

		local emitter = ParticleEmitter(self:GetPos(), true)
		emitter:SetNearClip(24, 32)
		local particlepos = pos + ang:Right() * 1 + ang:Forward() * 4 + ang:Up() * math.random(-5,-32)
		local particle = emitter:Add("effects/select_ring", particlepos)
		particle:SetDieTime(0.1)
		particle:SetColor(255*mult,255*mult,255*mult)
		particle:SetStartAlpha(255*mult)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(5)
		ang:RotateAroundAxis(ang:Right(), 90)
		particle:SetAngles(ang)
		particle:SetVelocity(owner:GetVelocity())
		particle = emitter:Add("effects/select_ring", particlepos)
		particle:SetDieTime(0.2)
		particle:SetColor(255*mult,255*mult,255*mult)
		particle:SetStartAlpha(255*mult)
		particle:SetEndAlpha(0)
		particle:SetStartSize(0)
		particle:SetEndSize(8)
		particle:SetAngles(ang)
		particle:SetVelocity(owner:GetVelocity())
		
		emitter:Finish()
	end
end
