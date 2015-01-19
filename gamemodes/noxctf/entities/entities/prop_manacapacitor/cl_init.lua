include("shared.lua")

local matGlow = Material("sprites/light_glow02_add")

function ENT:Draw()
	self:DrawModel()

	local c = self:GetColor()
	if c.a == 255 then
		render.SetMaterial(matGlow)
		if self:GetSkin() == 0 then
			local size = math.sin((RealTime() + self.Seed)* 16) * 32 + 64
			render.DrawSprite(self:GetPos() + self:GetUp() * 116, size, size, COLOR_RED)
		elseif self:GetSkin() < 51 then
			local size = math.sin((RealTime() + self.Seed)* 16) * 32 + 64
			render.DrawSprite(self:GetPos() + self:GetUp() * 116, size, size, COLOR_YELLOW)
		else
			local size = math.sin((RealTime() + self.Seed) * 4) * 8 + 64
			render.DrawSprite(self:GetPos() + self:GetUp() * 116, size, size, COLOR_CYAN)
		end
	end
end

function ENT:OnRemove()
	self.AlarmSound:Stop()
end

function ENT:Initialize()
	self.NextRequest = 0
	self.MaxManaStorage = 500
	self.Seed = math.Rand(0, 10)
	self.AlarmSound = CreateSound(self, "ambient/alarms/combine_bank_alarm_loop4.wav")
end

function ENT:Think()
	if self:GetSkin() < 51 then
		local c = self:GetColor()
		if c.a == 255 then
			self.AlarmSound:PlayEx(0.5, math.sin(CurTime()) + 150)
		end
	else
		self.AlarmSound:Stop()
	end
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
	self.MaxManaStorage = tonumber(stuff[3])
end

ENT.MaxTraceHUDPaintLength = 256

function ENT:TraceHUDPaint()
	if self.PHealth then
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText("Mana Capacitor", "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		y = y + hhh * 1.2
		local boxy = y
		surface.SetDrawColor(0, 0, 0, 255)
		surface.DrawRect(x - 100, y, 200, hhh * 1.75)
		surface.SetDrawColor(255, 0, 0, 255)
		local health = self.PHealth
		local maxhealth = self.MaxPHealth
		surface.DrawRect(x - 100, y, (health / maxhealth) * 200, hhh)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - 100, y, 200, hhh)
		draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)

		y = y + hhh

		local mana = self:GetSkin()
		local maxmana = self.MaxManaStorage
		surface.SetDrawColor(30, 30, 255, 255)
		surface.DrawRect(x - 100, y, (mana / maxmana) * 200, hhh * 0.75)
		draw.DrawText(mana.." / "..maxmana, "Default", x, y, color_white, TEXT_ALIGN_CENTER)
		surface.SetDrawColor(255, 255, 255, 255)
		surface.DrawOutlinedRect(x - 100, boxy, 200, hhh * 1.75)
		surface.DrawLine(x - 100, boxy + hhh, x + 100, boxy + hhh)

		y = y + hhh

		if self:GetSkin() == 0 then
			draw.SimpleText("(NO MANA)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		elseif self:GetSkin() < 51 then
			draw.SimpleText("(LOW MANA)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		end
	end

	if not self.DeniedAccess and CurTime() > self.NextRequest then
		MySelf:ConCommand("ReqInfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end