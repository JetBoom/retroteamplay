include("shared.lua")

function ENT:CalcViewFirstFunc(seat, ply, origin, angles, fov, znear, zfar)
	return {origin = origin, angles = self:GetAngles()}
end

function ENT:CalcViewFunc(seat, ply, origin, angles, fov, znear, zfar)
	local view = {}

	local camerapos
	if self.LockedThirdPersonCamera then
		camerapos = self:GetPos() + self:GetForward() * self.ThirdPersonCamera.x + self:GetRight() * self.ThirdPersonCamera.y + self:GetUp() * self.ThirdPersonCamera.z
		view.angles = self:GetAngles()
	else
		camerapos = origin + angles:Forward() * -(self.CameraDistance or (self:OBBMaxs() - self:OBBMins()):Length() * 1.4)
	end

	local filter = {self}
	filter = table.Add(filter, ents.FindByClass("vehiclepart"))
	filter = table.Add(filter, ents.FindByClass("prop_vehicle_*"))
	filter = table.Add(filter, player.GetAll())
	local tr = util.TraceLine({start = origin, endpos = camerapos, mask = MASK_SHOT, mins = Vector(-4, -4, -4), maxs = Vector(4, 4, 4), filter = filter})

	view.origin = tr.HitPos + tr.HitNormal * 2

	return view
end

ENT.MaxTraceHUDPaintLength = 1500

function ENT:TraceHUDPaint()
	if self:GetTeamID() == MySelf:GetTeamID() then
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
		draw.SimpleText(health.." / "..maxhealth, "tp_targetid_small", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
	elseif self:GetTeamID() > 0 then
		local toscreen = self:GetPos():ToScreen()
		local x, y = toscreen.x, toscreen.y
		draw.SimpleText(self.Name, "teamplay", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		draw.SimpleText(team.GetName(self:GetTeamID()), "DefaultFontBold", x, y + hhh, COLOR_RED, TEXT_ALIGN_CENTER)
	end
end

function ENT:DrawHUD(seat)
	local x, y = w * 0.5, h * 0.8
	draw.SimpleText(self.Name, "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
	local _, hhh = surface.GetTextSize("A")
	y = y + hhh * 1.2
	surface.SetDrawColor(255, 0, 0, 255)
	local health = self:GetVHealth()
	local maxhealth = self:GetMaxVHealth()
	surface.DrawRect(x - w * 0.1, y, (health / maxhealth) * w * 0.2, h * 0.04)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawOutlinedRect(x - w * 0.1, y, w * 0.2, h * 0.04)
	draw.SimpleText(health.." / "..maxhealth, "tp_targetid_small", x, y + hhh * 0.5, COLOR_CYAN, TEXT_ALIGN_CENTER)

	local startpos = self:GetPos() + self:GetForward() * 70
	local pos = util.TraceLine({start=startpos, endpos = startpos + self:GetForward() * 8000, filter = self}).HitPos:ToScreen()
	GAMEMODE:DrawCrosshair(pos.x, pos.y, 32, COLOR_RED)
	--[[local x, y = pos.x, pos.y
	local w2 = w * 0.015
	surface.SetDrawColor(255, 0, 0, 200)
	surface.DrawLine(x - w2, y, x + w2, y)
	surface.DrawLine(x, y - w2, x, y + w2)
	surface.SetDrawColor(255, 255, 255, 200)
	local w3 = w2 * 1.5
	local w4 = w3 * 2
	surface.DrawOutlinedRect(x - w3, y - w3, w4, w4)]]

	local pos = (startpos + MySelf:GetAimVector() * 4096):ToScreen()
	GAMEMODE:DrawCrosshair(pos.x, pos.y, 24, COLOR_YELLOW)
end

function ENT:TeamSet(newteamid)
end
