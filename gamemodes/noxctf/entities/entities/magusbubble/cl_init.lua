include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:DrawShadow(false)
	self:SetMaterial("models/shiny")
	self:SetRenderBounds(Vector(-750, -750, -750), Vector(750, 750, 750))
	self.AppAlpha = 40
	self.Size = 0
end

local matRefract = Material("models/spawn_effect")
local matSolid = Material("models/shiny")
function ENT:DrawAll()
	local enabled = self:GetOwner():GetSkin() > 0

	cam.Start3D(EyePos(), EyeAngles())
		render.MaterialOverride(matSolid)
			self:DrawModel()
		render.MaterialOverride(0)

		if enabled and render.GetDXLevel() >= 80 then
			render.UpdateRefractTexture()

			matRefract:SetFloat("$refractamount", self:GetAlpha() * 0.001)

			render.MaterialOverride(matRefract)
				self:DrawModel()
			render.MaterialOverride(0)
		end
	cam.End3D()
end

function ENT:DrawTranslucent()
	local magusshield = self:GetOwner()
	if magusshield:IsValid() then
		local c = magusshield:GetColor()
		if c.a == 255 then
			local size = self.Size
			if size < 18 then
				if not self.PlayedSound then
					self.PlayedSound = true
					self:EmitSound("ambient/machines/machine1_hit"..math.random(1, 2)..".wav")
				end

				size = math.min(18, size + FrameTime() * 15)
				self.Size = size
			end

			if magusshield:GetSkin() == 0 then
				self.AppAlpha = math.max(15, self.AppAlpha - FrameTime() * 100, 35)
				self:SetColor(Color(c.r, c.g, c.b, self.AppAlpha + math.sin(CurTime()) * 10))
			else
				self.AppAlpha = math.min(35, self.AppAlpha + FrameTime() * 100)
				self:SetColor(Color(c.r, c.g, c.b, self.AppAlpha + math.sin(CurTime() * 3) * 20))
			end

			local scale = size
			self:SetModelScale(scale * -1, 0)
			self:DrawAll()
			self:SetModelScale(scale, 0)
			self:DrawAll()
		end
	end
end
