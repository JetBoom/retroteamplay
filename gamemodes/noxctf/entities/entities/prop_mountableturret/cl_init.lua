include("shared.lua")

function ENT:Draw()
	self:DrawModel()
end

ENT.MaxTraceHUDPaintLength = 256

function ENT:TraceHUDPaint()
	if self:Team() == MySelf:Team() then
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText(self.Name, "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		y = y + hhh * 1.2
		surface.SetDrawColor(255, 0, 0, 255)
		local health = self:GetVHealth()
		local maxhealth = self:GetMaxVHealth()
		surface.DrawRect(x - w * 0.05, y, (health / maxhealth) * w * 0.1, h * 0.02)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - w * 0.05, y, w * 0.1, h * 0.02)
		draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
	else
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText(self.Name, "teamplay_nooutline", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		draw.SimpleText(team.GetName(self:Team()), "DefaultBold", x, y + hhh, COLOR_RED, TEXT_ALIGN_CENTER)
	end
end

function ENT:Initialize()
	self.NextRequest = 0
end

function ENT:Think()
end

function ENT:OnRemove()
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
	self.AmmoType = stuff[3]
end

function ENT:DrawHUD(seat)
	if self.PHealth then
		local x, y = w * 0.5, h * 0.8
		if self.AmmoType == "NONE" then
			draw.SimpleText("Mountable Turret", "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Mountable Turret: "..self.AmmoType, "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		end
		local _, hhh = surface.GetTextSize("A")
		y = y + hhh * 1.2
		surface.SetDrawColor(255, 0, 0, 255)
		local health = self.PHealth
		local maxhealth = self.MaxPHealth
		surface.DrawRect(x - w * 0.1, y, (health / maxhealth) * w * 0.2, h * 0.04)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - w * 0.1, y, w * 0.2, h * 0.04)
		draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y + hhh * 0.5, COLOR_CYAN, TEXT_ALIGN_CENTER)
	end

	local cannon = self:GetDTEntity(1)
	if cannon != NULL then
		local up = MySelf:GetAimVector()
		local startpos = cannon:GetPos() + up * 48
		local pos = util.TraceLine({start=startpos, endpos = startpos + up * 4096, filter = cannon}).HitPos:ToScreen()
		local x, y = pos.x, pos.y
		local w2 = w * 0.02
		local w22 = w2 * 0.75
		local w222 = w2 * 1.5
		surface.SetDrawColor(40, 255, 40, 200)
		surface.DrawLine(x - w222, y, x + w222, y)
		surface.DrawLine(x, y - w22, x, y + w22)

		surface.SetDrawColor(255, 0, 0, 180)
		surface.DrawOutlinedRect(x - w22, y - w22, w222, w222)
	end

	if not self.DeniedAccess and self.NextRequest < CurTime() then
		MySelf:ConCommand("ReqInfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end

function ENT:TraceHUDPaint()
	if self.PHealth then
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText("Mountable Turret", "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
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
		y = y + hhh
		if self.AmmoType == "NONE" then
			draw.SimpleText("(NO BARREL)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		else
			draw.SimpleText("Barrel: "..self.AmmoType, "teamplaytargetidsmall", x, y, color_white, TEXT_ALIGN_CENTER)
		end
	end

	if not self.DeniedAccess and self.NextRequest < CurTime() then
		MySelf:ConCommand("ReqInfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end
