function EFFECT:Init(data)
	local ent = data:GetEntity()
	if not (ent and ent:IsValid()) then return end

	local pos = ent:GetPos()
	local pos2 = pos + Vector(0,0,72)
	local radius = data:GetScale()
	local velocity = ent:GetVelocity()
	local mag = data:GetMagnitude()
	local startsize = 6
	local endsize = 32

	if radius == 80 then
		startsize = 2
		endsize = 16
	end

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	for i=1, 360, 8 - EFFECT_QUALITY * 0.5 do
		local particle = emitter:Add("sprites/light_glow02_add", pos + Vector(radius * math.cos(i), radius * math.sin(i), 0))
		particle:SetVelocity(velocity + Vector(0,0,36))
		particle:SetDieTime(1)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(50)
		particle:SetStartSize(startsize)
		particle:SetEndSize(endsize)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetColor(100, 255, 100)

		local particle = emitter:Add("sprites/light_glow02_add", pos2 + Vector(radius * math.cos(i), radius * math.sin(i), 0))
		particle:SetVelocity(velocity + Vector(0,0,-36))
		particle:SetDieTime(1)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(50)
		particle:SetStartSize(startsize)
		particle:SetEndSize(endsize)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetColor(100, 255, 100)
	end
	emitter:Finish()

	ent:EmitSound("nox/heal.ogg", 85, mag)
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end
