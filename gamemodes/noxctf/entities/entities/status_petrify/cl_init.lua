include("shared.lua")

function ENT:StatusInitialize()
	hook.Add("PrePlayerDraw", self, self.PrePlayerDraw)
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)

	if MySelf == self:GetOwner() then hook.Add("RenderScreenspaceEffects", self, self.RenderScreenspaceEffects) end
end

local matGold = Material("models/props_wasteland/rockcliff02b")
function ENT:PrePlayerDraw(pl)
	local owner = self:GetOwner()
	if pl ~= owner then return end

	render.ModelMaterialOverride(matGold)
end

function ENT:PostPlayerDraw(pl)
	local owner = self:GetOwner()
	if pl ~= owner then return end

	render.ModelMaterialOverride()
end

local cmtab = {
 [ "$pp_colour_contrast" ] = 0.5,
 [ "$pp_colour_colour" ] = 0
}

function ENT:RenderScreenspaceEffects()
	DrawColorModify(cmtab)
end
