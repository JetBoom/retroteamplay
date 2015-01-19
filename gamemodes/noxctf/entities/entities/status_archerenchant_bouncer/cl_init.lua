include("shared.lua")

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) then return end

	if owner == MySelf and not owner:ShouldDrawLocalPlayer() then
		local aimvec = owner:GetAimVector()
		local aimang = owner:EyeAngles()
		local pos = owner:GetShootPos() + aimvec * 4 + aimang:Right() + aimang:Up() * -0.5

		render.SetMaterial(matGlow)
		render.DrawSprite(pos + math.sin(CurTime() * 6) * 4 * aimang:Right(), 2, 2, COLOR_YELLOW)
	else
		local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		if attach then
			local aimvec = owner:GetAimVector()
			local aimang = owner:EyeAngles()
			local pos = attach.Pos + aimvec * 4 + aimang:Right() + aimang:Up() * -0.5

			render.SetMaterial(matGlow)
			render.DrawSprite(pos + math.sin(CurTime() * 6) * 16 * aimang:Right(), 12, 12, COLOR_YELLOW)
		end
	end
end
