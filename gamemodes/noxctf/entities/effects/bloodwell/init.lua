function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ent = data:GetEntity()

	self.Entity:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))

	sound.Play("npc/combine_gunship/gunship_moan.wav",pos,150,82,1)
	sound.Play("npc/combine_gunship/gunship_moan.wav",pos,150,82,1)
	
	
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

local function CollideCallback(particle, hitpos, hitnormal)
	if not particle.HitAlready then
	
		particle.HitAlready = true
		
		if math.random(10) == 1 then
			sound.Play("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.random(95, 105))
		end
		
		if math.random(3) == 1 then
			util.Decal(math.random(3) != 1 and "Blood" or "Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal)
		end
		particle:SetDieTime(0)
	end	
end


function EFFECT:Render()
	local pos = self.Pos
	local radius = 140
	
	if self.NextEmit <= CurTime() then
			
			self.NextEmit = CurTime() + EFFECT_IQUALITY * 0.03
	
			for i=1, math.random(3,11) do
				local rad = math.random(0,5)
				
				local sin = math.sin( CurTime()*3 + math.rad( rad*i ) )
				local cos = math.cos( CurTime()*3 + math.rad( rad*i ) )
				
				local ang = self.Norm:Angle():Right():Angle()
				
				local forw = ang:Forward()
				local right = ang:Right()
				local up = ang:Up()
				
				local size = math.random(3, 64)				
				
				local particle = self.Emitter:Add("noxctf/sprite_bloodspray"..math.random(1,8), self.Pos)
					particle:SetPos( pos + forw * sin * radius + right * cos * radius + up * math.random(-15,5) )
					particle:SetVelocity(VectorRand()*math.random(1,8) + vector_up*90)
					particle:SetStartAlpha(0)
					particle:SetEndAlpha(250)
					particle:SetStartSize(size)
					particle:SetEndSize(0)
					particle:SetLighting(true)
					particle:SetRoll(math.Rand(-180, 180))
					particle:SetColor(250, 10, 10)
					particle:SetAirResistance(1)
					particle:SetDieTime(math.Rand(0.8, 1.1))
					particle:SetGravity(Vector(0,0,math.random(-455,-325)))
					particle:SetCollide(true)
					particle:SetCollideCallback(CollideCallback)
			end
	end
end
