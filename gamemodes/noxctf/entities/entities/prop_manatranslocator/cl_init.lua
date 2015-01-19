include("shared.lua")

function ENT:Initialize()
	self.NextRequest = 0
	self.NextEmit = 0
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(35, 40)
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
		draw.SimpleText("Mana Translocator", "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
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
		if not self.Capacitor then
			y = y + hhh
			draw.SimpleText("(NOT ATTACHED TO A CAPACITOR)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		end
		if not self.TargetCapacitor then
			y = y + hhh
			draw.SimpleText("(NOT POINTING AT A TARGET CAPACITOR)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		end
	end

	if not self.DeniedAccess and self.NextRequest < CurTime() then
		MySelf:ConCommand("ReqInfo "..self:EntIndex())
		self.NextRequest = CurTime() + 0.75
	end
end

local matBeam = Material("effects/laser1")
function ENT:Draw()
	self:DrawModel()

	if GAMEMODE.EyeTraceEntity == self then
		local c = self:GetColor()

		local start = self:GetPos()
		local up = self:GetUp()

		render.SetMaterial(matBeam)
		local endpos = start + up * -40
		local trent = util.TraceLine({start=start, endpos=endpos, filter=self}).Entity
		self.Capacitor = trent:IsValid() and trent.CanTakeMana and not trent.NoTranslocate
		if self.Capacitor then
			if c.a ~= 255 then
				render.DrawBeam(start, endpos, 4, 1, 0, COLOR_LIMEGREEN)
			end
		else
			render.DrawBeam(start, endpos, 4, 1, 0, COLOR_RED)
		end

		start = start + up * 24
		local endpos = start + up * 64000
		trent = util.TraceLine({start=start, endpos=endpos, filter=self}).Entity
		self.TargetCapacitor = trent:IsValid() and trent.CanTakeMana
		if self.TargetCapacitor then
			if c.a ~= 255 then
				render.DrawBeam(start, endpos, 4, 1, 0, COLOR_LIMEGREEN)
			end
		else
			render.DrawBeam(start, endpos, 4, 1, 0, COLOR_RED)
		end
	end
end
