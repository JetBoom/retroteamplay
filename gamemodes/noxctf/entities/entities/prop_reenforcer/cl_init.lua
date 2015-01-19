include("shared.lua")

util.PrecacheSound("k_lab.teleport_rings_high")

local matGlow = Material("sprites/light_glow02_add")
local matBeam = Material("Effects/laser1")

function ENT:Draw()
	self:DrawModel()

	--if self:GetSkin() == 0 then return end

	local up = self:GetUp()
	local pos = self:GetPos() + up * 14.5
	local tr = util.TraceLine({start=pos, endpos=pos + up * 48, filter=self})
	local hitpos = tr.HitPos

	local ang = self:GetAngles()
	ang:RotateAroundAxis(up, self.Rotation)
	local offset = hitpos + ang:Forward() * 12
	local offset2 = hitpos + ang:Forward() * -12

	local radius = math.max(16, math.sin(RealTime()) * 16 + 16)

	render.SetMaterial(matBeam)
	if tr.HitNonWorld and tr.Fraction > 0.1 then
		self.Rotation = self.Rotation + FrameTime() * 200
		render.DrawBeam(pos, offset, 16, 6, 12, COLOR_LIMEGREEN)
		render.DrawBeam(pos, offset2, 16, 6, 12, COLOR_LIMEGREEN)

		render.SetMaterial(matGlow)
		render.DrawSprite(offset, radius, radius, COLOR_LIMEGREEN)
		render.DrawSprite(offset2, radius, radius, COLOR_LIMEGREEN)
	else
		self.Rotation = self.Rotation + FrameTime() * 80
		render.DrawBeam(pos, offset, 16, 6, 12, COLOR_RED)
		render.DrawBeam(pos, offset2, 16, 6, 12, COLOR_RED)

		render.SetMaterial(matGlow)
		render.DrawSprite(offset, radius, radius, COLOR_RED)
		render.DrawSprite(offset2, radius, radius, COLOR_RED)
	end

	if self.Rotation > 360 then self.Rotation = self.Rotation - 360 end
end

function ENT:Initialize()
	self.NextRequest = 0
	self.Rotation = 0
	self:SetRenderBounds(Vector(-32, -32, -16), Vector(32, 32, 64))
	self.AmbientSound = CreateSound(self, "k_lab.teleport_rings_high")
	self.SoundPlaying = false
end

function ENT:Think()
	local c = self:GetColor()
	if a == 255 then
		self.AmbientSound:PlayEx(0.65, math.sin(CurTime()) + 100)
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
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
		draw.SimpleText("Prop Repairer", "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
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
	end

	if not self.DeniedAccess and CurTime() > self.NextRequest then
		MySelf:ConCommand("ReqInfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end
