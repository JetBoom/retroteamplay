local function CollideCallback(particle, hitpos, hitnormal)
	if not particle.HitAlready then
	
		particle.HitAlready = true
		
		if math.random(10) == 1 then
			sound.Play("physics/flesh/flesh_bloody_impact_hard1.wav", hitpos, 50, math.random(95, 105))
		end
		util.Decal(math.random(3) != 1 and "Blood" or "Impact.Flesh", hitpos + hitnormal, hitpos - hitnormal)
		
		particle:SetDieTime(0)
	end	
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local pl = data:GetEntity()
	
	if !IsValid( pl ) then return end 
	
	sound.Play("physics/flesh/flesh_bloody_break.wav", pos, 75, math.random(95, 105))
	
	local emitter = ParticleEmitter(pos)
	
	for _, ent in ipairs(ents.FindInSphere(pos, 170)) do
		if ent:IsPlayer() and ent:Alive() and TrueVisible(ent:NearestPoint(pos), pos) then
			if ent:Team() == pl:Team() then
			
				local norm = (ent:GetShootPos() - pos):GetNormal()
				local dist = pos:Distance(ent:GetShootPos())
				
				for i = 1, 14 do
					
					particle = emitter:Add("noxctf/sprite_bloodspray"..math.random(8), pos + VectorRand()*15 + norm * dist * i/14)
					particle:SetVelocity( vector_up * i * 10 )
					particle:SetDieTime(math.Rand(1, 2))
					particle:SetStartAlpha(255)
					particle:SetEndAlpha(255)
					particle:SetStartSize(8)
					particle:SetEndSize(math.random(4,9))
					particle:SetRoll(math.Rand(0, 360))
					particle:SetColor(250, 0, 0)
					particle:SetAirResistance(2)
					particle:SetLighting(true)
					particle:SetRollDelta(math.Rand(-5, 5))
					particle:SetGravity(Vector(0,0,-540))
					particle:SetCollide( true )
					particle:SetCollideCallback(CollideCallback)
				end
				
			end
		end
	end

	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
