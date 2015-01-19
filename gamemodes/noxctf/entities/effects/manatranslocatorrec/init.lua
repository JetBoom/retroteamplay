function EFFECT:Init(data)
	local hitpos = data:GetOrigin()
	local startpos = data:GetStart()
	local hitent = data:GetEntity()
	local normal = data:GetNormal()
	local teamid = math.Round(data:GetMagnitude())
	local ang = normal:Angle()

	self.StartPos = startpos
	self.HitPos = hitpos

	self.EndTime = CurTime() + 1

	self.Color = table.Copy(team.GetColor(teamid) or color_white)

	sound.Play("nox/managain.ogg", hitpos, 70, math.Rand(98, 102))
	sound.Play("weapons/physcannon/energy_sing_flyby2.wav", hitpos, 70, 70)

	local emitter = ParticleEmitter(hitpos)
	emitter:SetNearClip(24, 32)
	for i=1, 90 do
		ang:RotateAroundAxis(normal, 4)
		local heading = normal * 48 + ang:Up() * 128
		local particle = emitter:Add("sprites/light_glow02_add", hitpos)
		particle:SetVelocity(heading)
		particle:SetDieTime(math.Rand(0.9, 0.98))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(32)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-10, 10))
		particle:SetAirResistance(16)
		particle:SetColor(92, 128, 255)
	end

	local particle = emitter:Add("sprites/light_glow02_add", hitpos)
	particle:SetDieTime(1.35)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(255)
	particle:SetStartSize(75)
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-10, 10))
	particle:SetColor(255, 255, 255)

	emitter:Finish()

	self.Entity:SetRenderBoundsWS(self.StartPos, self.HitPos, Vector(32, 32, 32))
end

function EFFECT:Think()
	return CurTime() < self.EndTime
end

local matBeam = Material("Effects/laser1")
function EFFECT:Render()
	render.SetMaterial(matBeam)
	render.DrawBeam(self.HitPos, self.StartPos, math.abs(math.sin((self.EndTime - CurTime()) * 9.425)) * 24, 1, RealTime() * 128, self.Color)
end
