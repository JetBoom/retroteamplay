include("shared.lua")

--util.PrecacheSound("NPC_dog.Idlemode_loop")
util.PrecacheSound("ambient/machines/laundry_machine1_amb.wav")
function ENT:Initialize()
	self.Seed = math.Rand(0, 10000)
	self.Thrust = 0
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(120, 140)
	self.NextSmoke = 0

	self.ThrusterSound = CreateSound(self, "ambient/machines/laundry_machine1_amb.wav")
	self.PlayingSound = false
	self.Pilot = NULL
	self.TailGunner = NULL
end

function ENT:CalcViewFirstFunc(seat, ply, origin, angles, fov, znear, zfar)
	if ply == self.Pilot then
		return {origin = origin, angles = self:GetAngles()}
	end
end

function ENT:CalcViewFunc(seat, ply, origin, angles, fov, znear, zfar)
	local view = {}

	if not self.CalcViewOffsetOut then
		local min, max = self:WorldSpaceAABB()
		local size = max - min

		self.CalcViewOffsetOut = size:Length() * 1.5
	end

	if ply == self.TailGunner then
		RunConsoleCommand("gmod_vehicle_viewmode", 0)
		return {}
	end

	local Offset = self:GetForward() * -self.CalcViewOffsetOut

	local TargetOrigin = self:GetPos() + Offset
	local distance = origin - TargetOrigin

	local filt = {self, par}
	filt = table.Add(filt, ents.FindByClass("vehiclepart"))
	filt = table.Add(filt, ents.FindByClass("prop_vehicle_prisoner_pod"))
	filt = table.Add(filt, player.GetAll())
	local tr = util.TraceLine({start = origin, endpos = TargetOrigin, filter = filt})

	angles = self:GetAngles()
	view.angles = angles
	view.origin = origin + tr.Normal * (distance:Length() - 10) * tr.Fraction

	return view
end

function ENT:Think()
	self.Thrust = math.Approach(self.Thrust, self:GetThrust(), FrameTime() * 600) -- Smoothing
	self.Emitter:SetPos(self:GetPos())
	if self:GetSkin() ~= 1 then
		self.ThrusterSound:Stop()
	elseif self:GetSkin() ~= 0 then
		self.ThrusterSound:PlayEx(0.9, math.min(255, 70 + self:GetVelocity():Length() * 0.1))
	end
end

function ENT:SetThrust(fThrust)
	self:SetNetworkedFloat("thrust", fThrust)
end

function ENT:OnRemove()
	self.ThrusterSound:Stop()
	self.Emitter:Finish()
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

	local getpos = self:GetPos()
	local startpos = getpos + self:GetForward() * 70
	local pos = util.TraceLine({start=startpos, endpos = startpos + self:GetForward() * 8000, filter = self, mask = MASK_SOLID}).HitPos:ToScreen()
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
	--[[local x, y = pos.x, pos.y
	local w2 = w * 0.015
	surface.SetDrawColor(255, 230, 0, 200)
	surface.DrawLine(x - w2, y, x + w2, y)
	surface.DrawLine(x, y - w2, x, y + w2)]]

	surface.SetDrawColor(255, 255, 255, 200)
	local x2 = w * 0.375
	y = h * 0.5
	surface.DrawLine(x2, y - 100, x2, y + 100)
	surface.DrawLine(x2, y - 100, x2 + 16, y - 100)
	surface.DrawLine(x2, y + 100, x2 + 16, y + 100)
	surface.SetDrawColor(255, 0, 0, 200)
	local siz = self.Thrust / 2500 * 200 - 2
	if 0 < siz then
		surface.DrawRect(x2 + 1, y + 99 - siz, 11, siz)
	end
	local sep = y + 28
	surface.SetDrawColor(0, 255, 0, 200)
	surface.DrawLine(x2, sep, x2 + 16, sep)
	draw.SimpleText("Thrust: "..math.floor(self.Thrust), "Default", x2, y + 104, COLOR_RED, TEXT_ALIGN_LEFT)
	local speed = self:GetVelocity():Length()
	draw.SimpleText("Velocity: "..math.floor(speed), "Default", x2, y + 120, speed >= 500 and COLOR_LIMEGREEN or COLOR_RED, TEXT_ALIGN_LEFT)

	surface.SetFont("DefaultSmall")
	local lw, lh = surface.GetTextSize("Tail Gunner: ------------------------------------------")
	local x = w * 0.5
	local y = h * 0.89

	draw.RoundedBox(4, x - lw * 0.5, y - 4, lw, h * 0.11, color_black_alpha90)

	if self.Pilot:IsValid() then
		draw.SimpleText("Pilot: "..self.Pilot:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
	if self.TailGunner:IsValid() then
		draw.SimpleText("Tail Gunner: "..self.TailGunner:Name(), "DefaultSmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
		y = y + lh
	end
end

function ENT:Draw()
	self:DrawModel()

	--[[local vNormal = self:GetForward() * -1
	local pos = self:GetPos()

	if self.NextSmoke < CurTime() then
		self.NextSmoke = CurTime() + math.max(0.02, EFFECT_IQUALITY * 0.038)
		local right = self:GetRight()
		local particle = self.Emitter:Add("particles/smokey", pos + right * 92 + vNormal * 92)
		particle:SetVelocity(VectorRand() * 8)
		particle:SetDieTime(1.9)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(14, 16))
		particle:SetEndSize(4)
		particle:SetRoll(math.random(0, 360))
		local col = team.GetColor(self:Team())
		particle:SetColor(col.r, col.g, col.b)

		local particle = self.Emitter:Add("particles/smokey", pos + right * -92 + vNormal * 92)
		particle:SetVelocity(VectorRand() * 8)
		particle:SetDieTime(1.9)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(math.Rand(14, 16))
		particle:SetEndSize(4)
		particle:SetRoll(math.random(0, 360))
		local col = team.GetColor(self:Team())
		particle:SetColor(col.r, col.g, col.b)
	end]]
end

usermessage.Hook("RecVD", function(um)
	local ent = um:ReadEntity()

	if ent:IsValid() then
		ent.Pilot = um:ReadEntity() or NULL
		ent.TailGunner = um:ReadEntity() or NULL
	end
end)
