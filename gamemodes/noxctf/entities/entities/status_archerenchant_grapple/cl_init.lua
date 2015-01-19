include("shared.lua")

local matBeam = Material("cable/rope")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) then return end

	local aimvec = owner:GetAimVector()
	local pos = owner:GetShootPos()
	local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
	if attach then
		pos = attach.Pos
	end

	pos = pos + aimvec * 24

	local aimang = owner:EyeAngles()
	aimang:RotateAroundAxis(aimang:Forward(), CurTime() * -180)

	render.SetMaterial(matBeam)
	render.StartBeam(16)
	for x=1, 16 do
		local bpos = pos + aimang:Up() * 16
		render.AddBeam(bpos, 3 - x * 0.1, x, color_white)
		aimang:RotateAroundAxis(aimang:Forward(), 22.5)
	end
	render.EndBeam()
end
