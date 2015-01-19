include("shared.lua")

local matGlow = Material("sprites/light_glow02_add")
local matBeam = Material("Effects/laser1")

function ENT:Draw()
	self:DrawModel()
	local c = self:GetColor()
	if c.a ~= 255 then return end

	self.Rotation = self.Rotation + FrameTime() * 5
	if self.Rotation >= 360 then
		self.Rotation = self.Rotation - 360
	end

	local fraction = self:GetNetworkedInt("brit", 255) / 255
	local radius = math.cos(RealTime() * 8) * 32 * fraction + 64 * fraction
	local whiteradius = math.sin(RealTime() * 8) * 8 + 16 * fraction
	local vPos = self:GetPos()
	local vUp = self:GetUp()
	local vGlow = vPos + vUp * (40 * fraction + 20)
	local cDraw = Color(0, 127 * fraction, 255 * fraction)

	render.SetMaterial(matBeam)
	render.DrawBeam(vPos, vPos + vUp * (40 * fraction + 20), 16 * fraction, 6, 12, cDraw)

	render.SetMaterial(matGlow)
	render.DrawSprite(vGlow, whiteradius, whiteradius, color_white)
	render.DrawSprite(vGlow, radius, radius, cDraw)
end

function ENT:Initialize()
	self:SetRenderBounds(Vector(-64, -64, -64), Vector(64, 64, 72))
	self.Rotation = math.random(0, 180)
	self.NextRequest = 0
end

function ENT:Info(um)
	local str = um:ReadString()
	if str == "deny" then
		self.DeniedAccess = true
		return
	end

	local stuff = string.Explode(",", str)
	self.PHealth = tonumber(stuff[1])
	self.MaxPHealth = tonumber(stuff[2])
end

ENT.MaxTraceHUDPaintLength = 256

function ENT:TraceHUDPaint()
	if self.PHealth then
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText("Mana Dispenser", "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		y = y + hhh * 1.2
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(x - 100, y, 200, hhh)
		surface.SetDrawColor(255, 0, 0, 255)
		local health = self.PHealth
		local maxhealth = self.MaxPHealth
		surface.DrawRect(x - 100, y, (health / maxhealth) * 200, hhh)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - 100, y, 200, hhh)
		draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		local c = self:GetColor()
		if c.a == 255 and self:GetSkin() == 0 then
			y = y + hhh
			draw.SimpleText("(INSUFFICIENT MANA INCOME)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		end
	end

	if not self.DeniedAccess and CurTime() > self.NextRequest then
		MySelf:ConCommand("ReqInfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end
