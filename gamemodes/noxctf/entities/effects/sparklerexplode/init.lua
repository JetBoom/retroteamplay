function EFFECT:Init(data)
	local normal = data:GetNormal() * -1
	local pos = data:GetOrigin()
	self.Normal = normal

	util.Decal("FadingScorch", pos - normal, pos + normal)

	sound.Play("ambient/levels/labs/electric_explosion4.wav", pos, 77, math.Rand(80, 115))

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)
	local hitnormalang = normal:Angle()
	local sep = math.max(4, EFFECT_IQUALITY * 4)
	local normadd = normal * 10
	for i=1, 360, sep do
		hitnormalang:RotateAroundAxis(normal, sep)
		local heading = hitnormalang:Up()
		local particle = emitter:Add("effects/yellowflare", pos + heading * 16 + normadd)
		particle:SetVelocity(heading * 100)
		particle:SetGravity(heading * -150)
		particle:SetDieTime(math.Rand(1.5, 1.6))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(200)
		particle:SetStartSize(math.Rand(30, 75))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-25, 25))
		particle:SetAirResistance(5)
		if math.random(1, 2) == 1 then
			particle:SetColor(200, 230, 255)
		end
	end
	emitter:Finish()

	self.Start = CurTime()
	self.EndTime = CurTime() + 1.6
	self.Pos = pos + normal

	ExplosiveEffect(pos, 48, 45, DMGTYPE_LIGHTNING)
end

function EFFECT:Think()
	return CurTime() < self.EndTime
end

--local matGlow = Material("Effects/yellowflare")
local matGlow = Material("noxctf/sprite_nova")
local matBolt = Material("Effects/laser1")
function EFFECT:Render()
	render.SetMaterial(matGlow)
	local size = 115.1 + math.sin((CurTime() - self.Start) * 3) * 115
	render.DrawQuadEasy(self.Pos, self.Normal, size, size, color_white)
	render.DrawQuadEasy(self.Pos, self.Normal * -1, size, size, color_white)
	render.DrawQuadEasy(self.Pos, self.Normal, size, size, COLOR_BLUE)
	render.DrawQuadEasy(self.Pos, self.Normal * -1, size, size, COLOR_BLUE)

	if 2 < size then
		local pos = self.Pos
		render.SetMaterial(matBolt)
		for i=1, math.Rand(2, 3) * EFFECT_QUALITY do
			local bpos = pos
			local hitnormalang = self.Normal:Angle()
			hitnormalang:RotateAroundAxis(self.Normal, math.Rand(0, 360))
			hitnormalang = hitnormalang:Up()
			local normal = ((self.EndTime - CurTime()) * 0.25 * VectorRand():GetNormal() + hitnormalang):GetNormal()
			local xmax = math.random(7, 10)

			render.StartBeam(xmax)
			for x=1, xmax do
				render.AddBeam(bpos, size * 0.2 - x * size * 0.0199, size * 0.05, Color(30, 255 - x * 15, 255, 255 - x * 20))
				normal = (normal + VectorRand() * 0.3):GetNormal()
				bpos = bpos + size * 0.05 * normal
			end
			render.EndBeam()
		end
	end
end
