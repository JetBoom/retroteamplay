MySelf = MySelf or NULL
hook.Add("InitPostEntity", "GetLocal", function()
	MySelf = LocalPlayer()

	GAMEMODE.HookGetLocal = GAMEMODE.HookGetLocal or (function(g) end)
	gamemode.Call("HookGetLocal", MySelf)
	RunConsoleCommand("initpostentity")
end)

w, h = ScrW(), ScrH()

include("modules/animationsapi/cl_boneanimlib.lua")
include("modules/animationsapi/cl_animeditor.lua")

include("shared.lua")

include("cl_scoreboard.lua")
include("cl_dermaskin.lua")
include("cl_targetid.lua")
include("cl_deathnotice.lua")
include("cl_notice.lua")
include("cl_noxious_localization.lua")
include("cl_votemap.lua")

include("vgui/dexroundedpanel.lua")
include("vgui/dexroundedframe.lua")
include("vgui/dexchanginglabel.lua")
include("vgui/dexpingbars.lua")

include("vgui/vehiclepad.lua")
include("vgui/pbuilder.lua")
include("vgui/pspells.lua")
include("vgui/pclasses.lua")
include("vgui/phelp.lua")
include("vgui/poptions.lua")
include("vgui/pteamselect.lua")

include("nox_shared_spelldefines.lua")

include("vehicles_shared.lua")

include("gametypes/cl_assault.lua")
include("gametypes/cl_blitz.lua")
include("gametypes/cl_harvest.lua")
include("gametypes/cl_ctf.lua")
include("gametypes/cl_holdtheflag.lua")
include("gametypes/cl_kingofthehill.lua")

GM.GibModels = {
	Model("models/gibs/HGIBS.mdl"),
	Model("models/gibs/HGIBS_spine.mdl"),
	Model("models/gibs/HGIBS_rib.mdl"),
	Model("models/gibs/HGIBS_scapula.mdl"),
	Model("models/gibs/antlion_gib_medium_2.mdl"),
	Model("models/gibs/Antlion_gib_Large_1.mdl"),
	Model("models/gibs/Strider_Gib4.mdl")
}

SPELL_SHEETS = {}
SPELL_SHEETS["Default"] = {}
DelayIcons = {}

function BroadcastLua(lua)
	RunString(lua)
end

-- Scales the screen based around 1080p but doesn't make things TOO tiny on low resolutions.
function BetterScreenScale()
	return math.max(0.6, math.min(1, ScrH() / 1080))
end

function WordBox(parent, text, font, textcolor)
	local cpanel = vgui.Create("DPanel", parent)
	local label = EasyLabel(cpanel, text, font, textcolor)
	local tsizex, tsizey = label:GetSize()
	cpanel:SetSize(tsizex + 16, tsizey + 8)
	label:SetPos(8, (tsizey + 8) * 0.5 - tsizey * 0.5)
	cpanel:SetVisible(true)
	cpanel:SetMouseInputEnabled(false)
	cpanel:SetKeyboardInputEnabled(false)

	return cpanel
end

function EasyLabel(parent, text, font, textcolor)
	local dpanel = vgui.Create("DLabel", parent)
	if font then
		dpanel:SetFont(font or "Default")
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()
	if textcolor then
		dpanel:SetTextColor(textcolor)
	end
	dpanel:SetKeyboardInputEnabled(false)
	dpanel:SetMouseInputEnabled(false)

	return dpanel
end

function EasyButton(parent, text, xpadding, ypadding)
	local dpanel = vgui.Create("DButton", parent)
	if textcolor then
		dpanel:SetFGColor(textcolor or color_white)
	end
	if text then
		dpanel:SetText(text)
	end
	dpanel:SizeToContents()

	if xpadding then
		dpanel:SetWide(dpanel:GetWide() + xpadding * 2)
	end

	if ypadding then
		dpanel:SetTall(dpanel:GetTall() + ypadding * 2)
	end

	return dpanel
end

function GM:SpawnMenuEnabled()
	return false
end

function GM:SpawnMenuOpen()
	return false
end

function GM:ContextMenuOpen()
	return false
end

local eyetrace
local eyetraceentity = NULL

GM.EyeTraceEntity = NULL

GM.PrevHealth = 0
function GM:_Think()
	eyetrace = MySelf:TraceLine(4096)
	eyetraceentity = eyetrace.Entity
	self.EyeTraceEntity = eyetraceentity

	MySelf:GetViewModel():SetAlpha(MySelf:GetAlpha()) -- TODO: use a prerender hook for this garbage.

	local health = MySelf:Health()
	if health < self.PrevHealth then
		self.HurtEffect = math.min(self.HurtEffect + (self.PrevHealth - health) * 0.02, 1.5)
	else
		self.HurtEffect = math.max(0, self.HurtEffect - FrameTime() * 0.65)
	end
	self.PrevHealth = health
end

CreateClientConVar("nox_declinefriendlyteleports", 0, true, true)

local headtilt = CreateClientConVar("tp_view_headtilt", 1, true, false):GetBool()
cvars.AddChangeCallback("tp_view_headtilt", function(cvar, oldvalue, newvalue)
	headtilt = newvalue == "1"
end)

local hud_HealthX = CreateClientConVar("nox_hud_health_x", 0.02, true, false)
local hud_HealthY = CreateClientConVar("nox_hud_health_y", 0.9, true, false)

local hud_NBarX = CreateClientConVar("nox_hud_nbar_x", 0, true, false)
local hud_NBarY = CreateClientConVar("nox_hud_nbar_y", 1, true, false)

local hud_ManaX = CreateClientConVar("nox_hud_mana_x", 0.125, true, false)
local hud_ManaY = CreateClientConVar("nox_hud_mana_y", 0.9, true, false)

local hud_StatusBarX = CreateClientConVar("nox_hud_statusbar_x", 0.25, true, false)
local hud_StatusBarY = CreateClientConVar("nox_hud_statusbar_y", 0.9, true, false)

local hud_SpellMenuX = CreateClientConVar("nox_hud_spellmenu_x", 0.85, true, false)
local hud_SpellMenuY = CreateClientConVar("nox_hud_spellmenu_y", 0.7, true, false)

local hud_LargeSpellIcons = CreateClientConVar("nox_hud_largespellicons", 1, true, false)

function surface.CreateLegacyFont(font, size, weight, antialias, additive, name, shadow, outline, blursize)
	surface.CreateFont(name, {font = font, size = size, weight = weight, antialias = antialias, additive = additive, shadow = shadow, outline = outline, blursize = blursize})
end

function GM:CreateFonts()
	local screens = math.min(1, ((w / 3640) + 0.5) ^ 2)

	surface.CreateLegacyFont("csd", BetterScreenScale() * 36, 500, true, false, "teamplaydeathnoticecs", false, true)
	
	surface.CreateLegacyFont("coolvetica", 48, 500, true, false, "ScoreboardHead")
	surface.CreateLegacyFont("coolvetica", 24, 500, true, false, "ScoreboardSub")

	surface.CreateLegacyFont("tahoma", 16, 1000, true, false, "NoticeFont", false, true)

	surface.CreateLegacyFont("tahoma", ScreenScale(16), 400, true, false, "healthandmana")

	surface.CreateLegacyFont("tahoma", 18, 300, true, false, "scoreboardfine")

	surface.CreateLegacyFont("tahoma", 24, 500, true, false, "teamplay", false, true)
	surface.CreateLegacyFont("tahoma", 24, 500, true, false, "teamplay_nooutline")
	surface.CreateLegacyFont("tahoma", 24, 500, true, false, "teamplay_teamscores", true, true)
	surface.CreateLegacyFont("tahoma", 32, 400, true, false, "teamplay_scoreboard")
	surface.CreateLegacyFont("tahoma", 22, 600, true, false, "teamplaytargetid", false, true)
	surface.CreateLegacyFont("tahoma", 18, 600, true, false, "teamplaytargetidsmall", false, true)

	surface.CreateLegacyFont("arial", 18, 600, true, false, "tp_targetid_small", false, true)

	surface.CreateLegacyFont("Impact", BetterScreenScale() * 9 + 9, 300, true, false, "ammodisplay")

	surface.CreateLegacyFont("Impact", BetterScreenScale() * 12 + 12, 300, true, false, "teamplay_centerprint")

	surface.CreateLegacyFont("Palatino Linotype", 48 * screens, 500, true, false, "ClassSelect",true, false)
	surface.CreateLegacyFont("Cambria", 28 * screens, 500, true, false, "ClassSelect2")
	surface.CreateLegacyFont("Cambria", 18 * screens, 500, true, false, "ClassSelect3", true, false)
	
	surface.CreateLegacyFont("Impact", 45 * screens, 1, true, false, "NoXHealthBar", false, false)
	surface.CreateLegacyFont("Impact", 30 * screens, 1, true, false, "NoXManaBar", false, false)
	
	-- Default, DefaultBold, DefaultSmall, etc. were changed when gmod13 hit. These are renamed fonts that have the old values.
	surface.CreateFont("DefaultVerySmall", {font = "tahoma", size = 10, weight = 0, antialias = false})
	surface.CreateFont("DefaultSmall", {font = "tahoma", size = 11, weight = 0, antialias = false})
	surface.CreateFont("DefaultSmallDropShadow", {font = "tahoma", size = 11, weight = 0, shadow = true, antialias = false})
	surface.CreateFont("Default", {font = "tahoma", size = 13, weight = 500, antialias = false})
	surface.CreateFont("DefaultBold", {font = "tahoma", size = 13, weight = 1000, antialias = false})
	surface.CreateFont("DefaultLarge", {font = "tahoma", size = 16, weight = 0, antialias = false})
end

function GM:HookGetLocal(pl)
	MySelf.Mana = MySelf.Mana or 0
	MySelf.ManaBase = MySelf.ManaBase or CurTime()

	self.RenderScreenspaceEffects = self._RenderScreenspaceEffects
	self.Think = self._Think
	self.HUDPaint = self._HUDPaint
	self.HUDPaintBackground = self._HUDPaintBackground
	self.CreateMove = self._CreateMove
end

function GM:RestoreHUDDefaults()
	RunConsoleCommand("nox_hud_health_x", tonumber(hud_HealthX:GetDefault()))
	RunConsoleCommand("nox_hud_health_y",  tonumber(hud_HealthY:GetDefault()))
	RunConsoleCommand("nox_hud_mana_x",  tonumber(hud_ManaX:GetDefault()))
	RunConsoleCommand("nox_hud_mana_y",  tonumber(hud_ManaY:GetDefault()))
	RunConsoleCommand("nox_hud_nbar_y",  tonumber(hud_NBarY:GetDefault()))
	RunConsoleCommand("nox_hud_nbar_x",  tonumber(hud_NBarX:GetDefault()))
	RunConsoleCommand("nox_hud_statusbar_x",  tonumber(hud_StatusBarX:GetDefault()))
	RunConsoleCommand("nox_hud_statusbar_y",  tonumber(hud_StatusBarY:GetDefault()))
	RunConsoleCommand("nox_hud_spellmenu_x",  tonumber(hud_SpellMenuX:GetDefault()))
	RunConsoleCommand("nox_hud_spellmenu_y",  tonumber(hud_SpellMenuY:GetDefault()))
	RunConsoleCommand("nox_hud_largespellicons",  tonumber(hud_LargeSpellIcons:GetDefault()))

	RunConsoleCommand("nox_hud_bowcharge_x", 0.5)
	RunConsoleCommand("nox_hud_bowcharge_y", 0.6)
end

function ExplosiveEffect(pos, maxrange, damage, dmgtype)
	local pos2 = pos + Vector(0, 0, 12)
	for _, pl in pairs(player.GetAll()) do
		local rag = pl:GetRagdollEntity()
		if rag and not rag.Frozen then
			local phys = rag:GetPhysicsObject()
			if phys:IsValid() then
				local physpos = phys:GetPos()
				local dist = physpos:Distance(pos)
				if dist < maxrange then
					for i=0, rag:GetPhysicsObjectCount() do
						local subphys = rag:GetPhysicsObjectNum(i)
						if subphys then
							subphys:Wake()
						end
					end

					if dmgtype == DMGTYPE_FIRE then
						phys:ApplyForceOffset(damage * 1000 * maxrange / dist * (physpos - pos):GetNormal(), pos2)
						if not rag.Burnt then
							local effectdata = EffectData()
								effectdata:SetOrigin(physpos)
								effectdata:SetEntity(pl)
							util.Effect("fire_death", effectdata)
							rag:EmitSound("ambient/fire/mtov_flame2.wav", 50, math.random(105, 110))
						end
					elseif dmgtype == DMGTYPE_LIGHTNING then
						phys:ApplyForceOffset(damage * 1000 * maxrange / dist * (physpos - pos):GetNormal(), pos2)
						if not rag.Electricuted then
							local effectdata = EffectData()
								effectdata:SetOrigin(physpos)
								effectdata:SetEntity(pl)
							util.Effect("electric_death", effectdata)
						end
					elseif dmgtype == DMGTYPE_ICE then
						phys:ApplyForceOffset(damage * 500 * maxrange / dist * (physpos - pos):GetNormal(), pos2)
						local effectdata = EffectData()
							effectdata:SetOrigin(physpos)
							effectdata:SetEntity(pl)
						util.Effect("ice_death", effectdata)
					else
						phys:ApplyForceOffset(damage * 1000 * maxrange / dist * (physpos - pos):GetNormal(), pos2)
					end
				end
			end
		end
	end
end
util.ExplosiveForce = ExplosiveEffect

-- DEPRICATED
EFFECT_QUALITY = 2
EFFECT_IQUALITY = 1

function GM:GenericPropHealthBar(ent)
	if ent.PHealth and 0 < ent.MaxPHealth then
		local toscreen = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
		self:DrawHealthBar(toscreen.x, toscreen.y, 240, 24, ent.Name, ent.PHealth.." / "..ent.MaxPHealth, COLOR_LIMEGREEN, ent.PHealth, ent.MaxPHealth)
	end
end

function GM:GenericVehicleHealthBar(ent)
	local toscreen = ent:LocalToWorld(ent:OBBCenter()):ToScreen()
	self:DrawHealthBar(toscreen.x, toscreen.y, 240, 24, ent.Name, ent:GetVHealth().." / "..ent:GetMaxVHealth(), COLOR_LIMEGREEN, ent:GetVHealth(), ent:GetMaxVHealth())
end

local texHealthBar = surface.GetTextureID("gui/gradient_down")
function GM:DrawHealthBar(x, y, width, height, name, inbartext, namecolor, health, maxhealth)
	local screenscale = BetterScreenScale()
	local wid = math.ceil(screenscale * width)
	local hei = math.ceil(screenscale * height)
	x = math.Round(x)
	y = math.Round(y)

	if name then
		draw.SimpleText(name, "teamplaytargetid", x, y, namecolor, TEXT_ALIGN_CENTER)
		local tx, ty = surface.GetTextSize(name)
		y = y + ty + 2
	end

	x = math.Round(x - wid * 0.5)

	surface.SetDrawColor(0, 0, 0, 220)
	surface.DrawRect(x, y, wid, hei)
	surface.SetDrawColor(namecolor.r, namecolor.g, namecolor.b, namecolor.a)
	surface.SetTexture(texHealthBar)
	local wid2 = wid * (health / maxhealth)
	surface.DrawTexturedRect(x, y, wid2, hei)
	surface.SetDrawColor(namecolor.r, namecolor.g, namecolor.b, namecolor.a * 0.1)
	surface.DrawRect(x, y, wid2, hei)
	surface.SetDrawColor(30, 30, 30, 255)
	surface.DrawOutlinedRect(x, y, wid, hei)
	surface.SetDrawColor(20, 20, 20, 255)
	surface.DrawOutlinedRect(x + 1, y + 1, wid - 2, hei - 2)
	surface.SetDrawColor(10, 10, 10, 255)
	surface.DrawOutlinedRect(x + 2, y + 2, wid - 4, hei - 4)

	if inbartext then
		draw.SimpleText(inbartext, "teamplay_centerprint", x + wid * 0.5, y + hei * 0.5, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
	end
end

function GM:Initialize()
	self:CreateFonts()

	surface.SetFont("DefaultBold")
	local texw, texh = surface.GetTextSize("Build: 00:00:00      ")
	SCORE_WIDTH = texw + 24
	SCORE_HEIGHT = texh * 7
	SCORE_TEXT_HEIGHT = texh

	timer.Simple(5, function() RunConsoleCommand("requestgametype") end)

	self:ParseParticleManifests()
	self:SetPropTypeNames()
	self:SetUpCastableSpells()
	self:SetupStatusMaterials()
end

function GM:SetupStatusMaterials()
	for k, v in pairs(scripted_ents.GetList()) do
		local st = scripted_ents.GetStored(k)
		if st and st.t and st.t.StatusImage then
			st.t.StatusMaterial = Material(st.t.StatusImage, "smooth")
		end
	end
end

function GM:InitPostEntity()
end

function GM:PlayerShouldTakeDamage(pl, attacker)
	return pl == attacker or not attacker:IsPlayer() or pl:Team() ~= attacker:Team()
end

function GM:CalcVehicleThirdPersonView(veh, seat, pl, origin, angles, fov, znear, zfar)
	local view = {}
	view.angles = angles
	view.fov = fov

	if veh.CalcViewFunc then
		return veh:CalcViewFunc(seat, pl, origin, angles, fov, znear, zfar)
	elseif not veh.CalcViewUp then
		local min, max = veh:WorldSpaceAABB()
		local size = max - min

		veh.CalcViewOffsetUp = math.min(175, size.z * 1.25)
		veh.CalcViewOffsetOut = size:Length()
	end

	--local Up = view.angles:Up() * veh.CalcView.OffsetUp
	local Up = Vector(0, 0, veh.CalcViewOffsetUp)
	local Offset = view.angles:Forward() * -veh.CalcViewOffsetOut

	local TargetOrigin = veh:GetPos() + Up + Offset
	local distance = origin - TargetOrigin

	local filt = {veh}
	filt = table.Add(filt, ents.FindByClass("vehicle*"))
	filt = table.Add(filt, ents.FindByClass("prop_vehicle_*"))
	filt = table.Add(filt, player.GetAll())
	local tr = util.TraceLine({start = origin, endpos = TargetOrigin, filter = filt, mask = MASK_PLAYERSOLID})

	angles.roll = 0
	view.angles = angles
	view.origin = origin + tr.Normal * (distance:Length() - 10) * tr.Fraction

	return view
end

function GM:CalcVehicleFirstPersonView(veh, seat, pl, origin, angles, fov, znear, zfar)
	if veh.CalcViewFirstFunc then
		return veh:CalcViewFirstFunc(seat, pl, origin, angles, fov)
	end
end

local roll = 0
local EyeHullMins = Vector(-8, -8, -8)
local EyeHullMaxs = Vector(8, 8, 8)
local camdist = 0
function GM:CalcView(pl, origin, angles, fov, znear, zfar)
	camdist = math.Approach(camdist, self.ThirdPerson and 1 or 0, FrameTime() * 5)

	local veh = pl:GetVehicle()
	if veh:IsValid() then
		local par = veh:GetVehicleParent()
		if par:IsValid() then
			if camdist > 0 then
				return self:CalcVehicleThirdPersonView(par, veh, pl, origin, angles, fov, znear, zfar)
			else
				return self:CalcVehicleFirstPersonView(par, veh, pl, origin, angles, fov, znear, zfar)
			end
		end
	elseif pl:GetRagdollEntity() and pl:Alive() then
		local rpos, rang = self:GetRagdollEyes(pl)
		if rpos then
			origin = rpos
			angles = rang
		end
	elseif camdist > 0 then
		local tr = util.TraceHull({start = origin, endpos = origin - camdist * 82 * angles:Forward(), mask = MASK_SOLID_BRUSHONLY, mins = EyeHullMins, maxs = EyeHullMaxs})
		origin = tr.Hit and tr.HitPos + (tr.HitPos - origin):GetNormalized() * 4 or tr.HitPos
	end

	if pl:GetObserverMode() == OBS_MODE_NONE then
        if headtilt then
            local vel = pl:GetVelocity()
            roll = math.Approach(roll, vel:GetNormalized():Dot(angles:Right()) * math.min(30, vel:Length() / 100), math.max(0.25, math.sqrt(math.abs(roll))) * 30 * FrameTime())
            angles.roll = angles.roll + roll
        end
	end

	if pl:IsPlayingTaunt() then
		self:CalcViewTaunt(pl, origin, angles, fov, zclose, zfar)
	end

	return self.BaseClass.CalcView(self, pl, origin, angles, fov, znear, zfar)
end

function GM:CalcViewTaunt(pl, origin, angles, fov, zclose, zfar)
	local tr = util.TraceHull({start = origin, endpos = origin - angles:Forward() * 72, mins = Vector(-2, -2, -2), maxs = Vector(2, 2, 2), mask = MASK_OPAQUE, filter = pl})
	origin:Set(tr.HitPos + tr.HitNormal * 2)
end

usermessage.Hook("SLM", function(um)
	MySelf.Mana = um:ReadFloat()
	MySelf.ManaBase = um:ReadFloat()
end)

function GM:PlayerBindPress(pl, bind, wasin)
	if wasin then
		if bind == "+undo" or bind == "+zoom" then
			RunConsoleCommand("dropflag")
			return true
		elseif bind == "+speed" then
			if 0 < MySelf:NumCastableSpells() then
				RunConsoleCommand("cast", string.lower(CURRENT_SPELL))
			end

			return true
		end
	end
end

function GM:ShouldDrawLocalPlayer(pl)
	return camdist > 0 and not pl.KnockedDown or pl:IsPlayingTaunt()
end

function GM:PrePlayerDraw(pl)
	if pl:GetPlayerClassTable().NeedsColorOverride then
		local teamcolor = team.GetColor(pl:Team())
		render.SetColorModulation(teamcolor.r / 255, teamcolor.g / 255, teamcolor.b / 255)
	end
end

function GM:PostPlayerDraw(pl)
	render.SetColorModulation(1, 1, 1)
end

function GM:KeyPress(pl, key)
end

function GM:HUDShouldDraw(name)
	return name ~= "CHudCrosshair" and name ~= "CHudHealth" and name ~= "CHudBattery" and name ~= "CHudAmmo" and name ~= "CHudSecondaryAmmo" and name ~= "CHudDamageIndicator"
end

function GM:DrawGameTypeHUD()
	-- Nothing yet.
end

function MakepTeams()
	local frame = vgui.Create("DFrame")
	frame:SetSize(w * 0.3, h * 0.45)
	frame:Center()
	frame:SetTitle("Choose Team")
	frame:MakePopup()
	pTeams = frame

	local y = 64
	for _, id in pairs(TEAMS_PLAYING) do
		local button = vgui.Create("DButton", frame)
		button:SetPos(16, y)
		button:SetSize(w * 0.3 - 32, 30)
		button:SetText(team.GetName(id))
		button.DoClick = function(btn)
			RunConsoleCommand("chooseside", tostring(id))
			pTeams:Remove()
		end

		y = y + 32
	end

	local button = vgui.Create("DButton", frame)
	button:SetPos(16, y + 32)
	button:SetSize(w * 0.3 - 32, 30)
	button:SetText("SPECTATE")
	button.DoClick = function(btn)
		pTeams:Remove()
	end
end

local lastsoundtime = -1
local HealthMaterial = surface.GetTextureID("vgui/health2")
local ManaMaterial = surface.GetTextureID("vgui/mana2")
local texCrosshair = surface.GetTextureID("noxctf/crosshair1")
GM.CrosshairScale = CreateClientConVar("teamplay_crosshairscale", "1", true, false):GetFloat()
cvars.AddChangeCallback("teamplay_crosshairscale", function(cvar, oldvalue, newvalue)
	GAMEMODE.CrosshairScale = tonumber(newvalue) or 1
end)
function GM:DrawCrosshair(x, y, size, col)
	size = (size or 32) * self.CrosshairScale
	surface.SetTexture(texCrosshair)
	if col then
		surface.SetDrawColor(col)
	else
		surface.SetDrawColor(255, 0, 0, 180)
	end
	surface.DrawTexturedRect(x - size * 0.5, y - size * 0.5, size, size)
end

function GM:_HUDPaint()
	w, h = ScrW(), ScrH()

	local curtime = CurTime()

	if curtime < GAMESTART then
		draw.SimpleText("Waiting for players: "..math.ceil(GAMESTART - curtime), "ScoreboardSub", w * 0.5, h * 0.5, color_white, TEXT_ALIGN_CENTER)
	end

	if not pTeamSelect or not pTeamSelect:Valid() then
		self:DrawGameTypeHUD(curtime)
	end

	self:HUDDrawTargetID()
	self:DrawDeathNotice(0.5, 0.01)
	self:PaintNotes()
	self:DrawCenterPrint()
	self:DeadHUD(curtime)
	self:DrawHUD(curtime)
end

function GM:DeadHUD(curtime)
	if not MySelf:Alive() then
		local timleft = math.max(0, (MySelf.NextSpawnTime or 0) - CurTime())
		if timleft == 0 then
			if MySelf:GetPlayerClass() < 1 then
				draw.SimpleText("Press F2 to select a class. Press F1 for Help.", "teamplay", w * 0.5, h * 0.56, COLOR_RED, TEXT_ALIGN_CENTER)
			else
				draw.SimpleText("Click to respawn!", "teamplay", w * 0.5, h * 0.56, COLOR_RED, TEXT_ALIGN_CENTER)
			end
		else
			draw.SimpleText("Respawning...", "teamplay", w * 0.5, h * 0.56, color_white, TEXT_ALIGN_CENTER)
			draw.SimpleText(string.ToMinutesSecondsMilliseconds(timleft), "teamplay", w * 0.5, h * 0.56 + 48, color_white, TEXT_ALIGN_CENTER)
		end
	end
end

local OldHUDStyle = CreateClientConVar("nox_hud_oldstyle", "0", true, false)
local mana_bar = surface.GetTextureID("noxctf/mana_bar")
local mana_back = surface.GetTextureID("noxctf/mana_bar_back") 
local health_bar = surface.GetTextureID("noxctf/health_bar")
local health_back = surface.GetTextureID("noxctf/health_bar_back") 
local background = surface.GetTextureID("noxctf/bar_background")
local colHealth = table.Copy(COLOR_HEALTH)

--Who the hell used SetScissorRect instead of DrawTexturedRectUV?!
--Also why did Extreme56 made the HUD already aligned in the texture?

function GM:DrawHealth(x, y, health, maxhealth)
	local curX = hud_NBarX:GetFloat() * w
	local curY = hud_NBarY:GetFloat() * h
	local screens = math.min(1, ((w / 3640) + 0.5) ^ 2) --BetterScreenScale()
	local imagesizey = 128 * screens
	local imagesizex = 512 * screens

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetTexture(background)
	surface.DrawTexturedRect(curX, curY - imagesizey, imagesizex, imagesizey)

	surface.SetTexture(health_back)
	surface.DrawTexturedRect(curX, curY - imagesizey, imagesizex, imagesizey)

	if health < maxhealth * 0.25 then
		colHealth.a = 255 - math.abs(math.sin(RealTime() * 4)) * 160
		surface.SetDrawColor(colHealth)
	end
	surface.SetTexture(health_bar)
	surface.DrawTexturedRectUV(curX+(imagesizex*0.185546875), curY - imagesizey, curX+(imagesizex/1.38378378378)*(health/maxhealth), imagesizey, 0.185546875, 0, 0.185546875+ 0.72265625*(health/maxhealth), 1)

	draw.SimpleTextOutlined(health, "NoXHealthBar", 43 * screens + curX, curY - 33 * screens, colHealth, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255))
end

function GM:DrawMana(x, y, mana, maxmana)
	local curX = hud_NBarX:GetFloat() * w
	local curY = hud_NBarY:GetFloat() * h
	local screens = math.min(1, ((w / 3640) + 0.5) ^ 2) --BetterScreenScale()
	local imagesizey = 128 * screens
	local imagesizex = 512 * screens

	surface.SetDrawColor(255, 255, 255, 255)
	surface.SetTexture(mana_back)
	surface.DrawTexturedRect(curX, curY - imagesizey, imagesizex, imagesizey)
		
	surface.SetTexture(mana_bar)
	--Ugly numbers
	surface.DrawTexturedRectUV(curX+(imagesizex/8), curY - imagesizey, curX+(imagesizex/1.45868945869)*(mana/maxmana), imagesizey, 0.125, 0, 0.125+ 0.685546875*(mana/maxmana), 1)

	draw.SimpleTextOutlined(math.floor(mana), "NoXManaBar", 25 * screens + curX, curY - 68 * screens, COLOR_MANA, TEXT_ALIGN_CENTER , TEXT_ALIGN_CENTER, 2, Color(0,0,0,255))
end

function GM:DrawHUD(curtime)
	local classtab = MySelf:GetPlayerClassTable()

	if not MySelf:InVehicle() then
		if eyetraceentity:IsValid() and eyetraceentity.TraceHUDPaint then
			if eyetraceentity.MaxTraceHUDPaintLength then
				if eyetrace.HitPos:Distance(EyePos()) <= eyetraceentity.MaxTraceHUDPaintLength then
					eyetraceentity:TraceHUDPaint(eyetrace)
				end
			else
				eyetraceentity:TraceHUDPaint(eyetrace)
			end
		end
	end

	surface.SetFont("healthandmana")
	local texw, texh = surface.GetTextSize("9999")
	local iconsize = ScreenScale(21.3333333334)
	local boxw = texw + iconsize * 1.1
	local boxh = math.max(texh * 1.1, iconsize * 1.1)
	local siz
	if hud_LargeSpellIcons:GetBool() then
		siz = ScreenScale(16)
	else
		siz = ScreenScale(10.6666667)
	end

	if MySelf:Team() ~= TEAM_SPECTATOR then
		local mana = math.max(0, MySelf:GetMana())
		if OldHUDStyle:GetBool() then
			local entityhealth = math.max(0, MySelf:Health() / classtab.Health)
			local colortouse
			if 0.75 < entityhealth then
				colortouse = COLOR_GREEN
			elseif 0.5 < entityhealth then
				colortouse = COLOR_YELLOW
			elseif 0.3 < entityhealth then
				colortouse = COLOR_ORANGE
			else
				colortouse = COLOR_RED
			end

			--local x = iconsize
			--local y = h - boxh * 1.5
			local x = w * hud_HealthX:GetFloat()
			local y = h * hud_HealthY:GetFloat()
			draw.RoundedBox(8, x, y, boxw, boxh, color_black_alpha180)
			draw.SimpleTextOutlined(math.max(MySelf:Health(), 0), "healthandmana", x + boxw * 0.9, y + boxh * 0.5, colortouse, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255))
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(HealthMaterial)
			surface.DrawTexturedRect(x, y + boxh * 0.5 - iconsize * 0.5, iconsize, iconsize)

			--x = x + boxw * 1.25
			x = w * hud_ManaX:GetFloat()
			y = h * hud_ManaY:GetFloat()
			draw.RoundedBox(8, x, y, boxw, boxh, color_black_alpha180)
			draw.SimpleTextOutlined(math.floor(mana), "healthandmana", x + boxw * 0.9, y + boxh * 0.5, mana_color, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER, 2, Color(0,0,0,255))
			surface.SetDrawColor(255, 255, 255, 255)
			surface.SetTexture(ManaMaterial)
			surface.DrawTexturedRect(x, y + boxh * 0.5 - iconsize * 0.5, iconsize, iconsize)
		else
			self:DrawHealth(0, 0, math.max(0, MySelf:Health()), classtab.Health)
			if ( classtab.Mana > 0 ) then
				self:DrawMana(0,0, math.max(0, MySelf:GetMana()), classtab.Mana )
			end
		end

		if MySelf:NumCastableSpells() then
			if 0 < MySelf:NumCastableSpells() then
				self:DrawSpellSelection(mana)
			end
		end
	end

	local dX = w * hud_StatusBarX:GetFloat()
	local dY = h * hud_StatusBarY:GetFloat()
	for _, ent in pairs(ents.FindByClass("status_*")) do
		if ent:GetOwner() ~= MySelf or not ent.StatusMaterial then continue end

		local endtime = ent:GetDieTime()

		surface.SetDrawColor(255, 255, 255, 255)
		surface.SetMaterial(ent.StatusMaterial)
		surface.DrawTexturedRect(dX, dY, siz, siz)

		if endtime == 0 then
			draw.SimpleText("-", "teamplay", dX + siz * 0.5, dY + siz, color_white, TEXT_ALIGN_CENTER)
		else
			local delta = math.ceil(math.max(0, endtime - CurTime()))
			draw.SimpleText(delta, "teamplay", dX + siz * 0.5, dY + siz, delta < 3 and COLOR_RED or delta < 5 and COLOR_YELLOW or color_white, TEXT_ALIGN_CENTER)
		end

		--dX = dX + 2
		dX = dX + siz * 1.25
	end
	
	for spellid, tab in pairs(DelayIcons) do
		local endtime = tab.EndTime
		local starttime = tab.StartTime

		if curtime < starttime + 1 then
			local timeleft = curtime - starttime
			surface.SetDrawColor(255, 255, 160, 255 - (255 * timeleft))
			local start = 5 * timeleft + 1
			local size = siz + start * 2
			surface.DrawRect(dX - start, dY - start, size, size)
		end

		surface.SetDrawColor(255, 255, 255, 255)
		if endtime == -10 then
			surface.SetMaterial(Spells[spellid].Icon)
			surface.DrawTexturedRect(dX, dY, siz, siz)
			draw.SimpleText("-", "teamplay", dX + siz * 0.5, dY + siz, color_white, TEXT_ALIGN_CENTER)
		else
			local timeleft = endtime - curtime
			if timeleft <= 0 then
				DelayIcons[spellid] = nil
			else
				surface.SetMaterial(Spells[spellid].Icon)
				surface.DrawTexturedRect(dX, dY, siz, siz)
				local delta = math.ceil(math.max(0, endtime - CurTime()))
				draw.SimpleText(math.ceil(timeleft), "teamplay", dX + siz * 0.5, dY + siz, delta < 3 and COLOR_RED or delta < 5 and COLOR_YELLOW or color_white, TEXT_ALIGN_CENTER)
			end
		end
		dX = dX + siz * 1.25
	end
end

concommand.Add("+menu_context", function(pl)
	GAMEMODE.ThirdPerson = not GAMEMODE.ThirdPerson
end)

concommand.Add("castslot", function(sender, command, arguments)
	local id = tonumber(arguments[1] or 0) or 0
	local class = MySelf:GetPlayerClass()
	local sheet = SPELL_SHEETS[class]

	if not sheet then return end

	local spellname

	if id == 1 then
		spellname = sheet[IN_FORWARD + IN_MOVELEFT][2]
	elseif id == 2 then
		spellname = sheet[IN_FORWARD][2]
	elseif id == 3 then
		spellname = sheet[IN_FORWARD + IN_MOVERIGHT][2]
	elseif id == 4 then
		spellname = sheet[IN_FORWARD + IN_MOVELEFT][1]
	elseif id == 5 then
		spellname = sheet[IN_FORWARD][1]
	elseif id == 6 then
		spellname = sheet[IN_FORWARD + IN_MOVERIGHT][1]
	elseif id == 7 then
		spellname = sheet[IN_MOVELEFT][2]
	elseif id == 8 then
		spellname = sheet[IN_MOVELEFT][1]
	elseif id == 9 then
		spellname = sheet[IN_MOVERIGHT][1]
	elseif id == 10 then
		spellname = sheet[IN_MOVERIGHT][2]
	elseif id == 11 then
		spellname = sheet[IN_BACK + IN_MOVELEFT][1]
	elseif id == 12 then
		spellname = sheet[IN_BACK][1]
	elseif id == 13 then
		spellname = sheet[IN_BACK + IN_MOVERIGHT][1]
	elseif id == 14 then
		spellname = sheet[IN_BACK + IN_MOVELEFT][2]
	elseif id == 15 then
		spellname = sheet[IN_BACK][2]
	elseif id == 16 then
		spellname = sheet[IN_BACK + IN_MOVERIGHT][2]
	end

	if spellname and #spellname > 0 and spellname ~= "-" then
		RunConsoleCommand("cast", spellname)
	end
end)

function GM:DrawSpellSelection(mana)
	local class = MySelf:GetPlayerClass()

	local siz
	if hud_LargeSpellIcons:GetBool() then
		siz = ScreenScale(16)
	else
		siz = ScreenScale(10.6666667)
	end

	--local dX = w - siz * 6
	--local dY = h - siz * 6
	local dX = w * hud_SpellMenuX:GetFloat()
	local dY = h * hud_SpellMenuY:GetFloat()
	local x = dX
	local y = dY

	local sheet = SPELL_SHEETS[class]
	if not sheet then return end

	local spellid = NameToSpell[ sheet[IN_FORWARD + IN_MOVELEFT][2] ]
	local _CURRENT_SPELL = NameToSpell[CURRENT_SPELL] or "-"
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz * 2
	spellid = NameToSpell[ sheet[IN_FORWARD][2] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz * 2
	spellid = NameToSpell[ sheet[IN_FORWARD + IN_MOVERIGHT][2] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = x + siz
	dY = dY + siz
	spellid = NameToSpell[ sheet[IN_FORWARD + IN_MOVELEFT][1] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz
	spellid = NameToSpell[ sheet[IN_FORWARD][1] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz
	spellid = NameToSpell[ sheet[IN_FORWARD + IN_MOVERIGHT][1] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dY = dY + siz
	dX = x
	spellid = NameToSpell[ sheet[IN_MOVELEFT][2] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz
	spellid = NameToSpell[ sheet[IN_MOVELEFT][1] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz * 2
	spellid = NameToSpell[ sheet[IN_MOVERIGHT][1] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz
	spellid = NameToSpell[ sheet[IN_MOVERIGHT][2] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dY = dY + siz
	dX = x + siz
	spellid = NameToSpell[ sheet[IN_BACK + IN_MOVELEFT][1] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz
	spellid = NameToSpell[ sheet[IN_BACK][1] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz
	spellid = NameToSpell[ sheet[IN_BACK + IN_MOVERIGHT][1] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = x
	dY = dY + siz
	spellid = NameToSpell[ sheet[IN_BACK + IN_MOVELEFT][2] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz * 2
	spellid = NameToSpell[ sheet[IN_BACK][2] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end
	dX = dX + siz * 2
	spellid = NameToSpell[ sheet[IN_BACK + IN_MOVERIGHT][2] ]
	if spellid then
		if Spells[spellid].Mana and mana < Spells[spellid].Mana then
			surface.SetDrawColor(255, 0, 0, 255)
		elseif self.DisabledSpells[spellid] then
			surface.SetDrawColor(100, 100, 100, 255)
		elseif _CURRENT_SPELL == spellid then
			surface.SetDrawColor(80, 255, 100, 255)
		else
			surface.SetDrawColor(255, 255, 255, 255)
		end
		surface.SetMaterial(Spells[spellid].Icon)
		surface.DrawTexturedRect(dX, dY, siz, siz)
	else
		surface.SetDrawColor(255, 255, 255, 127)
		surface.DrawOutlinedRect(dX, dY, siz, siz)
	end

	local spellid = NameToSpell[CURRENT_SPELL]
	if spellid then
		if Spells[spellid].Mana and MySelf:GetMana() < Spells[spellid].Mana then
			draw.SimpleText(CURRENT_SPELL, "teamplay", x + siz * 2.5, y - siz, COLOR_RED, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
		else
			draw.SimpleText(CURRENT_SPELL, "teamplay", x + siz * 2.5, y - siz, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
		end
	end
	if MySelf:KeyDown(IN_ATTACK2) then
		if MySelf:KeyDown(IN_ATTACK) then
			draw.SimpleText("2", "teamplay", x + siz * 2.5, y + siz * 2.5, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			self:SelectSpellsFromPage2()
		else
			draw.SimpleText("1", "teamplay", x + siz * 2.5, y + siz * 2.5, COLOR_LIMEGREEN, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
			self:SelectSpellsFromPage1()
		end
	end
end

function GM:SelectSpellsFromPage1()
	local class = MySelf:GetPlayerClass()
	if MySelf:KeyDown(IN_MOVELEFT) and MySelf:KeyDown(IN_FORWARD) then
		if SPELL_SHEETS[class][IN_FORWARD + IN_MOVELEFT][1] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_FORWARD + IN_MOVELEFT][1]
		end
	elseif MySelf:KeyDown(IN_MOVERIGHT) and MySelf:KeyDown(IN_FORWARD) then
		if SPELL_SHEETS[class][IN_FORWARD + IN_MOVERIGHT][1] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_FORWARD + IN_MOVERIGHT][1]
		end
	elseif MySelf:KeyDown(IN_MOVERIGHT) and MySelf:KeyDown(IN_BACK) then
		if SPELL_SHEETS[class][IN_BACK + IN_MOVERIGHT][1] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_BACK + IN_MOVERIGHT][1]
		end
	elseif MySelf:KeyDown(IN_MOVELEFT) and MySelf:KeyDown(IN_BACK) then
		if SPELL_SHEETS[class][IN_BACK + IN_MOVELEFT][1] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_BACK + IN_MOVELEFT][1]
		end
	elseif MySelf:KeyDown(IN_MOVELEFT) then
		if SPELL_SHEETS[class][IN_MOVELEFT][1] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_MOVELEFT][1]
		end
	elseif MySelf:KeyDown(IN_MOVERIGHT) then
		if SPELL_SHEETS[class][IN_MOVERIGHT][1] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_MOVERIGHT][1]
		end
	elseif MySelf:KeyDown(IN_FORWARD) then
		if SPELL_SHEETS[class][IN_FORWARD][1] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_FORWARD][1]
		end
	elseif MySelf:KeyDown(IN_BACK) then
		if SPELL_SHEETS[class][IN_BACK][1] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_BACK][1]
		end
	end
end

function GM:SelectSpellsFromPage2()
	local class = MySelf:GetPlayerClass()
	if MySelf:KeyDown(IN_MOVELEFT) and MySelf:KeyDown(IN_FORWARD) then
		if SPELL_SHEETS[class][IN_FORWARD + IN_MOVELEFT][2] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_FORWARD + IN_MOVELEFT][2]
		end
	elseif MySelf:KeyDown(IN_MOVERIGHT) and MySelf:KeyDown(IN_FORWARD) then
		if SPELL_SHEETS[class][IN_FORWARD + IN_MOVERIGHT][2] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_FORWARD + IN_MOVERIGHT][2]
		end
	elseif MySelf:KeyDown(IN_MOVERIGHT) and MySelf:KeyDown(IN_BACK) then
		if SPELL_SHEETS[class][IN_BACK + IN_MOVERIGHT][2] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_BACK + IN_MOVERIGHT][2]
		end
	elseif MySelf:KeyDown(IN_MOVELEFT) and MySelf:KeyDown(IN_BACK) then
		if SPELL_SHEETS[class][IN_BACK + IN_MOVELEFT][2] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_BACK + IN_MOVELEFT][2]
		end
	elseif MySelf:KeyDown(IN_MOVELEFT) then
		if SPELL_SHEETS[class][IN_MOVELEFT][2] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_MOVELEFT][2]
		end
	elseif MySelf:KeyDown(IN_MOVERIGHT) then
		if SPELL_SHEETS[class][IN_MOVERIGHT][2] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_MOVERIGHT][2]
		end
	elseif MySelf:KeyDown(IN_FORWARD) then
		if SPELL_SHEETS[class][IN_FORWARD][2] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_FORWARD][2]
		end
	elseif MySelf:KeyDown(IN_BACK) then
		if SPELL_SHEETS[class][IN_BACK][2] ~= "-" then
			CURRENT_SPELL = SPELL_SHEETS[class][IN_BACK][2]
		end
	end
end

function GM:HUDPaintBackground()
end

function GM:_HUDPaintBackground()
	local veh = MySelf:GetVehicle()
	if veh != NULL then
		local realveh = veh:GetDTEntity(0)
		if realveh.DrawHUD then
			realveh:DrawHUD(veh)
		end
	end

	if not MySelf:InVehicle() then
		self:DrawCrosshair(ScrW() * 0.5, ScrH() * 0.5)
	end
end

function GM:_CreateMove(cmd)
	if MySelf:IsPlayingTaunt() and MySelf:Alive() then
		self:CreateMoveTaunt(cmd)
	end
end

function GM:CreateMoveTaunt(cmd)
	cmd:ClearButtons(0)
	cmd:ClearMovement()
end

GM.HurtEffect = 0
function GM:_RenderScreenspaceEffects()
	if MySelf:GetStatus("infravision") then
		DrawMaterialOverlay("models/props_c17/fisheyelens", 0.01 + math.abs(math.sin(CurTime() * 0.4)) * 0.02)
	end

	if render.GetDXLevel() < 80 then return end

	if self.HurtEffect > 0 then
		DrawSharpen(1, math.min(6, self.HurtEffect * 3))
	end
end

function GM:PostProcessPermitted(str)
	return false
end

function insma()
	local c = mana_color
	if c.a == 254 then return end
	local off = Color(255, 0, 0, 254)
	local on = Color(75, 150, 255, 254)
	timer.Simple(0.1, function() setmanacolor(off) end)
	timer.Simple(0.15, function() setmanacolor(on) end)
	timer.Simple(0.2, function() setmanacolor(off) end)
	timer.Simple(0.25, function() setmanacolor(on) end)
	timer.Simple(0.3, function() setmanacolor(off) end)
	timer.Simple(0.35, function() setmanacolor(on) end)
	timer.Simple(0.4, function() setmanacolor(off) end)
	timer.Simple(0.45, function() setmanacolor(on) end)
	timer.Simple(0.5, function() setmanacolor(Color(75, 150, 255, 255)) end)
	surface.PlaySound("nox/nomana.ogg")
end

function mastu()
	local c = mana_color
	if c.a == 254 then return end
	local off = Color(255, 0, 0, 254)
	local on = Color(75, 150, 255, 254)
	timer.Simple(0.1, function() setmanacolor(off) end)
	timer.Simple(0.15, function() setmanacolor(on) end)
	timer.Simple(0.2, function() setmanacolor(off) end)
	timer.Simple(0.25, function() setmanacolor(on) end)
	timer.Simple(0.3, function() setmanacolor(off) end)
	timer.Simple(0.35, function() setmanacolor(on) end)
	timer.Simple(0.4, function() setmanacolor(off) end)
	timer.Simple(0.45, function() setmanacolor(on) end)
	timer.Simple(0.5, function() setmanacolor(Color(75, 150, 255, 255)) end)
	surface.PlaySound("nox/manastuncast.ogg")

	LM(27)
end

function InitTeams(teamtab)
	TEAMS_PLAYING = teamtab

	local dontdestroy = {}
	for i=1, #TEAMS_PLAYING do
		dontdestroy[ TEAMS_PLAYING[i] ] = true
	end
	for i in pairs(team.TeamInfo) do
		if not dontdestroy[i] and i < 9 and 0 < i then
			team.TeamInfo[i] = nil
		end
	end
end

CURRENT_SPELL = "none"
usermessage.Hook("sp", function(um)
	gamemode.Call("LocalPlayerSpawn", um:ReadShort())
end)

function GM:LocalPlayerSpawn(classid)
	DelayIcons = {}
	self:LoadSpellSheet(classid)
	local viewmod = MySelf:GetViewModel()
	if viewmod:IsValid() then
		viewmod:SetColor(Color(255, 255, 255, 255))
	end
end

function setmanacolor(col)
	mana_color = col
end

function GM:LoadSpellSheet(classid)
	classid = classid or MySelf:GetPlayerClass()
	local classtab = CLASSES[classid]
	if not classtab or classtab.Group == "Hidden" then return end

	local tab = {}
	local filename = "noxspellshortcuts_"..string.lower(classtab.Name)..".txt"
	
	file.CreateDir(DIRECTORY)
	
	if file.Exists(DIRECTORY .."/".. filename, "DATA") then
		local contents = file.Read(DIRECTORY .."/".. filename, "DATA")
		if classtab.DefaultSpellSheet and #string.gsub(string.gsub(contents, ":", ""), "-", "") <= 0 then
			tab = string.Explode(":", classtab.DefaultSpellSheet)
		else
			tab = string.Explode(":", contents)
		end
	elseif classtab.DefaultSpellSheet then
		tab = string.Explode(":", classtab.DefaultSpellSheet)
	end

	for k, v in ipairs(tab) do
		if not v or #v == 0 then
			tab[k] = "-"
		end
	end

	SPELL_SHEETS[classid] = {}
	SPELL_SHEETS[classid][IN_FORWARD]={}
	SPELL_SHEETS[classid][IN_FORWARD][1] = tab[1]
	SPELL_SHEETS[classid][IN_FORWARD][2] = tab[2]
	SPELL_SHEETS[classid][IN_BACK]={}
	SPELL_SHEETS[classid][IN_BACK][1] = tab[3]
	SPELL_SHEETS[classid][IN_BACK][2] = tab[4]
	SPELL_SHEETS[classid][IN_MOVELEFT]={}
	SPELL_SHEETS[classid][IN_MOVELEFT][1] = tab[5]
	SPELL_SHEETS[classid][IN_MOVELEFT][2] = tab[6]
	SPELL_SHEETS[classid][IN_MOVERIGHT]={}
	SPELL_SHEETS[classid][IN_MOVERIGHT][1] = tab[7]
	SPELL_SHEETS[classid][IN_MOVERIGHT][2] = tab[8]
	SPELL_SHEETS[classid][IN_FORWARD + IN_MOVELEFT]={}
	SPELL_SHEETS[classid][IN_FORWARD + IN_MOVELEFT][1] = tab[9]
	SPELL_SHEETS[classid][IN_FORWARD + IN_MOVELEFT][2] = tab[10]
	SPELL_SHEETS[classid][IN_FORWARD + IN_MOVERIGHT]={}
	SPELL_SHEETS[classid][IN_FORWARD + IN_MOVERIGHT][1] = tab[11]
	SPELL_SHEETS[classid][IN_FORWARD + IN_MOVERIGHT][2] = tab[12]
	SPELL_SHEETS[classid][IN_BACK + IN_MOVELEFT]={}
	SPELL_SHEETS[classid][IN_BACK + IN_MOVELEFT][1] = tab[13]
	SPELL_SHEETS[classid][IN_BACK + IN_MOVELEFT][2] = tab[14]
	SPELL_SHEETS[classid][IN_BACK + IN_MOVERIGHT]={}
	SPELL_SHEETS[classid][IN_BACK + IN_MOVERIGHT][1] = tab[15]
	SPELL_SHEETS[classid][IN_BACK + IN_MOVERIGHT][2] = tab[16]
	if not file.Exists(DIRECTORY .."/noxspellshortcuts_"..string.lower(CLASSES[classid].Name)..".txt", "DATA") then
		file.Write(DIRECTORY .."/noxspellshortcuts_"..string.lower(CLASSES[classid].Name)..".txt", table.concat(tab, ":"))
	end
end

function GM:SaveSpellSheet(class)
	if not SPELL_SHEETS[class] then return end

	local tab = {}
	tab[1] = SPELL_SHEETS[class][IN_FORWARD][1] or "-"
	tab[2] = SPELL_SHEETS[class][IN_FORWARD][2] or "-"
	tab[3] = SPELL_SHEETS[class][IN_BACK][1] or "-"
	tab[4] = SPELL_SHEETS[class][IN_BACK][2] or "-"
	tab[5] = SPELL_SHEETS[class][IN_MOVELEFT][1] or "-"
	tab[6] = SPELL_SHEETS[class][IN_MOVELEFT][2] or "-"
	tab[7] = SPELL_SHEETS[class][IN_MOVERIGHT][1] or "-"
	tab[8] = SPELL_SHEETS[class][IN_MOVERIGHT][2] or "-"
	tab[9] = SPELL_SHEETS[class][IN_FORWARD + IN_MOVELEFT][1] or "-"
	tab[10] = SPELL_SHEETS[class][IN_FORWARD + IN_MOVELEFT][2] or "-"
	tab[11] = SPELL_SHEETS[class][IN_FORWARD + IN_MOVERIGHT][1] or "-"
	tab[12] = SPELL_SHEETS[class][IN_FORWARD + IN_MOVERIGHT][2] or "-"
	tab[13] = SPELL_SHEETS[class][IN_BACK + IN_MOVELEFT][1] or "-"
	tab[14] = SPELL_SHEETS[class][IN_BACK + IN_MOVELEFT][2] or "-"
	tab[15] = SPELL_SHEETS[class][IN_BACK + IN_MOVERIGHT][1] or "-"
	tab[16] = SPELL_SHEETS[class][IN_BACK + IN_MOVERIGHT][2] or "-"

	file.Write(DIRECTORY .."/noxspellshortcuts_"..string.lower(CLASSES[class].Name)..".txt", table.concat(tab, ":"))
end

usermessage.Hook("FCap", function(um)
	local playername = um:ReadString()
	local selfteam = um:ReadShort()
	local otherteam = um:ReadShort()

	GAMEMODE:CenterPrintAll(playername.." of "..team.GetName(selfteam).." captured the "..team.GetName(otherteam).." flag!~snox/flagcaptured.wav", COLOR_RED, 6)
end)

usermessage.Hook("FTak", function(um)
	local selfteam = um:ReadShort()
	local playername = um:ReadString()
	if selfteam == MySelf:Team() then
		GAMEMODE:CenterPrintAll(playername.." took your flag!!", COLOR_RED)
	else
		GAMEMODE:CenterPrintAll(playername.." took the "..team.GetName(selfteam).." flag!!")
	end

	surface.PlaySound("nox/nflagpickup.ogg")
end)

usermessage.Hook("FDro", function(um)
	local selfteam = um:ReadShort()
	local playername = um:ReadString()
	if selfteam == MySelf:Team() then
		GAMEMODE:CenterPrint(playername.." dropped your flag!", COLOR_RED)
	else
		GAMEMODE:CenterPrint(playername.." dropped the "..team.GetName(selfteam).." flag!")
	end

	surface.PlaySound("nox/nflagdrop.ogg")
end)

usermessage.Hook("FRet", function(um)
	local playername = um:ReadString()
	local selfteam = um:ReadShort()
	local faraway = um:ReadBool()
	if faraway then
		GAMEMODE:CenterPrint(playername.." returned the "..team.GetName(selfteam).." flag.")
	else
		GAMEMODE:CenterPrint(playername.." gently placed the "..team.GetName(selfteam).." flag back on its stand.")
	end

	surface.PlaySound("nox/nflagreturn.ogg")
end)

usermessage.Hook("EndG", function(um)
	local winner = um:ReadShort()
	END_GAME = true
	NEXT_MAP = CurTime() + 35
	if 0 < winner then
		GAMEMODE:CenterPrintAll(team.GetName(winner).." has won the match!", COLOR_YELLOW, 60)
	else
		GAMEMODE:CenterPrintAll("The game has ended in a tie!", COLOR_YELLOW, 60)
	end

	surface.PlaySound(winner == MySelf:Team() and "nox/flagcaptured.wav" or "nox/roundlose.ogg")

	function GAMEMODE:HUDPaint() end
	function GAMEMODE:HUDPaintBackground() end
end)

usermessage.Hook("FlagReturnEffect", function(um)
	local effectdata = EffectData()
		effectdata:SetOrigin(um:ReadVector())
		effectdata:SetStart(um:ReadVector())
		effectdata:SetScale(um:ReadShort())
	util.Effect("flagreturn", effectdata)
end)

usermessage.Hook("RecFlagInfo", function(um)
	local index = um:ReadShort()
	team.TeamInfo[index].FlagPoint = um:ReadVector()
	local flag = um:ReadEntity()
	team.TeamInfo[index].Flag = flag
	flag:SetTeamID(index)
end)

function DI(um)
	local spellid = um:ReadShort()
	local tTime = um:ReadFloat()
	if tTime == 0 then
		DelayIcons[spellid] = nil
	elseif 0 < tTime then
		local curtime = CurTime()
		DelayIcons[spellid] = {StartTime = curtime, EndTime = curtime + tTime}
	else
		DelayIcons[spellid] = {StartTime = CurTime(), EndTime = -10}
	end
end
usermessage.Hook("DI", DI)

function gib()
	local effectdata = EffectData()
		effectdata:SetEntity(MySelf)
		effectdata:SetNormal(MySelf:GetVelocity():GetNormal())
	util.Effect("gib_player", effectdata)
end

usermessage.Hook("NextRespawn", function(um)
	MySelf.NextSpawnTime = um:ReadFloat()
end)

usermessage.Hook("RecInfo", function(um)
	local ent = um:ReadEntity()
	if ent:IsValid() and ent.Info then
		ent:Info(um)
	end
end)

local function play(ent, snd)
	if ent:IsValid() and ent:Alive() then
		ent:EmitSound(snd, 70, 100)
	end
end

usermessage.Hook("SI", function(um)
	local ent = um:ReadEntity()
	local tab = Spells[um:ReadShort()]
	if tab and ent:IsValid() then
		for i, word in ipairs(tab.Words) do
			timer.Simple(i * 0.1 - 0.1, function() play(ent, word) end)
		end
	end
end)

-- Temporary fix
function render.DrawQuadEasy(pos, dir, xsize, ysize, color, rotation)
	xsize = xsize / 2
	ysize = ysize / 2

	local ang = dir:Angle()

	if rotation then
		ang:RotateAroundAxis(ang:Forward(), rotation)
	end

	local upoffset = ang:Up() * ysize
	local rightoffset = ang:Right() * xsize

	render.DrawQuad(pos - upoffset - rightoffset, pos - upoffset + rightoffset, pos + upoffset + rightoffset, pos + upoffset - rightoffset, color)
end
