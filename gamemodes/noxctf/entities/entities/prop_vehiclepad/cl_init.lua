include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.NextRequest = 0
	self.ManaStorage = 0
	self.MaxManaStorage = 2000
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
	self.ManaStorage = tonumber(stuff[3])
	self.MaxManaStorage = tonumber(stuff[4])
end

ENT.MaxTraceHUDPaintLength = 256

function ENT:TraceHUDPaint()
	if self.PHealth then
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText("Vehicle Pad", "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		y = y + hhh * 1.2
		local boxy = y
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(x - 100, y, 200, hhh)
		surface.SetDrawColor(255, 0, 0, 255)
		local health = self.PHealth
		local maxhealth = self.MaxPHealth
		surface.DrawRect(x - 100, y, (health / maxhealth) * 200, hhh)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - 100, y, 200, hhh)
		draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)

		y = y + hhh

		local mana = self.ManaStorage
		local maxmana = self.MaxManaStorage
		surface.SetDrawColor(30, 30, 255, 255)
		surface.DrawRect(x - 100, y, (mana / maxmana) * 200, hhh * 0.75)
		draw.SimpleText(mana.." / "..maxmana, "Default", x, y, color_white, TEXT_ALIGN_CENTER)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - 100, boxy, 200, hhh * 1.75)
		surface.DrawLine(x - 100, boxy + hhh, x + 100, boxy + hhh)
	end

	if not self.DeniedAccess and CurTime() > self.NextRequest then
		MySelf:ConCommand("ReqInfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end
