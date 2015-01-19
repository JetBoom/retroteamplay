include("shared.lua")

function ENT:StatusInitialize()
	hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)

	if MySelf == self:GetOwner() then hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects) end
end

local matGold = Material("models/shiny")
function ENT:PrePlayerDraw(pl)
	local owner = self:GetOwner()
	if pl ~= owner then return end

	render.ModelMaterialOverride(matGold)
	render.SetColorModulation(1, 1, 0)
end

function ENT:PostPlayerDraw(pl)
	local owner = self:GetOwner()
	if pl ~= owner then return end

	render.SetColorModulation(1, 1, 1)
	render.ModelMaterialOverride()
end

local cmtab = {["$pp_colour_brightness"] = -.2, ["$pp_colour_contrast"] = 1, ["$pp_colour_colour"] = 1, ["$pp_colour_addr"] = 1, ["$pp_colour_mulr"] = 1, ["$pp_colour_addg"] = 1}
function ENT:RenderScreenspaceEffects()
	DrawColorModify(cmtab)
end