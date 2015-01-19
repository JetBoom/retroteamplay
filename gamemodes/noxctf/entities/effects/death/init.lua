function EFFECT:Init(data)
	local startpos = data:GetOrigin() + Vector(0,0,48)
	local endpos = data:GetStart() + Vector(0,0,48)
	local emitter = ParticleEmitter(startpos)
	emitter:SetNearClip(24, 32)
	for i=1, 30 do
		local particle = emitter:Add("sprites/glow04_noz", startpos + VectorRand()*16)
		particle:SetVelocity(VectorRand() * 16 + (endpos - startpos):GetNormal() * endpos:Distance(startpos) * 2)
		particle:SetDieTime(.6)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(220)
		particle:SetStartSize(16)
		particle:SetEndSize(4)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(255, 0, 0)
		particle:SetCollide(true)
		particle:SetBounce(0.75)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end