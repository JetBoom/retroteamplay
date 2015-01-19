include("shared.lua")

local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() or CurTime() % 1 > 0.1 then return end

	if owner == MySelf and not owner:ShouldDrawLocalPlayer() then
		local aimang = owner:EyeAngles()

		render.SetMaterial(matGlow)
		render.DrawSprite(owner:GetShootPos() + owner:GetAimVector() * 4 + aimang:Right() + aimang:Up() * -0.5, 0.8, 0.8, COLOR_RED)
	else
		local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		if attach then
			render.SetMaterial(matGlow)
			render.DrawSprite(attach.Pos, 8, 8, COLOR_RED)
		end
	end
end
