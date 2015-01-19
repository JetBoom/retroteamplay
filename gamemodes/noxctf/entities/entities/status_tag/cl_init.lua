include("shared.lua")

function ENT:StatusInitialize()
	self.Rotation = 0

	self.AmbientSound = CreateSound(self, "ambient/alarms/alarm1.wav")
	self.AmbientSound:Play()
end

function ENT:StatusThink(owner)
	self.AmbientSound:PlayEx(0.85, 100 + math.abs(math.sin(RealTime() * math.pi)) * 30)
end

local matTag = Material("sprites/light_glow02_add_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	if self:GetTagOwner() == MySelf then
		local pos = owner:GetPos() + Vector(0, 0, 85)

		render.SetMaterial(matTag)
		self.Rotation = self.Rotation + FrameTime() * 40
		if self.Rotation > 360 then self.Rotation = self.Rotation - 360 end
		render.DrawQuadEasy(pos, MySelf:GetAimVector() * -1, 72, 72, COLOR_RED, self.Rotation)
	end
end
