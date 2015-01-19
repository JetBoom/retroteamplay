function EFFECT:Init(data)
	local target = data:GetEntity()
	if not target:IsValid() then return end

	local startpos = data:GetOrigin()
	local endpos = target:NearestPoint(startpos)

	local collide = math.Round(data:GetMagnitude()) ~= 1

	local emitter = ParticleEmitter(startpos)
	emitter:SetNearClip(24, 32)
	for i=1, 9 do
		local particle = emitter:Add("sprites/glow04_noz", endpos + VectorRand():GetNormal() * math.Rand(4, 16))
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(4, 16) + (startpos - endpos)) --(startpos - endpos):GetNormal() * endpos:Distance(startpos))
		particle:SetDieTime(1.1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(220)
		particle:SetStartSize(16)
		particle:SetEndSize(3)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		particle:SetColor(60, 60, 255)
		if collide then
			particle:SetCollide(true)
			particle:SetBounce(0.75)
		end
	end
	emitter:Finish()

	if CurTime() >= (target.m_NextManaDrainSound or 0) then
		target.m_NextManaDrainSound = CurTime() + 0.5
		sound.Play("nox/manadraining.ogg", endpos, 80, math.Rand(95, 105))
	end
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
