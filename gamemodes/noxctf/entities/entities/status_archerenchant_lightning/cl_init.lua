include("shared.lua")

local matBolt = Material("Effects/laser1")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) then return end

	if owner == MySelf and not owner:ShouldDrawLocalPlayer() then
		local aim = MySelf:GetAimVector()
		local aimang = aim:Angle()
		local pos = MySelf:GetShootPos() + aim * 9 + aimang:Right() + aimang:Up() * -0.5

		render.SetMaterial(matBolt)
		for i=1, math.random(2, 4) do
			local bpos = pos
			local normal = VectorRand()
			local bpos2 = pos + normal * 0.25
			local xmax = math.random(4, 8)
			render.StartBeam(xmax)
			for x=1, xmax do
				render.AddBeam(bpos, 1 - x * 0.1, x, COLOR_CYAN)
				normal = (normal + VectorRand() * 0.3):GetNormalized()
				bpos = bpos2
				bpos2 = bpos2 + normal * 3
			end
			render.EndBeam()
		end
	else
		local attach = owner:GetAttachment(owner:LookupAttachment("anim_attachment_RH"))
		if attach then
			local pos = attach.Pos

			render.SetMaterial(matBolt)
			for i=1, math.random(2, 4) do
				local bpos = pos
				local normal = VectorRand()
				local bpos2 = pos + normal * 3
				local xmax = math.random(4, 8)
				render.StartBeam(xmax)
				for x=1, xmax do
					render.AddBeam(bpos, 8 - x * 0.9, x, COLOR_CYAN)
					normal = (normal + VectorRand() * 0.3):GetNormalized()
					bpos = bpos2
					bpos2 = bpos2 + normal * 4
				end
				render.EndBeam()
			end
		end
	end
end
