function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ent = data:GetEntity()

	self.Entity:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))

	sound.Play("npc/combine_gunship/gunship_crashing1.wav",pos,150,175,1)
	
	self.DieTime = CurTime() + data:GetMagnitude()

	self.NextEmit = 0

	self.Emitter = ParticleEmitter(pos)
	self.Emitter:SetNearClip(24, 32)

	local tr = util.TraceLine({start=pos, endpos=pos + Vector(0,0,-32), mask = MASK_SOLID_BRUSHONLY})
	if tr.HitWorld then
		self.Norm = tr.HitNormal
	else
		self.Norm = Vector(0,0,1)
	end
	self.Pos = pos
end

function EFFECT:Think()	
	if self.DieTime <= CurTime() then
		--self.Emitter:Finish()
		return false
	end
	return true
end

function EFFECT:Render()
	local pos = self.Pos
	local radius = 150
	
	if self.NextEmit <= CurTime() then
			
			self.NextEmit = CurTime() + EFFECT_IQUALITY * 0.03
	
			for i=1, math.random(3,11) do
				local rad = math.random(2) == 1 and 90 or 180
				
				local sin = math.sin( CurTime()*2 + math.rad( rad*i ) )
				local cos = math.cos( CurTime()*2 + math.rad( rad*i ) )
				
				local ang = self.Norm:Angle():Right():Angle()
				
				local forw = ang:Forward()
				local right = ang:Right()
				local up = ang:Up()
				
				if i < 4 then
					local particle = self.Emitter:Add("sprites/glow04_noz", self.Pos)
					particle:SetPos( pos + forw * sin * radius + right * cos * radius + up * math.random(-5,5) )
					particle:SetVelocity(VectorRand()*math.random(-8,8))
					particle:SetStartAlpha(50)
					particle:SetEndAlpha(255)
					particle:SetStartSize(math.random(133, 164))
					particle:SetEndSize(4)
					particle:SetColor(215, 170, 45)
					particle:SetAirResistance(20)
					particle:SetDieTime(math.Rand(0.5, 2.1))
					particle:SetGravity(Vector(0,0,255))
				end
				
				local particle = self.Emitter:Add("effects/fire_cloud1", self.Pos)
					particle:SetPos( pos + forw * sin * radius + right * cos * radius + up * math.random(-15,5) )
					particle:SetVelocity(VectorRand()*math.random(-8,8))
					particle:SetStartAlpha(0)
					particle:SetEndAlpha(250)
					particle:SetStartSize(math.random(33, 64))
					particle:SetEndSize(4)
					//particle:SetLighting(true)
					particle:SetRoll(math.Rand(-180, 180))
					particle:SetColor(185, 170, 45)
					particle:SetAirResistance(20)
					particle:SetDieTime(math.Rand(0.5, 1.1))
					particle:SetGravity(Vector(0,0,math.random(-155,15)))
					particle:SetCollide(true)
			end
	end
end
