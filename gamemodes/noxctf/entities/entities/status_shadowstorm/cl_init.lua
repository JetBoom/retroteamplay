include("shared.lua")

function ENT:StatusInitialize()
	hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
end

function ENT:GetVisibility(pl)
	return 0
end

function ENT:PostPlayerDraw(pl)
	if pl ~= self:GetOwner() then return end

	render.SetBlend(1)
	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()
end

local matWhite = Material("models/debug/debugwhite")
function ENT:PrePlayerDraw(pl)
	if pl ~= self:GetOwner() then return end

	local blend = 0

	if pl:Team() == LocalPlayer():Team() then
		blend = .1
	elseif blend <= 0 then return true end
	
	render.SetBlend(blend)
	render.SetColorModulation(0.2, 0.2, 0.2)
	render.ModelMaterialOverride(matWhite)
end
