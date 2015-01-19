include("shared.lua")

local vecScale = 1.5
function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-100, -100, -32), Vector(100, 100, 92))
	
	self.FinishTime = CurTime() + 1
end

local matRefract = Material("models/spawn_effect")
local matLight = Material("models/spawn_effect2")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end
	if owner:IsInvisible() then return end

	self:SetRenderOrigin(owner:GetPos() + Vector(0, 0, owner:OBBMaxs().z + math.sin(RealTime() * 2) * 5) + owner:GetForward() * 7)
	
	local ang = Angle(35.313, owner:GetAngles().yaw, -134.883)
	self:SetRenderAngles(ang)

	if CurTime() < self.FinishTime then
		local delta = self.FinishTime - CurTime()
		self:SetModelScale((math.cos(delta * 10) * delta * 0.5 + 1) * vecScale, 0)
	else
		self:SetModelScale(vecScale, 0)
	end

	self:CenterOnPlayer(owner)
	cam.Start3D(EyePos() + Vector(0, 0, owner:OBBCenter().z*-0.1), EyeAngles())
		render.SetColorModulation(0, .7, 1)
		render.SetBlend(0.5)

		render.MaterialOverride(matLight)
			self:DrawModel()
		render.MaterialOverride(0)

		render.SetBlend(1)

		if not owner == MySelf and owner:ShouldDrawLocalPlayer() and render.GetDXLevel() >= 80 then
			render.UpdateRefractTexture()

			matRefract:SetFloat("$refractamount", 0.008)

			render.MaterialOverride(matRefract)
				self:DrawModel()
			render.MaterialOverride(0)
		end
		
		render.SetColorModulation(1, 1, 1)
	cam.End3D()
end
