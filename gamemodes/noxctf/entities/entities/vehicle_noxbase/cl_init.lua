include("shared.lua")

ENT.MaxTraceHUDPaintLength = 2048

ENT.NextSmoke = 0

--[[local EngineStart = Sound("ATV_engine_start")
local EngineIdleSlow = Sound("ATV_throttleoff_slowspeed")
local EngineIdle = Sound("ATV_throttleoff_fastspeed")
local EngineForward = Sound("ATV_firstgear")]]

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())

	--[[self.IdleSound = CreateSound(self, EngineIdle)
	self.IdleSlowSound = CreateSound(self, EngineIdleSlow)
	self.StartSound = CreateSound(self, EngineStart)
	self.ForwardSound = CreateSound(self, EngineForward)]]
end

function ENT:Draw()
	--self:SetColor(Color(255, 255, 255, 0))
	self:DrawModel()

	if self:GetState() ~= STATE_ROVER_OFF and self.NextSmoke <= RealTime() then
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
	if self:Team() == MySelf:Team() then
		GAMEMODE:GenericVehicleHealthBar(self)
	end
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())

	--[[local state = self:GetState()
	if state == STATE_ROVER_OFF then
		self.IdleSound:Stop()
		self.IdleSlowSound:Stop()
		self.StartSound:Stop()
		self.ForwardSound:Stop()
	elseif state == STATE_ROVER_IDLE then
		if self.NextFastIdle and CurTime() >= self.NextFastIdle then
			self.IdleSound:PlayEx(1, 100 + math.sin(RealTime()))
			self.IdleSlowSound:Stop()
		else
			self.NextFastIdle = nil
			self.IdleSound:Stop()
			self.IdleSlowSound:PlayEx(1, 100 + math.sin(RealTime()))
		end

		self.StartSound:Stop()
		self.ForwardSound:Stop()
	elseif state == STATE_ROVER_ACCELERATING then
		self.IdleSound:Stop()
		self.IdleSlowSound:Stop()
		self.StartSound:Stop()
		self.ForwardSound:PlayEx(1, 100 + math.sin(RealTime()))
		if not self.NextFastIdle then
			self.NextFastIdle = CurTime() + 2
		end
	end]]
end

function ENT:OnRemove()
	self.Emitter:Finish()

	--[[self.IdleSound:Stop()
	self.IdleSlowSound:Stop()
	self.StartSound:Stop()
	self.ForwardSound:Stop()]]
end

function ENT:DrawHUD(seat)
	if seat == self:GetGunnerSeat() then
		local cannon = self:GetCannon()
		if cannon:IsValid() then
			local up = cannon:GetUp()
			up.z = math.Clamp(MySelf:GetAimVector().z, up.z - 0.6, up.z + 0.6)
			up = up:GetNormal()
			local startpos = cannon:GetPos() + up * 48
			local pos = util.TraceLine({start=startpos, endpos = startpos + up * 4096, filter = ents.FindByClass("projectile_*"), mask = MASK_SOLID}).HitPos:ToScreen()
			GAMEMODE:DrawCrosshair(pos.x, pos.y, 32, COLOR_RED)
			--[[local x, y = pos.x, pos.y
			local w2 = w * 0.02
			local w22 = w2 * 0.75
			local w222 = w2 * 1.5
			surface.SetDrawColor(40, 255, 40, 200)
			surface.DrawLine(x - w222, y, x + w222, y)
			surface.DrawLine(x, y - w22, x, y + w22)

			surface.SetDrawColor(255, 0, 0, 180)
			surface.DrawOutlinedRect(x - w22, y - w22, w222, w222)]]
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
	draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y + hhh * 0.5, COLOR_CYAN, TEXT_ALIGN_CENTER)

	surface.SetFont("DefaultSmall")
	local lw, lh = surface.GetTextSize("Driver: ------------------------------------------")
	local x = w * 0.5
	local y = h * 0.89

	--draw.RoundedBox(4, x - lw * 0.5, y - 4, lw, h * 0.11, color_black_alpha90)

	local seat = self:GetPilotSeat()
	if seat:IsValid() and seat:GetOwner():IsValid() then
		draw.SimpleText("Driver: "..seat:GetOwner():Name(), "DefaultSmall", x, y, color_white, TEXT_ALIGN_CENTER)
		y = y + lh
	end

	local seat = self:GetGunnerSeat()
	if seat:IsValid() and seat:GetOwner():IsValid() then
		draw.SimpleText("Gunner: "..seat:GetOwner():Name(), "DefaultSmall", x, y, color_white, TEXT_ALIGN_CENTER)
	end
end
