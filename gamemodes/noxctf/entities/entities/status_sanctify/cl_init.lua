include("shared.lua")

function ENT:StatusInitialize()
	self.Rotation = 120
	self.NextEmit = 0
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() or not ent:IsVisibleTarget(MySelf) then return end

	local oldpos = self:GetPos()

	local pos = ent:GetCenter()
	local ang = Angle(0, RealTime() * 270, 0)
	local count = 20
	local rotdelta = 360 / count

	local emitting = self.NextEmit <= CurTime()
	if emitting then self.NextEmit = CurTime() + 0.075 end

	local zbob = math.sin(RealTime() * 2) * ang:Up() * 3
	
	render.SetMaterial(matGlow)
	for i=1, count do
		local pos1 = pos + ang:Forward() * 24 + zbob
		local pos2 = pos1 + ang:Up() * 35
		local pos3 = pos1 - ang:Up() * 35

		render.DrawSprite(pos1, 32, 32, COLOR_YELLOW)
		render.DrawSprite(pos1, 16, 16, color_white)
		render.DrawSprite(pos2, 32, 32, COLOR_YELLOW)
		render.DrawSprite(pos2, 16, 16, color_white)
		render.DrawSprite(pos3, 32, 32, COLOR_YELLOW)
		render.DrawSprite(pos3, 16, 16, color_white)
		
		if i < count then
			ang:RotateAroundAxis(ang:Up(), rotdelta)
		end
	end

	self:SetPos(oldpos)
end
