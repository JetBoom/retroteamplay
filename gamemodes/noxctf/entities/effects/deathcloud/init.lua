function EFFECT:Init(data)
	local ent = data:GetEntity()
	local endpos = ent:GetCenter()
	local radius = data:GetMagnitude()

	sound.Play("nox/airburst.ogg", endpos, 80, math.Rand(30, 40))

	local emitter = ParticleEmitter(endpos)
	emitter:SetNearClip(32, 42)
	emitter:SetPos(endpos)

	local forw = ent:GetForward()
	local up = ent:GetUp()

	local amount = 10

	local xydir = forw:Angle()
	for i = 1, amount do
		local ang = up:Angle()
		for j = 1, amount do
			local dir = ang:Forward()
			local startpos = endpos + dir * radius
			local vel = (endpos - startpos):GetNormal() * radius

			local particle = emitter:Add("sprites/light_glow02_add", startpos)
			particle:SetVelocity(vel)
			particle:SetDieTime(1)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(20)
			particle:SetEndSize(0)
			particle:SetRollDelta(math.Rand(-10, 10))
			particle:SetRoll(math.Rand(0, 360))
			particle:SetColor(255, 0, 0)

			local particle = emitter:Add("particle/smokestack", startpos)
			particle:SetVelocity(vel)
			particle:SetDieTime(1)
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(0)
			particle:SetStartSize(60)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-6, 6))
			particle:SetColor(0, 0, 0)

			ang:RotateAroundAxis(-1 * xydir:Right(), 360/amount)
		end
		xydir:RotateAroundAxis(up, 360/amount)
	end
	emitter:Finish()
end

function EFFECT:Think()
	return false
end

function EFFECT:Render()
end