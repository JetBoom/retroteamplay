include("shared.lua")

local matGlow = Material("sprites/light_glow02_add")

function ENT:Initialize()
	self.Rotation = 0
	self:SetRenderBounds(Vector(-128, -128, -72), Vector(128, 128, 90))
	//self.Emitter = ParticleEmitter(self:GetPos())
end

ENT.MaxTraceHUDPaintLength = 1024

function ENT:TraceHUDPaint()
	local myteam = self:GetTeamID() or 0
	--[[if myteam == MySelf:Team() then
		GAMEMODE:MakeTip("This is your team's core. Defend it at all costs! It's health is displayed in the top left of your screen. Feed it Mana via translocators to shield it!")
	else
		GAMEMODE:MakeTip("It's an enemy core! Your team must destroy it to win!")
	end]]

	local toscreen = self:GetPos():ToScreen()
	local x, y = toscreen.x, toscreen.y
	draw.SimpleText("Core - "..team.GetName(myteam), "teamplay", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)
	local _, hhh = surface.GetTextSize("A")
	y = y + hhh * 1.2
	local boxy = y
	surface.SetDrawColor(0, 0, 0, 255)
	surface.DrawRect(x - 100, y, 200, hhh * 1.75)
	surface.SetDrawColor(255, 0, 0, 255)
	local health = team.GetScore(myteam)
	local maxhealth = CORE_HEALTH
	surface.DrawRect(x - 100, y, (health / maxhealth) * 200, hhh)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawOutlinedRect(x - 100, y, 200, hhh)
	draw.SimpleText(health.." / "..maxhealth, "teamplaytargetidsmall", x, y, COLOR_CYAN, TEXT_ALIGN_CENTER)

	y = y + hhh

	local mana = GetGlobalInt("shield"..myteam, 0)
	local maxmana = CORE_MAX_MANA
	surface.SetDrawColor(30, 30, 255, 255)
	surface.DrawRect(x - 100, y, (mana / maxmana) * 200, hhh * 0.75)
	draw.DrawText(mana.." / "..maxmana, "Default", x, y, color_white, TEXT_ALIGN_CENTER)
	surface.SetDrawColor(255, 255, 255, 255)
	surface.DrawOutlinedRect(x - 100, boxy, 200, hhh * 1.75)
	surface.DrawLine(x - 100, boxy + hhh, x + 100, boxy + hhh)

	y = y + hhh

	if mana == 0 then
		draw.SimpleText("(NO MANA. SHIELD OFF)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
	elseif mana < 51 then
		draw.SimpleText("(LOW MANA. SHIELD LOW)", "teamplaytargetidsmall", x, y, COLOR_RED, TEXT_ALIGN_CENTER)
	end
end

local matWall = Material("VGUI/white")

function ENT:Draw()
	self:DrawModel()

	if EFFECT_QUALITY < 1 then return end

	local teamid = self:GetTeamID()
	if not teamid then return end
	local score = team.GetScore(teamid) * 0.001

	self.Rotation = self.Rotation + FrameTime() * score

	if self.Rotation > 360 then self.Rotation = self.Rotation - 360 end

	local rsin = math.sin(self.Rotation) * 64
	local rcon = math.cos(self.Rotation) * 64

	local vOffset = Vector(rsin, rcon, 0)

	local c = self:GetColor()

	local drawColor = Color(c.r, c.g, c.b, 200)
	local size =  math.sin(RealTime() * 10) * 90 + 120
	local minisize = size * 0.5

	local pos = self:GetPos()
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, size, size, drawColor)
	render.DrawSprite(pos + vOffset, minisize, minisize, drawColor)
end
