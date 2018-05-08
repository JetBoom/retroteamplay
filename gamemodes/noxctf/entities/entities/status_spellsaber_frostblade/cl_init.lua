include("shared.lua")

function ENT:StatusInitialize()
	self:DrawShadow(false)
	self:SetRenderBounds(Vector(-40, -40, -18), Vector(40, 40, 80))
	
	self.AmbientSound = CreateSound(self, "ambient/levels/canals/windmill_wind_loop1.wav")

	self.IceChunk = {}
	for i = 1,4 do
		self.IceChunk[i] = ClientsideModel("models/Gibs/Glass_shard06.mdl", RENDERGROUP_TRANSLUCENT)
		self.IceChunk[i]:SetModelScale( 0.3, 0 )
		self.IceChunk[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
	for i = 1,4 do
		self.IceChunk[i]:Remove()
	end
end

function ENT:StatusThink(owner)
	local mult = LocalPlayer() == owner and math.min(owner:GetMana(),20) / 20 or 1
	self.AmbientSound:PlayEx(0.2*mult, 100)
end

function ENT:Draw()
	local owner = self:GetOwner()
	local mult = LocalPlayer() == owner and math.min(owner:GetMana(),20) / 20 or 1
	
	for i=1,4 do
		if (owner:IsInvisible() or not owner:GetStatus("weapon_spell_saber")) and self.IceChunk[i] then
			self.IceChunk[i]:SetColor(Color(150,200,255,0))
		else
			self.IceChunk[i]:SetColor(Color(150,200,255,255*mult))
		end
	end
	
	if not owner:IsValid() or owner:IsInvisible() or not owner:GetStatus("weapon_spell_saber") then return end
	
	local bone = owner:LookupBone("valvebiped.bip01_r_hand")
	if bone then
		local pos, ang = owner:GetBonePosition(bone)

		local emitter = ParticleEmitter(self:GetPos())
		emitter:SetNearClip(24, 32)
		for i=1, 8 do
			local particle = emitter:Add("particle/snow", pos + ang:Right() * 1 + ang:Forward() * 4 + VectorRand() * 2 + ang:Up() * math.random(-5,-35))
			particle:SetDieTime(0.35)
			particle:SetStartAlpha(20*mult)
			particle:SetEndAlpha(0)
			particle:SetStartSize(4)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
		end
		for i=1, 12 do
			local startpos = pos + ang:Right() * 1 + ang:Forward() * 4 + VectorRand() * 2 + ang:Up() * math.random(-5,-35)
			local endpos = pos + ang:Right() * 1 + ang:Forward() * 4 + ang:Up() * -20
			local particle = emitter:Add("effects/yellowflare", startpos)
			particle:SetDieTime(0.35)
			particle:SetStartAlpha(125*mult)
			particle:SetEndAlpha(0)
			particle:SetStartSize(1)
			particle:SetEndSize(1)
			particle:SetVelocity((startpos - endpos):GetNormal() * (math.Rand(30,40) * mult))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-20, 20))
			particle:SetAirResistance(10)
		end
		
		emitter:Finish()
		
		for i=1,4 do
			local chunkpos, chunkang = owner:GetBonePosition(bone)
			if not self.IceChunk[i] then
				self.IceChunk[i] = ClientsideModel("models/Gibs/Glass_shard06.mdl", RENDERGROUP_TRANSLUCENT)
				self.IceChunk[i]:SetModelScale( 0.3, 0 )
				self.IceChunk[i]:SetRenderMode( RENDERMODE_TRANSALPHA )
			end
			self.IceChunk[i]:SetPos(pos + ang:Right() * 2.3 + ang:Forward() * 1.8 + ang:Up() * (-5 + i * -6))
			chunkang:RotateAroundAxis(chunkang:Right(), 160)
			chunkang:RotateAroundAxis(chunkang:Forward(), 90)
			self.IceChunk[i]:SetAngles(chunkang)
		end
	end
	

end
