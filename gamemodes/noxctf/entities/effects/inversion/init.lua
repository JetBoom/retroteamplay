function EFFECT:Init(data)
	self.Pos = data:GetOrigin()
	self.Norm = data:GetNormal()
	if 1 < data:GetMagnitude() then
		sound.Play("nox/inversion.ogg", self.Pos, 80, math.Rand(75, 85))
	end
	self.Refract = 50
end

function EFFECT:Think()
	self.Refract = self.Refract - FrameTime() * 40

	return 0 < self.Refract
end

local matRefract = Material("effects/strider_pinch_dudv")
function EFFECT:Render()
	matRefract:SetFloat("$refractamount", self.Refract)
	render.SetMaterial(matRefract)
	render.UpdateRefractTexture()
	local siz = 60 - self.Refract
	render.DrawQuadEasy(self.Pos, self.Norm, siz, siz, color_white)
	render.DrawQuadEasy(self.Pos, self.Norm * -1, siz, siz, color_white)
end
