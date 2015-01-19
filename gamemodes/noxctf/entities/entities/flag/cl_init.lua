include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:Initialize()
	self:SetRenderBounds(Vector(-128, -128, -72), Vector(128, 128, 90))
end

function ENT:Think()
	self:AlignToCarrier()
end

local matWall = Material("VGUI/white")
local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	self:AlignToCarrier()

	local pos = self:GetPos()

	local c = self:GetColor()

	if self:GetCarrier() == MySelf then
		cam.Start3D(EyePos(), EyeAngles())
			render.SetBlend(0.25)
				self:DrawModel()
			render.SetBlend(1)
		cam.End3D()
		return
		--a = a * 0.25
	else
		self:DrawModel()
	end

	local rsin = math.sin(CurTime() * 4) * 16
	local rcon = math.cos(CurTime() * 4) * 16
	local drawColor = Color(c.r, c.g, c.b, 200)
	local size =  math.sin(RealTime() * 5) * 60 + 90
	local minisize = size * 0.5

	render.SetMaterial(matGlow)
	render.DrawSprite(pos, size, size, drawColor)
	render.DrawSprite(pos + Vector(rsin, rcon, 0), minisize, minisize, drawColor)
	render.DrawSprite(pos + Vector(0, rcon, rsin), minisize, minisize, drawColor)
	render.DrawSprite(pos + Vector(rcon, 0, rsin), minisize, minisize, drawColor)
end
