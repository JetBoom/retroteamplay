include('shared.lua')

function ENT:Draw()
	self:DrawModel()
end

function ENT:Initialize()
	self.AmbientSound = CreateSound(self, "ambient/machines/thumper_amb.wav")
end

function ENT:CalcViewFirstFunc(seat, ply, origin, angles, fov, znear, zfar)
	return {origin = origin, angles = self:GetAngles()}
end

function ENT:Think()
	if self:GetSkin() ~= 1 then
		self.AmbientSound:Stop()
	elseif self:GetSkin() ~= 0 then
		self.AmbientSound:PlayEx(0.9, math.min(255, self:GetVelocity():Length() * 0.13 + 85))
	end
end

function ENT:OnRemove()
	self.AmbientSound:Stop()
end

ENT.MaxTraceHUDPaintLength = 1500

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
		draw.SimpleText(self.Name, "teamplay", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		local _, hhh = surface.GetTextSize("A")
		draw.SimpleText(team.GetName(self:Team()), "DefaultBold", x, y + hhh, COLOR_RED, TEXT_ALIGN_CENTER)
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
	draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y + hhh * 0.5, COLOR_CYAN, TEXT_ALIGN_CENTER)
	local gun = self:GetNetworkedEntity("gun", NULL)
	if gun:IsValid() then
		local filt = ents.FindByClass("projectile_*")
		table.insert(filt, gun)
		local dir = self:GetForward()
		local aimvec = MySelf:GetAimVector()
		dir.z = math.Clamp(aimvec.z, dir.z - 0.25, dir.z + 0.25)
		dir = dir:GetNormal()
		local startpos = gun:GetPos()
		local pos = util.TraceLine({start=startpos, endpos = startpos + dir * 4096, filter = filt, mask = MASK_SOLID}).HitPos:ToScreen()
		GAMEMODE:DrawCrosshair(pos.x, pos.y, 32, COLOR_RED)
		--[[local x, y = pos.x, pos.y
		surface.SetDrawColor(255, 0, 0, 200)
		surface.DrawLine(x - 48, y, x + 48, y)
		surface.DrawLine(x, y - 48, x, y + 48)
		surface.SetDrawColor(255, 255, 255, 200)
		surface.DrawOutlinedRect(x - 48, y - 48, 96, 96)]]

		local pos = (startpos + aimvec * 4096):ToScreen()
		GAMEMODE:DrawCrosshair(pos.x, pos.y, 24, COLOR_YELLOW)
		--[[local x, y = pos.x, pos.y
		surface.SetDrawColor(255, 230, 0, 200)
		surface.DrawLine(x - 48, y, x + 48, y)
		surface.DrawLine(x, y - 48, x, y + 48)]]
	end
end
