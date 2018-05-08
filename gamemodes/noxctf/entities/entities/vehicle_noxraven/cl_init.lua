include("shared.lua")

util.PrecacheSound("NPC_dog.Idlemode_loop")
function ENT:Initialize()
	self.Seed = math.Rand(0, 10000)
	self.Thrust = 0
	--self.AfterBurner = 0
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(120, 140)
	self.NextSmoke = 0

	self.ThrusterSound = CreateSound(self, "ambient/levels/citadel/zapper_loop2.wav")
	--self.AfterBurnerSound = CreateSound(self, "weapons/rpg/rocket1.wav")
end

function ENT:Think()
	self.Thrust = math.Approach(self.Thrust, self:GetThrust(), FrameTime() * 1200) -- Smoothing
	--self.AfterBurner = math.Approach(self.AfterBurner, self:GetAfterBurner(), FrameTime() * 1200)
	self.Emitter:SetPos(self:GetPos())

	local skin = self:GetSkin()
	if skin == 0 then
		self.ThrusterSound:Stop()
	elseif skin == 1 then
		self.ThrusterSound:PlayEx(0.95, math.min(255, 35 + self:GetVelocity():Length() * 0.135))
		--[[self.AfterBurnerSound:Stop()
	elseif skin == 2 then
		self.ThrusterSound:Stop()
		self.AfterBurnerSound:PlayEx(0.95, math.min(255, 35 + self:GetVelocity():Length() * 0.125))]]
	end
end

function ENT:CalcViewFirstFunc(seat, ply, origin, angles, fov, znear, zfar)
	return {origin = origin, angles = self:GetAngles()}
end

function ENT:CalcViewFunc(seat, ply, origin, angles, fov, znear, zfar)
	local view = {}

	if not self.CalcViewOffsetOut then
		local min, max = self:WorldSpaceAABB()
		local size = max - min
		self.CalcViewOffsetOut = size:Length() * 3
	end

	local Offset = self:GetForward() * -self.CalcViewOffsetOut

	local TargetOrigin = self:GetPos() + Offset
	local distance = origin - TargetOrigin

	local filt = {self, par}
	filt = table.Add(filt, ents.FindByClass("vehiclepart"))
	filt = table.Add(filt, ents.FindByClass("prop_vehicle_prisoner_pod"))
	filt = table.Add(filt, player.GetAll())
	local tr = util.TraceLine({start = origin, endpos = TargetOrigin, filter = filt})

	view.origin = origin + tr.Normal * (distance:Length() - 10) * tr.Fraction

	view.angles = self:GetAngles()

	return view
end

function ENT:SetThrust(fThrust)
	self:SetNetworkedFloat("thrust", fThrust)
end

function ENT:OnRemove()
	self.ThrusterSound:Stop()
	--self.AfterBurnerSound:Stop()
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
	local sep = y
	surface.SetDrawColor(0, 255, 0, 200)
	surface.DrawLine(x2, sep, x2 + 16, sep)
	draw.SimpleText("Thrust: "..math.floor(self.Thrust), "Default", x2, y + 104, COLOR_RED, TEXT_ALIGN_LEFT)
end

function ENT:Draw()
	self:DrawModel()

	local Scale = self.Thrust / 1800
	if Scale < 0.05 then return end

	if self.NextSmoke <= CurTime() then
		self.NextSmoke = CurTime() + 0.025

		local fwd = self:GetForward()
		local pos = self:GetPos() + fwd * -64

		local particle = self.Emitter:Add("effects/fire_cloud"..math.random(1,2), pos)
		particle:SetDieTime(math.Rand(0.6, 0.75))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(Scale * 18)
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-100, 100))

		local ang = self:GetForward():Angle()
		local grav = -130 * Scale * fwd
		ang:RotateAroundAxis(fwd, CurTime() * 120)
		for i=1, 3 do
			ang:RotateAroundAxis(fwd, 120)

			local particle = self.Emitter:Add("effects/fire_cloud"..math.random(1,2), pos)
			particle:SetVelocity(Scale * 100 * ang:Up())
			particle:SetGravity(grav)
			particle:SetDieTime(math.Rand(0.5, 0.65))
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(0)
			particle:SetStartSize(Scale * 6)
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-100, 100))
		end
	end
end

function RLO()
	surface.PlaySound("ambient/alarms/klaxon1.wav")
	timer.Simple(0.6, function() surface.PlaySound("ambient/alarms/klaxon1.wav") end)
	timer.Simple(1.2, function() surface.PlaySound("ambient/alarms/klaxon1.wav") end)
end
