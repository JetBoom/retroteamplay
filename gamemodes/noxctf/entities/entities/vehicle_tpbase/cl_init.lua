include("shared.lua")

ENT.MaxTraceHUDPaintLength = 2048

ENT.NextSmoke = 0

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
end

function ENT:Draw()
	self:DrawModel()

	if self:GetPilot():IsValid() and self.NextSmoke <= RealTime() then
		self.NextSmoke = RealTime() + 0.1

		local particle = self.Emitter:Add("particles/smokey", self:GetPos() + self:GetForward() * -85 + self:GetRight() * 26)
		particle:SetStartAlpha(100)
		particle:SetEndAlpha(0)
		particle:SetDieTime(math.Rand(1.5, 2))
		particle:SetStartSize(8)
		particle:SetEndSize(math.Rand(12, 16))
		particle:SetGravity(Vector(0, 0, 10))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetCollide(true)
		particle:SetBounce(0.1)
		particle:SetVelocity(self:GetForward() * -16)
		local brightness = (self:GetVHealth() / self:GetMaxVHealth()) * 220
		particle:SetColor(brightness, brightness, brightness)
	end
end

function ENT:TraceHUDPaint()
	if self:GetTeamID() == MySelf:GetTeamID() then
		GAMEMODE:GenericVehicleHealthBar(self)
	end
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

function ENT:DrawHUD(seat)
	if seat == self:GetGunnerSeat() then
		local cannon = self:GetCannon()
		if cannon:IsValid() then
			local up = cannon:GetUp()
			up.z = math.Clamp(MySelf:GetAimVector().z, up.z - 0.6, up.z + 0.6)
			up:Normalize()
			local startpos = cannon:GetPos() + up * 48
			local pos = util.TraceLine({start=startpos, endpos = startpos + up * 4096, filter = ents.FindByClass("projectile_*"), mask = MASK_SOLID}).HitPos:ToScreen()
			GAMEMODE:DrawCrosshair(pos.x, pos.y, 32, COLOR_RED)
		end
	end

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
