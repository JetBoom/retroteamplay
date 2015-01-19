function EFFECT:Init(data)
	if EFFECT_QUALITY < 1 then self.Tim = 1 return end

	local pos = data:GetOrigin()
	local normal = data:GetNormal()
	self.Col = team.GetColor(math.Round(data:GetMagnitude()))

	self.Pos = pos
	self.Normal = normal
	self.Normal2 = normal * -1

	sound.Play("nox/forceofnature_bounce.ogg", pos)

	self.Tim = 0

	self.Entity:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 64))
end

function EFFECT:Think()
	self.Tim = self.Tim + FrameTime() * math.max(1, self.Tim)

	return self.Tim < 1
end

local matBounce = Material("sprites/glow04_noz")
function EFFECT:Render()
	if EFFECT_QUALITY < 1 then return end

	local Pos = self.Pos

	render.SetMaterial(matBounce)
	local size
	if self.Tim < 0.5 then
		size = self.Tim * 512
	else
		size = 512 - self.Tim * 512
	end

	local col = Color(0, 255, 0, 255)
	render.DrawQuadEasy(Pos, self.Normal, size, size, self.Col)
	render.DrawQuadEasy(Pos, self.Normal2, size, size, self.Col)
end
