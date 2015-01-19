function EFFECT:Init(data)
	local dir = data:GetNormal() * -1
	self.Dir = dir
	local pos = data:GetOrigin()
	self.EndPos = pos
	self.TeamID = math.Round(data:GetMagnitude())
	self.Col = team.GetColor(self.TeamID) or color_white
	self.DieTime = CurTime() + 0.25

	util.Decal("Impact.Concrete", pos + dir, pos - dir)
	sound.Play("ambient/energy/weld"..math.random(1,2)..".wav", pos, 70, math.Rand(230, 255))
end

function EFFECT:Think()
	return CurTime() < self.DieTime
end

local matGlow = Material("sprites/glow04_noz")
function EFFECT:Render()
	local ct = CurTime()
	local c = self.Col
	if not self.EndParticles then
		self.EndParticles = true

		local emitter = ParticleEmitter(self.EndPos)
		for i=1, 8 do
			local particle = emitter:Add("noxctf/sprite_nova", self.EndPos)
			particle:SetDieTime(math.Rand(0.3, 0.5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(1)
			particle:SetEndSize(8)
			particle:SetVelocity(VectorRand():GetNormal() * 800)
			particle:SetAirResistance(1200)
			particle:SetColor(c.r, c.g, c.b)
		end
	end

	local size = (self.DieTime - ct) * 128
	render.SetMaterial(matGlow)
	render.DrawSprite(self.EndPos, size, size, Color(c.r, c.g, c.b, 255))
	render.DrawQuadEasy(self.EndPos, self.Dir, size, size, Color(c.r, c.g, c.b, 255))
end
