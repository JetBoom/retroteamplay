include("shared.lua")
 
function ENT:StatusInitialize()
	hook.Add("PostPlayerDraw", self, self.PostPlayerDraw)
end

local nodraw = false
local matGlow = Material("models/props_combine/tpballglow")
function ENT:PostPlayerDraw(pl)
	if nodraw then return end
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if pl ~= owner then return end

	local offset = Vector(0, 0, pl:OBBMaxs().z) * .05
	cam.Start3D(EyePos() + offset, EyeAngles())
		render.ModelMaterialOverride(matGlow)
			render.SetColorModulation(1, 1, 0)
			pl:SetModelScale(1.1, 0)
				pl:SetupBones()
				nodraw = true
				pl:DrawModel()
				nodraw = false
			pl:SetModelScale(1, 0)
			pl:SetupBones()
			render.SetColorModulation(1, 1, 1)
		render.ModelMaterialOverride()
	cam.End3D()
end