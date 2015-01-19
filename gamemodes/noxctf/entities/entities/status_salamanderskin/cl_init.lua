include("shared.lua")

function ENT:StatusInitialize()
	hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
end

local matScales = Material("models/props_foliage/tree_deciduous_01a_trunk")
function ENT:PrePlayerDraw(pl)
	local owner = self:GetOwner()
	if pl ~= owner then return end

	local c = team.GetColor(pl:Team())
	render.SetColorModulation(c.r / 255, c.g / 255, c.b / 255)
	render.ModelMaterialOverride(matScales)
end

function ENT:PostPlayerDraw(pl)
	local owner = self:GetOwner()
	if pl ~= owner then return end

	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()
end
