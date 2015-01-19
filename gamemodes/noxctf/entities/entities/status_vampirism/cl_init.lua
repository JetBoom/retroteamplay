include("shared.lua")

local matGlow = Material("sprites/glow04_noz")
local colVampire = Color(255, 0, 255, 190)
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	if ent:IsInvisible() then return end

	render.SetMaterial(matGlow)
	if MySelf == ent and not ent:ShouldDrawLocalPlayer() then
		for i=0, 15 do
			local size = math.Rand(8, 13)
			render.DrawSprite(ent:GetPos() + Vector(math.Rand(-10, 10),math.Rand(-10, 10),math.Rand(0, 72)) + VectorRand():GetNormal() * math.Rand(4, 10), size, size, colVampire)
		end
	else
		for i=0, 25 do
			if math.Rand(1,2) < 1.75 then
				local bone = ent:GetBoneMatrix(i)
				if bone then
					local size = math.Rand(8, 13)
					render.DrawSprite(bone:GetTranslation() + VectorRand():GetNormal() * math.Rand(4, 10), size, size, colVampire)
				end
			end
		end
	end
end
