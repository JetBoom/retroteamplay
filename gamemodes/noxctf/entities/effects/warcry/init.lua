local matRefraction = Material("refract_ring")
matRefraction:SetFloat("$nocull", 1)
if render.GetDXLevel() < 90 then
	matRefraction = Material("effects/strider_pinch_dudv")
end

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	self.Pos = pos

	sound.Play("nox/warcry.ogg", pos)

	self.Refract = 0
	self.Size = 64

	self.Entity:SetRenderBounds(Vector(-1536, -1536, -1536), Vector(1536, 1536, 1536))
end

function EFFECT:Think()
	self.Refract = self.Refract + FrameTime() * 0.5
	self.Size = 1536 * self.Refract ^ 0.3

	return self.Refract < 1
end

function EFFECT:Render()
	/*local mypos = self.Pos
	local Distance = EyePos():Distance(mypos)
	local Pos = mypos + (MySelf:EyePos() - mypos):GetNormal() * Distance * (self.Refract ^ 0.3) * 0.8*/

	local Pos = self.Entity:GetPos()

	matRefraction:SetFloat("$refractamount", math.sin(self.Refract * math.pi) * 0.75)
	render.SetMaterial(matRefraction)
	render.UpdateRefractTexture()
	render.DrawQuadEasy(Pos, Vector(0, 0, 1), self.Size, self.Size)
	render.DrawQuadEasy(Pos, Vector(0, 0, -1), self.Size, self.Size)
end
