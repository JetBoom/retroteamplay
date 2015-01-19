include("shared.lua")

function ENT:CalcViewFirstFunc(seat, ply, origin, angles, fov, znear, zfar)
	if ply == self:GetPilotSeat():GetOwner() then
		return {origin = origin, angles = self:GetAngles()}
	end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(48, 64)

	self.ThrusterSound = CreateSound(self, "ambient/machines/laundry_machine1_amb.wav")
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())

	self.ThrusterSound:PlayEx(0.9, 70 + math.min(1, self:GetVelocity():Length() / self.MaxSpeed) * 100)
end

function ENT:OnRemove()
	self.ThrusterSound:Stop()
	--self.Emitter:Finish()
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
	
	local startpos
	if seat == self:GetPilotSeat() then
		startpos = self:GetPos() + self:GetForward() * 70
		local pos = util.TraceLine({start=startpos, endpos = startpos + self:GetForward() * 8000, filter = self}).HitPos:ToScreen()
		GAMEMODE:DrawCrosshair(pos.x, pos.y, 32, COLOR_RED)
	else
		startpos = MySelf:GetShootPos()
	end
	
	local pos = (startpos + MySelf:GetAimVector() * 4096):ToScreen()
	GAMEMODE:DrawCrosshair(pos.x, pos.y, 24, COLOR_YELLOW)

	surface.SetFont("DefaultFontSmall")
	local lw, lh = surface.GetTextSize("Driver: ------------------------------------------")
	local x = w * 0.5
	local y = h * 0.89
	
	draw.RoundedBox(4, x - lw * 0.5, y - 4, lw, h * 0.11, color_black_alpha90)

	local seat = self:GetPilotSeat()
	if seat:IsValid() and seat:GetOwner():IsValid() then
		draw.SimpleText("Driver: "..seat:GetOwner():Name(), "DefaultFontSmall", x, y, color_white, TEXT_ALIGN_CENTER)
		y = y + lh
	end

	local seat = self:GetGunnerSeat()
	if seat:IsValid() and seat:GetOwner():IsValid() then
		draw.SimpleText("Gunner: "..seat:GetOwner():Name(), "DefaultFontSmall", x, y, color_white, TEXT_ALIGN_CENTER)
	end
end