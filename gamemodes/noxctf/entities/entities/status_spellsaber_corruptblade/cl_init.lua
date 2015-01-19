include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))
	
	self.AmbientSound = CreateSound(self, "npc/fast_zombie/breathe_loop1.wav")
	self.Emitter = ParticleEmitter(self:GetPos())

	self.Skull = ClientsideModel("models/Gibs/HGIBS.mdl", RENDERGROUP_TRANSLUCENT)
	self.Skull:SetModelScale( 0.7, 0 )
	self.Skull:SetRenderMode( RENDERMODE_TRANSALPHA )
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
	self.Skull:Remove()
end

function ENT:StatusThink(owner)
	self.AmbientSound:PlayEx(0.7, 40)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:Draw()
	local owner = self:GetOwner()
	
	if (owner:IsInvisible() or not owner:GetStatus("weapon_spell_saber")) and self.Skull then
		self.Skull:SetColor(Color(120,20,255,0))
	else
		self.Skull:SetColor(Color(120,20,255,255))
	end
	
	if not owner:IsValid() or owner:IsInvisible() or not owner:GetStatus("weapon_spell_saber") then return end
	
	local bone = owner:LookupBone("valvebiped.bip01_r_hand")
	if bone then
		local pos, ang = owner:GetBonePosition(bone)

		local emitter = self.Emitter
		for i=1, 2 do
			local particle = emitter:Add("particle/particle_noisesphere", pos + ang:Right() * 2 + ang:Forward() * math.random(2,6) + VectorRand() * 1.5 + ang:Up() * -9)
			particle:SetDieTime(1)
			particle:SetColor(math.random(50,220),0,255)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(100)
			particle:SetStartSize(3)
			particle:SetEndSize(1)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetVelocity(owner:GetVelocity() + ang:Up() * -32)
		end
		
		if not self.Skull:IsValid() then
			self.Skull = ClientsideModel("models/Gibs/HGIBS.mdl", RENDERGROUP_TRANSLUCENT)
			self.Skull:SetModelScale( 0.7, 0 )
			self.Skull:SetRenderMode( RENDERMODE_TRANSALPHA )
			self.Skull:SetColor(Color(120,20,255,255))
		end
		self.Skull:SetPos(pos + ang:Right() * 1.2 + ang:Forward() * 3.8 + ang:Up() * -6)
		ang:RotateAroundAxis(ang:Up(), 90)
		self.Skull:SetAngles(ang)
	end
end
