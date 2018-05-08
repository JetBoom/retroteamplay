for _, class in pairs(file.Find(GM.FolderName.."/gamemode/classes/*.lua", "LUA")) do
	AddCSLuaFile("classes/" ..class)
end

--[[for _, spell in pairs(file.Find(GM.FolderName.."/gamemode/spells/*.lua", "LUA")) do
	AddCSLuaFile("spells/" ..spell)
end]]

AddCSLuaFile("shared.lua")
AddCSLuaFile("sh_globals.lua")
AddCSLuaFile("sh_props.lua")
AddCSLuaFile("sh_register.lua")
AddCSLuaFile("sh_animations.lua")
AddCSLuaFile("sh_voicesets.lua")
AddCSLuaFile("sh_colors.lua")
AddCSLuaFile("sh_luaanimations.lua")

AddCSLuaFile("cl_init.lua")
AddCSLuaFile("cl_deathnotice.lua")
AddCSLuaFile("cl_noxious_localization.lua")
AddCSLuaFile("cl_scoreboard.lua")
AddCSLuaFile("cl_targetid.lua")
AddCSLuaFile("cl_notice.lua")
AddCSLuaFile("cl_dermaskin.lua")
AddCSLuaFile("cl_votemap.lua")

AddCSLuaFile("sv_obj_player_extend.lua")
AddCSLuaFile("sv_globals.lua")

AddCSLuaFile("obj_entity_extend.lua")
AddCSLuaFile("obj_player_extend.lua")

AddCSLuaFile("vgui/dexroundedpanel.lua")
AddCSLuaFile("vgui/dexroundedframe.lua")
AddCSLuaFile("vgui/dexchanginglabel.lua")
AddCSLuaFile("vgui/dexpingbars.lua")

AddCSLuaFile("vgui/pbuilder.lua")
AddCSLuaFile("vgui/pspells.lua")
AddCSLuaFile("vgui/phelp.lua")
AddCSLuaFile("vgui/pclasses.lua")
AddCSLuaFile("vgui/scoreboard.lua")
AddCSLuaFile("vgui/vehiclepad.lua")
AddCSLuaFile("vgui/poptions.lua")
AddCSLuaFile("vgui/pteamselect.lua")

AddCSLuaFile("nox_votemap.lua")
AddCSLuaFile("nox_teams.lua")
AddCSLuaFile("nox_shared_spelldefines.lua")

AddCSLuaFile("vehicles_shared.lua")

AddCSLuaFile("modules/sh_statushook.lua")

AddCSLuaFile("gametypes/cl_assault.lua")
AddCSLuaFile("gametypes/cl_blitz.lua")
AddCSLuaFile("gametypes/cl_harvest.lua")
AddCSLuaFile("gametypes/cl_ctf.lua")
AddCSLuaFile("gametypes/cl_holdtheflag.lua")
AddCSLuaFile("gametypes/cl_kingofthehill.lua")

include("gametypes/assault.lua")
include("gametypes/blitz.lua")
include("gametypes/harvest.lua")
include("gametypes/ctf.lua")
include("gametypes/holdtheflag.lua")
include("gametypes/kingofthehill.lua")

-- TODO: Check vehicle pad vgui to make sure that vehicle icons aren't bigger than the text on small resolutions.
-- TODO: Hit effects for melee and arrows.
-- TODO: Draw a quad to signify team barriers in build mode.
-- CODE (BOTS): for _, v in pairs(player.GetAll()) do if v:IsBot() then v:SetPlayerClass(2) v:Spawn() end end

local LifeStatus = {}
local LifeStatusTimers = {}

function GM:AddLifeStatus(name)
	if name then
		table.insert(LifeStatus, name)
	end
end

function GM:AddLifeStatusTimer(name)
	if name then
		table.insert(LifeStatusTimers, name)
	end
end

function GM:HandleOvertime()
end

include("modules/animationsapi/boneanimlib.lua")

include("shared.lua")

include("sv_globals.lua")
include("sv_obj_player_extend.lua")

include("nox_votemap.lua")
include("nox_spelldefines.lua")
include("nox_shared_spelldefines.lua")

include("vehicles_shared.lua")
include("modules/sv_mapeditor.lua")

if file.Exists(GM.FolderName.."/gamemode/maps/"..game.GetMap()..".lua", "LUA") then
	include("maps/"..game.GetMap()..".lua")
end

CTFKillAwards = {}
CTFKillAwards[100] = "100_CTF_Kills"
CTFKillAwards[250] = "250_CTF_Kills"
CTFKillAwards[500] = "500_CTF_Kills"
CTFKillAwards[1000] = "1000_CTF_Kills"
CTFKillAwards[2500] = "2500_CTF_Kills"
CTFKillAwards[5000] = "5000_CTF_Kills"
CTFKillAwards[7500] = "7500_CTF_Kills"
CTFKillAwards[10000] = "10000_CTF_Kills"
CTFKillAwards[12500] = "12500_CTF_Kills"
CTFKillAwards[15000] = "15000_CTF_Kills"
CTFKillAwards[17500] = "17500_CTF_Kills"
CTFKillAwards[20000] = "20000_CTF_Kills"

function BroadcastLua(lua)
	for _, pl in pairs(player.GetAll()) do
		pl:SendLua(lua)
	end
end

GM.TeamLocks = {}

function GM:IsOnRightSide(ent, teamid)
	if teamid then
		local teaminfo=team.TeamInfo[teamid]
		if teaminfo then
			local flagpoint=teaminfo.FlagPoint
			if flagpoint then
				local desireddistance = ent:NearestPoint(flagpoint):Distance(flagpoint)
				for _, teamid2 in pairs(TEAMS_PLAYING) do
					if ent:NearestPoint(flagpoint):Distance(team.TeamInfo[teamid2].FlagPoint) < desireddistance then
						return false
					end
				end
			end
		end
	end

	return true
end

function GM:MovedToRightSide(pl, teamid)
end

function GM:OnDamagedByExplosion(pl)
end

function GM:Initialize()
	game.ConsoleCommand("sv_gravity 600\n")
	game.ConsoleCommand("sv_kickerrornum 0\n")

	self:AddResources()
	self:ParseParticleManifests()
	self:SetPropTypeNames()
	self:SetUpCastableSpells()
end

function GM:AddResources()
	resource.AddFile("resource/fonts/cambria.ttf")

	resource.AddFile("materials/awesomestrike/simplecircle.vmt")

	resource.AddFile("materials/refract_ring.vtf")
	resource.AddFile("materials/refract_ring.vmt")
	resource.AddFile("materials/vgui/health2.vtf")
	resource.AddFile("materials/vgui/health2.vmt")
	resource.AddFile("materials/vgui/mana2.vtf")
	resource.AddFile("materials/vgui/mana2.vmt")

	resource.AddFile("materials/noxctf/health_bar.vmt")
	resource.AddFile("materials/noxctf/health_bar.vtf")
	resource.AddFile("materials/noxctf/health_bar_back.vmt")
	resource.AddFile("materials/noxctf/health_bar_back.vtf")
	resource.AddFile("materials/noxctf/mana_bar.vmt")
	resource.AddFile("materials/noxctf/mana_bar.vtf")
	resource.AddFile("materials/noxctf/mana_bar_back.vmt")
	resource.AddFile("materials/noxctf/mana_bar_back.vtf")
	resource.AddFile("materials/noxctf/bar_background.vmt")
	resource.AddFile("materials/noxctf/bar_background.vtf")

	resource.AddFile("materials/noxctf/classselect_bar.vmt")
	resource.AddFile("materials/noxctf/classselect_bar.vtf")
	resource.AddFile("materials/noxctf/classselect_bar_back.vmt")
	resource.AddFile("materials/noxctf/classselect_bar_back.vtf")
	resource.AddFile("materials/noxctf/classselect_detail.vmt")
	resource.AddFile("materials/noxctf/classselect_detail.vtf")
	resource.AddFile("materials/noxctf/classselect_type.vmt")
	resource.AddFile("materials/noxctf/classselect_type.vtf")

	resource.AddFile("materials/noxctf/crosshair1.vmt")

	resource.AddFile("models/weapons/v_pza.mdl")
	resource.AddFile("models/weapons/w_spanner.mdl")
	resource.AddFile("models/weapons/v_spanner/v_spanner.mdl")
	resource.AddFile("sound/weapons/melee/wrench/wrench_hit-01.wav")
	resource.AddFile("sound/weapons/melee/wrench/wrench_hit-02.wav")
	resource.AddFile("sound/weapons/melee/wrench/wrench_hit-03.wav")
	resource.AddFile("sound/weapons/melee/wrench/wrench_hit-04.wav")
	resource.AddFile("materials/models/weapons/wrench.vmt")
	resource.AddFile("materials/models/weapons/wrench.vtf")
	resource.AddFile("materials/models/weapons/wrench_nm.vtf")
	resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vmt")
	resource.AddFile("materials/models/weapons/temptexture/handsmesh1.vtf")

	resource.AddFile("materials/noxctf/sprite_nova.vtf")
	resource.AddFile("materials/noxctf/sprite_nova.vmt")
	resource.AddFile("materials/noxctf/sprite_smoke.vtf")
	resource.AddFile("materials/noxctf/sprite_smoke.vmt")

	resource.AddFile("materials/noxctf/sprite_bloodspray1.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray2.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray3.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray4.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray5.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray6.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray7.vmt")
	resource.AddFile("materials/noxctf/sprite_bloodspray8.vmt")

	for _, filename in pairs(file.Find("materials/noxctf/classicons/*.vmt", "GAME")) do
		resource.AddFile("materials/noxctf/classicons/"..filename)
	end
	for _, filename in pairs(file.Find("materials/noxctf/classicons/*.vtf", "GAME")) do
		resource.AddFile("materials/noxctf/classicons/"..filename)
	end
	for _, filename in pairs(file.Find("materials/spellicons/*.png", "GAME")) do
		resource.AddFile("materials/spellicons/"..filename)
	end
	for _, filename in pairs(file.Find("sound/nox/*.ogg", "GAME")) do
		resource.AddFile("sound/nox/"..filename)
	end
	for _, filename in pairs(file.Find("materials/mixerman3d/weapons/*.*", "GAME")) do
		resource.AddFile("materials/mixerman3d/weapons/"..filename)
	end
	for _, filename in pairs(file.Find("models/mixerman3d/weapons/*.*", "GAME")) do
		resource.AddFile("models/mixerman3d/weapons/"..filename)
	end
	for _, filename in pairs(file.Find("models/peanut/*.*", "GAME")) do
		resource.AddFile("models/peanut/"..filename)
	end
	for _, filename in pairs(file.Find("materials/peanut/*.*", "GAME")) do
		resource.AddFile("materials/peanut/"..filename)
	end
	for _, filename in pairs(file.Find("models/katharsmodels/flags/*.*", "GAME")) do
		resource.AddFile("models/katharsmodels/flags/"..filename)
	end
	for _, filename in pairs(file.Find("materials/katharsmodels/flags/*.*", "GAME")) do
		resource.AddFile("materials/katharsmodels/flags/"..filename)
	end
	for _, filename in pairs(file.Find("materials/models/npc_player/*.*", "GAME")) do
		resource.AddFile("materials/models/npc_player/"..filename)
	end

	resource.AddFile("materials/noxctf/flagicon_home.vmt")
	resource.AddFile("materials/noxctf/flagicon_home.vtf")
	resource.AddFile("materials/noxctf/flagicon_field.vmt")
	resource.AddFile("materials/noxctf/flagicon_field.vtf")
	resource.AddFile("materials/noxctf/flagicon_dropped.vmt")
	resource.AddFile("materials/noxctf/flagicon_dropped.vtf")

	resource.AddFile("materials/killicon/axe.vmt")
	resource.AddFile("materials/killicon/axe.vtf")
	resource.AddFile("models/nox_longbow_v2.mdl")
	resource.AddFile("models/w_nox_longbow.mdl")
	resource.AddFile("models/nox_sword_short_v001.mdl")
	resource.AddFile("models/w_nox_short_sword.mdl")

	resource.AddFile("models/morrowind/daedric/staff/v_daedric_staff.mdl")
	resource.AddFile("models/morrowind/daedric/staff/w_daedric_staff.mdl")
	resource.AddFile("models/morrowind/magnus/staff/v_magnus_staff.mdl")
	resource.AddFile("models/morrowind/magnus/staff/w_magnus_staff.mdl")

	resource.AddFile("materials/morrowind/daedric/staff/daedric1.vmt")
	resource.AddFile("materials/morrowind/daedric/staff/daedric2.vmt")
	resource.AddFile("materials/morrowind/daedric/staff/daedric3.vmt")
	resource.AddFile("materials/morrowind/daedric/staff/daedric4.vmt")
	resource.AddFile("materials/morrowind/daedric/staff/daedric5.vmt")

	resource.AddFile("materials/morrowind/magnus/staff/magnus1.vmt")
	resource.AddFile("materials/morrowind/magnus/staff/magnus2.vmt")
	resource.AddFile("materials/morrowind/magnus/staff/magnus3.vmt")
	resource.AddFile("materials/morrowind/magnus/staff/magnus4.vmt")
	resource.AddFile("materials/morrowind/magnus/staff/magnus5.vmt")

	resource.AddFile("materials/models/wp_sword_short/wp_sword_short.vmt")
	resource.AddFile("materials/models/wp_sword_short/wp_sword_short.vtf")
	resource.AddFile("materials/models/wp_sword_short/wp_sword_short_normal.vtf")
	resource.AddFile("materials/models/arrows/arrow.vmt")
	resource.AddFile("materials/models/arrows/arrow.vtf")
	resource.AddFile("materials/models/orcbow/ornesbow.vmt")
	resource.AddFile("materials/models/orcbow/ornesbow.vtf")
	resource.AddFile("materials/models/orcbow/ornesbow_normal.vtf")

	-- Paladin's Warhammer
	resource.AddFile("sound/weapons/hammer/morrowind_hammer_deploy1.wav")
	resource.AddFile("sound/weapons/hammer/morrowind_hammer_hit.wav")
	resource.AddFile("sound/weapons/hammer/morrowind_hammer_hitwall1.wav")
	resource.AddFile("sound/weapons/hammer/morrowind_hammer_slash.wav")
	resource.AddFile("sound/weapons/halberd/morrowind_halberd_deploy1.wav")
	resource.AddFile("sound/weapons/halberd/morrowind_halberd_hit.wav")
	resource.AddFile("sound/weapons/halberd/morrowind_halberd_hitwall1.wav")
	resource.AddFile("sound/weapons/halberd/morrowind_halberd_slash.wav")

	resource.AddFile("models/morrowind/orcish/hammer/v_orcish_hammer.mdl")
	resource.AddFile("models/morrowind/orcish/hammer/w_orcish_hammer.mdl")

	resource.AddFile("materials/morrowind/orcish/hammer/orcish1.vmt")
	resource.AddFile("materials/morrowind/orcish/hammer/orcish1.vtf")
	resource.AddFile("materials/morrowind/orcish/hammer/orcish2.vmt")
	resource.AddFile("materials/morrowind/orcish/hammer/orcish2.vtf")
	resource.AddFile("materials/morrowind/orcish/hammer/orcish3.vmt")
	resource.AddFile("materials/morrowind/orcish/hammer/orcish3.vtf")
	resource.AddFile("materials/morrowind/orcish/hammer/orcish4.vmt")
	resource.AddFile("materials/morrowind/orcish/hammer/orcish4.vtf")
	resource.AddFile("materials/morrowind/orcish/hammer/orcish5.vmt")
	resource.AddFile("materials/morrowind/orcish/hammer/orcish5.vtf")
	resource.AddFile("materials/vgui/entities/weapon_mor_orcish_hammer.vmt")
	resource.AddFile("materials/vgui/entities/weapon_mor_orcish_hammer.vtf")

	--[[
	-- Alchemist's Scepter
	resource.AddFile("models/morrowind/dwemer/mace/v_dwemer_mace.mdl")
	resource.AddFile("models/morrowind/dwemer/mace/w_dwemer_mace.mdl")

	resource.AddFile("materials/morrowind/dwemer/mace/dwemer1.vmt")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer1.vtf")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer2.vmt")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer2.vtf")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer3.vmt")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer3.vtf")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer4.vmt")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer4.vtf")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer5.vmt")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer5.vtf")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer6.vmt")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer6.vtf")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer7.vmt")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer7.vtf")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer8.vmt")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer8.vtf")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer9.vmt")
	resource.AddFile("materials/morrowind/dwemer/mace/dwemer9.vtf")

	resource.AddFile("materials/vgui/entities/weapon_mor_dwemer_mace.vmt")
	resource.AddFile("materials/vgui/entities/weapon_mor_dwemer_mace.vtf")
	--]]
	resource.AddFile("particles/nox.pcf")
	resource.AddFile("particles/noxa.pcf")
	resource.AddFile("particles/zolt.pcf")

	resource.AddFile("models/props_noxious/fist/fist_of_vengeance.mdl")
	resource.AddFile("materials/models/props_noxious/fist/color.vtf")
	resource.AddFile("materials/models/props_noxious/fist/color.vmt")

end

function GM:CreateDummyEntities()
	local mapname = game.GetMap()

	local vVec0 = Vector(0, 0, 0)
	local files, directories = file.Find(self.FolderName.."/entities/entities/dummy_*", "LUA")
	for _, name in pairs(directories) do
		local ent = ents.Create(name)
		if ent:IsValid() then
			ent:SetPos(vVec0)
			ent:Spawn()
			_G[string.upper(name)] = ent
		end
	end
end

function GM:PlayerSwitchFlashlight(pl, switchon)
	return false
end

function GM:InitPostEntity()
	self:CreateDummyEntities()

	physenv.SetPerformanceSettings({MaxVelocity = 32000})

	local mapname = game.GetMap()

	for _, ent in pairs(ents.FindByClass("item_*")) do
		ent:Remove()
	end

	for _, ent in pairs(ents.FindByClass("weapon_*")) do
		ent:Remove()
	end

	self.MapEditorEntities = {}
	if file.Exists("noxctfmaps/"..mapname..".txt", "DATA") then
		local red = file.Read("noxctfmaps/"..mapname..".txt", "DATA")
		if string.sub(red, 1, 3) == "SRL" then
			for _, enttab in pairs(Deserialize(red)) do
				local ent = ents.Create(string.lower(enttab.Class))
				if ent:IsValid() then
					ent:SetPos(enttab.Position)
					ent:SetAngles(enttab.Angles)
					if enttab.KeyValues then
						ent.KeyValues = ent.KeyValues or {}
						for key, value in pairs(enttab.KeyValues) do
							ent.KeyValues[key] = value
						end
					end
					ent:Spawn()
					table.insert(self.MapEditorEntities, ent)
				end
			end
		else
			for _, stuff in pairs(string.Explode(",", red)) do
				local expstuff = string.Explode(" ", stuff)
				local ent = ents.Create(string.lower(expstuff[1]))
				if ent:IsValid() then
					ent:SetPos(Vector(tonumber(expstuff[2]), tonumber(expstuff[3]), tonumber(expstuff[4])))
					for i=5, #expstuff do
						local kv = string.Explode("§", expstuff[i])
						ent:SetKeyValue(kv[1], kv[2])
					end
					ent:Spawn()
					table.insert(self.MapEditorEntities, ent)
				end
			end
		end
	end

	self.Spawns = {}
	self.Spawns[TEAM_BLUE] = ents.FindByClass("info_player_blue")
	self.Spawns[TEAM_YELLOW] = ents.FindByClass("info_player_yellow")
	self.Spawns[TEAM_GREEN] = ents.FindByClass("info_player_green")
	self.Spawns[TEAM_RED] = ents.FindByClass("info_player_red")
	self.Spawns[TEAM_SPECTATOR] = ents.FindByClass("info_player*")

	local someold = ents.FindByClass("gmod_player_start")
	someold = table.Add(someold, ents.FindByClass("info_player_team_spawn"))
	for _, oldspawn in pairs(someold) do
		table.insert(self.Spawns[TEAM_SPECTATOR], oldspawn)

		if oldspawn.GreenTeam then
			table.insert(self.Spawns[TEAM_GREEN], oldspawn)
		elseif oldspawn.BlueTeam then
			table.insert(self.Spawns[TEAM_BLUE], oldspawn)
		elseif oldspawn.RedTeam then
			table.insert(self.Spawns[TEAM_RED], oldspawn)
		elseif oldspawn.YellowTeam then
			table.insert(self.Spawns[TEAM_YELLOW], oldspawn)
		end
	end

	for teamid, spawns in pairs(self.Spawns) do
		if teamid ~= TEAM_SPECTATOR then
			if #spawns == 0 then
				team.TeamInfo[teamid] = nil
			else
				table.insert(TEAMS_PLAYING, teamid)
			end
		end
	end

	for _, ent in pairs(ents.FindByClass("info_target")) do
		local lowername = string.lower(ent:GetName())
		if lowername == "blueflagpoint" then
			if team.TeamInfo[TEAM_BLUE] then team.TeamInfo[TEAM_BLUE].FlagPoint = ent:GetPos() end
		elseif lowername == "redflagpoint" then
			if team.TeamInfo[TEAM_RED] then team.TeamInfo[TEAM_RED].FlagPoint = ent:GetPos() end
		elseif lowername == "yellowflagpoint" then
			if team.TeamInfo[TEAM_YELLOW] then team.TeamInfo[TEAM_YELLOW].FlagPoint = ent:GetPos() end
		elseif lowername == "greenflagpoint" then
			if team.TeamInfo[TEAM_GREEN] then team.TeamInfo[TEAM_GREEN].FlagPoint = ent:GetPos() end
		end
	end

	for _, ent in pairs(ents.FindByClass("blueflagpoint")) do
		if team.TeamInfo[TEAM_BLUE] then
			team.TeamInfo[TEAM_BLUE].FlagPoint = ent:GetPos()
		end
	end

	for _, ent in pairs(ents.FindByClass("redflagpoint")) do
		if team.TeamInfo[TEAM_RED] then
			team.TeamInfo[TEAM_RED].FlagPoint = ent:GetPos()
		end
	end

	for _, ent in pairs(ents.FindByClass("yellowflagpoint")) do
		if team.TeamInfo[TEAM_YELLOW] then
			team.TeamInfo[TEAM_YELLOW].FlagPoint = ent:GetPos()
		end
	end

	for _, ent in pairs(ents.FindByClass("greenflagpoint")) do
		if team.TeamInfo[TEAM_GREEN] then
			team.TeamInfo[TEAM_GREEN].FlagPoint = ent:GetPos()
		end
	end

	for _, ent in pairs(ents.FindByClass("flagspawn")) do
		if ent.BlueTeam then
			if team.TeamInfo[TEAM_BLUE] then team.TeamInfo[TEAM_BLUE].FlagPoint = ent:GetPos() end
		elseif ent.RedTeam then
			if team.TeamInfo[TEAM_RED] then team.TeamInfo[TEAM_RED].FlagPoint = ent:GetPos() end
		elseif ent.YellowTeam then
			if team.TeamInfo[TEAM_YELLOW] then team.TeamInfo[TEAM_YELLOW].FlagPoint = ent:GetPos() end
		elseif ent.GreenTeam then
			if team.TeamInfo[TEAM_GREEN] then team.TeamInfo[TEAM_GREEN].FlagPoint = ent:GetPos() end
		end
	end

	local ent = ents.FindByClass("balldrop")[1]
	if ent then
		GAMEMODE.BallDrop = ent:GetPos()
	else
		local poss = {}
		for _, teamid in pairs(TEAMS_PLAYING) do
			local fp = team.TeamInfo[ teamid ].FlagPoint
			if fp then
				table.insert(poss, fp)
			end
		end
		if 0 < #poss then
			local pos = Vector(0,0,0)
			for _, ppp in pairs(poss) do
				pos = pos + ppp
			end
			GAMEMODE.BallDrop = pos / #poss + Vector(0, 0, 256)
		else
			GAMEMODE.BallDrop = Vector(0,0,0)
		end
	end

	for _, teamid in pairs(TEAMS_PLAYING) do
		for _, ent in pairs(self.Spawns[teamid]) do
			ent:SetPos(util.TraceLine({start=ent:GetPos() + Vector(0,0,16), endpos=ent:GetPos() + Vector(0,0,-8000), filter=ent}).HitPos + Vector(0,0,16))
			if ent:GetAngles() == Angle(0,0,0) then
				local ang = (GAMEMODE.BallDrop - ent:GetPos()):Angle()
				ang.pitch = 0
				ent:SetAngles(ang)
			end
		end
	end

	for _, teamid in pairs(TEAMS_PLAYING) do
		if not team.TeamInfo[teamid].FlagPoint then
			local poss = {}
			for _, ent in pairs(self.Spawns[teamid]) do
				table.insert(poss, ent:GetPos())
				if 0 < #poss then
					local pos = Vector(0,0,0)
					for _, ppp in pairs(poss) do
						pos = pos + ppp
					end
					team.TeamInfo[teamid].FlagPoint = pos / #poss + Vector(0, 0, 32)
				else
					team.TeamInfo[teamid].FlagPoint = Vector(0,0,0)
				end
			end
		end
	end

	--[[if file.Exists(GAMEMODE_NAME.."_gametype.txt", "DATA") then
		local gt = file.Read(GAMEMODE_NAME.."_gametype.txt")

		if self[gt.."Initialize"] then
			self[gt.."Initialize"](self)
		end
	elseif self.CTFInitialize then
		self:CTFInitialize()
	else
		local gt = self.GameTypes[1]
		if gt then
			self[gt.."Initialize"](self)
		else
			ErrorNoHalt("NO GAMETYPES FOUND!?")
		end
	end]]

	if file.Exists(GAMEMODE_NAME.."_gametype.txt", "DATA") then --???
		local gt = file.Read(GAMEMODE_NAME.."_gametype.txt")

		if self[gt.."Initialize"] then
			self[gt.."Initialize"](self)
		end
	else
		self:CTFInitialize()
	end

	if self.GameType == "HTF" then
		local ent = ents.Create(GAMEMODE.FlagEntity)
		if ent:IsValid() then
			ent:SetPos(GAMEMODE.BallDrop)
			ent:Spawn()
			for i, teamid in pairs(TEAMS_PLAYING) do
				team.TeamInfo[teamid].Flag = ent
			end
			GAMEMODE.Flag = ent
			GAMEMODE.Ball = ent
		end
	elseif self.FlagEntity then
		for i=1, #TEAMS_PLAYING do
			local teamid = TEAMS_PLAYING[i]
			if team.TeamInfo[teamid].FlagPoint then
				local ent = ents.Create(GAMEMODE.FlagEntity)
				if ent:IsValid() then
					ent:SetPos(team.TeamInfo[teamid].FlagPoint + Vector(0, 0, -16))
					ent:SetTeamID(teamid)
					ent:Spawn()
					team.TeamInfo[teamid].Flag = ent
				end
			end
		end
	end

	for _, ent in pairs(ents.FindByClass("logic_gametypeinitialize")) do
		if ent.GameType == self.GameType then
			ent:FireOutput("OnInitialize", ent, ent)
		end
	end

	self:SetWalls(false)

	RunConsoleCommand("mapcyclefile", "mapcycle_noxctf.txt")
end

function GM:PlayerSelectSpawn(pl)
	local myteam = pl:Team()
	local Count = GAMEMODE.Spawns[myteam] and #GAMEMODE.Spawns[myteam] or 0
	if Count == 0 then return pl end
	for i=0, 15 do
		local ChosenSpawnPoint = GAMEMODE.Spawns[myteam][math.random(1, Count)]
		if ChosenSpawnPoint and ChosenSpawnPoint:IsValid() and ChosenSpawnPoint:IsInWorld() then
			local blocked = false
			for _, ent in pairs(ents.FindInBox(ChosenSpawnPoint:GetPos() + Vector(-48, -48, 0), ChosenSpawnPoint:GetPos() + Vector(48, 48, 60))) do
				if ent and ent:IsValid() then
					if ent:IsPlayer() or string.find(ent:GetClass(), "prop_") then
						blocked = true
						break
					end
				end
			end
			if not blocked then
				return ChosenSpawnPoint
			end
		end
		if i == 15 then return ChosenSpawnPoint end
	end
	return pl
end

local function randomize(a, b)
	return b.RandomWeight < a.RandomWeight
end

function GM:Think()
	for _, pl in pairs(player.GetAll()) do
		pl:Think()
	end

	if not ENDGAME and not OVERTIME and ROUND_LENGTH <= CurTime() then
		self:TimeUp()
	end
end

function GM:ShuffleTeams()
	local sortteams = table.Copy(TEAMS_PLAYING)

	local curteam = 1

	math.randomseed(os.time())
	local allplayers = player.GetAll()

	for _, pl in pairs(allplayers) do
		pl.RandomWeight = math.random(1, 10000)
	end

	table.sort(allplayers, randomize)

	for _, pl in ipairs(allplayers) do
		if 0 < pl:GetPlayerClass() or pl.DeathClass and 0 < pl.DeathClass then
			pl.RandomWeight = nil
			pl:SetTeam(sortteams[curteam])
			pl:ForceRespawn()

			curteam = curteam + 1
			if not sortteams[curteam] then
				curteam = 1
			end
		end
	end
end

function GM:TimeUp()
	OVERTIME = true
	self:HandleOvertime()
end

GM.WallsUp = true
function GM:SetWalls(bool)
	if bool ~= self.WallsUp then
		for _, wall in pairs(ents.FindByClass("func_wall_toggle")) do
			wall:Fire("toggle", "", 0)
		end

		if string.sub(game.GetMap(), 1, 2) == "sf" then
			if bool then
				for _, brush in pairs(ents.FindByName("build*")) do
					if brush:GetClass() == "func_brush" then
						brush:Fire("Enable", "", 0)
					end
				end
			else
				for _, brush in pairs(ents.FindByName("build*")) do
					if brush:GetClass() == "func_brush" then
						brush:Fire("Disable", "", 0)
					end
				end
			end
		end

		self.WallsUp = not self.WallsUp
	end
end

ALLPROPS = {}
function GM:DestroyAllProps()
	for _, ent in pairs(ALLPROPS) do
		if ent and ent:IsValid() then
			ent:Remove()
		end
	end
	ALLPROPS = {}
end

function GM:OnNPCKilled(ent, attacker, inflictor)
end

function GM:PlayerNoClip(pl, on)
	if pl:IsAdmin() then
		if NDB then
			if on then
				LogAction("[Admin CMD] <"..pl:SteamID().."> "..pl:Name().." TURNED ON NOCLIP")
			else
				LogAction("[Admin CMD] <"..pl:SteamID().."> "..pl:Name().." TURNED OFF NOCLIP")
			end
		end

		return true
	end

	return false
end

function GM:OnPhysgunFreeze(weapon, phys, ent, pl)
	return false
end

function GM:DrainPower(prop, amount)
	if prop.Destroyed then
		return false
	end

	local totalpower = 0
	local shouldpower = false
	local todrain = {}
	local proppos = prop:GetPos()
	local propteam = prop:GetTeamID()
	for _, ent in pairs(CAPACITORS) do
		if ent.IsCapacitor and not ent.Destroyed and ent:GetTeamID() == propteam and ent:GetPos():Distance(proppos) <= CAPACITOR_RANGE then
			local totake = math.min(ent.ManaStorage, amount - totalpower)
			todrain[ent] = totake
			totalpower = totalpower + totake
			if amount <= totalpower then
				shouldpower = true
				break
			end
		end
	end

	if shouldpower then
		--[[if not prop.Powered then
			prop.Powered = true
			prop:Fire("powered", "", 0)
		end]]
		for ent, amount in pairs(todrain) do
			ent.ManaStorage = ent.ManaStorage - amount
			ent:SetSkin(ent.ManaStorage)
			if ent.GrandCapacitor then
				ent:SetMana(ent.ManaStorage)
				team.SetScore(ent:GetTeamID(), ent.ManaStorage)
			end
		end
		return true
	--[[elseif prop.Powered then
		prop.Powered = false
		prop:Fire("depowered", "", 0)]]
	end

	return false
end

function GM:Evaluate(prop, nodrain)
	if prop.Destroyed then
		prop.Powered = false
		return
	end
	local totalpower = 0
	local targetpower = prop.ManaDrainPerSecond
	local shouldpower = false
	local todrain = {}
	local propteam = prop:GetTeamID()
	for _, ent in pairs(ents.FindInSphere(prop:GetPos(), CAPACITOR_RANGE)) do
		if ent.IsCapacitor and not ent.Destroyed and ent:GetTeamID() == propteam then
			local totake = math.min(ent.ManaStorage, targetpower - totalpower)
			todrain[ent] = totake
			totalpower = totalpower + totake
			if targetpower <= totalpower then
				shouldpower = true
				break
			end
		end
	end

	if shouldpower then
		if not prop.Powered then
			prop.Powered = true
			prop:Fire("powered", "", 0)
		end
		if not nodrain then
			for ent, amount in pairs(todrain) do
				ent.ManaStorage = ent.ManaStorage - amount
				ent:SetSkin(ent.ManaStorage)
			end
		end
	elseif prop.Powered then
		prop.Powered = false
		prop:Fire("depowered", "", 0)
	end
end

function GM:EvaluatePower()
	for _, ent in pairs(ents.GetAll()) do
		if ent.MagusShield then ent.MagusShield = nil end
	end

	for _, shield in pairs(ents.FindByClass("prop_magusshield")) do
		if not shield.Destroyed then
			local myteam = shield:GetTeamID()
			for _, ent in pairs(ents.FindInSphere(shield:GetPos(), 375)) do
				if not ent.NoMagusShield and ent.PHealth and ent:GetTeamID() == myteam then
					ent.MagusShield = shield
				end
			end
		end
	end
end

local function IsInBox(tofind, vecmin, vecmax)
	for _, ent in pairs(ents.FindInBox(vecmin, vecmax)) do
		if tofind == ent then return true end
	end

	return false
end

function GM:PhysgunDrop(ply, ent)
	local phys = ent:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	if ent.NoWater and ent:WaterLevel() > 1 then
		ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
		self:RemoveProp(ply, ent)
		ply:PrintMessage(HUD_PRINTCENTER, "That type of prop can't be placed in liquid.")
		return
	end

	if IsGlitched(ent, ply, passive) then
		ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
		self:RemoveProp(ply, ent)
		return
	end

	local entpos = ent:GetPos()

	local spawns = ents.FindByClass("info_player*")
	table.Add(spawns, ents.FindByClass("prop_spawnpoint"))
	table.Add(spawns, ents.FindByClass("gmod_player_start"))
	for _, ent2 in pairs(spawns) do
		local ent2pos = ent2:GetPos()
		for _, ent3 in pairs(ents.FindInBox(ent2pos + Vector(-17, -17, 0), ent2pos + Vector(17, 17, 73))) do
			if ent3 == ent and ent2 ~= ent then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				self:RemoveProp(ply, ent)
				ply:PrintMessage(HUD_PRINTTALK, "That would be blocking a spawn point.")
				return
			end
		end
	end

	if ent.SolidBase then
		local tr = util.TraceLine({start=entpos, endpos=entpos + ent:GetUp() * (ent:OBBMins().z - 16), filter=ent})
		if not tr.HitWorld or tr.HitSky or tr.HitNoDraw or tr.HitNormal.z < 0.9 then
			ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
			self:RemoveProp(ply, ent)
			ply:PrintMessage(HUD_PRINTTALK, "That type of structure's base must be placed on solid ground.")
			return
		end
	end

	if ent.NoWater and util.PointContents(entpos) == 32 then
		ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
		self:RemoveProp(ply, ent)
		ply:PrintMessage(HUD_PRINTTALK, "That type of structure can't opperate in water or lava.")
		return
	end

	if ent.NoFreeze then
		ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
		self:RemoveProp(ply, ent)
		ply:PrintMessage(HUD_PRINTTALK, "Invalid spot for placement! Probably blocking something important.")
		return
	end

	if ent.ReverseTerritory then
		local desireddistance = entpos:Distance(team.TeamInfo[ply:Team()].FlagPoint)
		for _, teamid in pairs(TEAMS_PLAYING) do
			if teamid ~= ply:Team() and desireddistance < entpos:Distance(team.TeamInfo[teamid].FlagPoint) then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				self:RemoveProp(ply, ent)
				ply:PrintMessage(HUD_PRINTTALK, "Can only be placed in enemy territory.")
				return
			end
		end
	end

	for _, teamid in pairs(TEAMS_PLAYING) do
		if teamid ~= ply:Team() then
			local point = team.TeamInfo[teamid].FlagPoint
			if ent:NearestPoint(point):Distance(point) < BUILD_DISTANCE_TO_ENEMY then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				self:RemoveProp(ply, ent)
				ply:PrintMessage(HUD_PRINTTALK, "Too close to an enemy home.")
				return
			end
		else
			local point = team.TeamInfo[teamid].FlagPoint
			if IsInBox(ent, point + Vector(-96, -96, -40), point + Vector(96, 96, 128)) then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				ent:Remove()
				ply:LMR(29)
				return
			end
		end
	end

	if ent.ClusterPrevention then
		local entteam = ent:GetTeamID()
		for _, ent2 in pairs(ents.FindInSphere(entpos, 256)) do
			if ent ~= ent2 and ent2.ClusterPrevention == ent.ClusterPrevention and ent2:GetTeamID() == entteam then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				self:RemoveProp(ply, ent)
				ply:PrintMessage(HUD_PRINTTALK, "The structure is too close to other friendly structures and is creating interference.")
				return
			end
		end
	end

	ply.PropCarry = nil
	self:EvaluatePower()
	ent:Fire("dropped", "", 0)
end

local function CC_VoteRemove(pl)
	if not pl:IsValid() then return end

	pl.NextPhysReload = pl.NextPhysReload or 0
	if CurTime() < pl.NextPhysReload then return "" end
	pl.NextPhysReload = CurTime() + 1

	local trace = pl:TraceLine(3500)
	local ent = trace.Entity

	if not (ent:IsValid() and ent.PHealth and not ent:IsPlayer()) then return "" end

	if (ent.NoRemove or ent.PHealth == 64000) and not ent.Destroyed then
		pl:PrintMessage(HUD_PRINTCENTER, "This type of prop can't be removed during gameplay.")
		return ""
	end

	local entteam = ent:GetTeamID()
	if entteam ~= pl:Team() then return "" end

	local class = ent:GetClass()
	if class:lower() == "obelisk" or class == GAMEMODE.FlagEntity then return "" end

	if ent.Owner ~= pl:SteamID() and not pl:IsAdmin() or entteam ~= pl:Team() then
		ent.VoteRemove = ent.VoteRemove or {}
		ent.VoteRemove[pl:SteamID()] = true
		local count = table.Count(ent.VoteRemove)
		local needed = 0
		local plteam = pl:Team()
		for _, play in pairs(player.GetAll()) do
			if play:Team() == plteam and play:GetPlayerClassTable().Name == "Crafter" then
				needed = needed + 1
			end
		end
		needed = math.max(2, needed - 1)
		if needed <= count then
			pl:PrintMessage(HUD_PRINTCENTER, "The prop has been voted out of the world.")
			ent:EmitSound("npc/roller/mine/rmine_predetonate.wav")
			GAMEMODE:RemoveProp(pl, ent)
		else
			local votesneeded = math.ceil(needed - count)
			if votesneeded ~= 1 then
				pl:PrintMessage(HUD_PRINTCENTER, "This prop needs "..votesneeded.." more votes to remove it.")
			else
				pl:PrintMessage(HUD_PRINTCENTER, "This prop needs 1 more vote to remove it.")
			end
		end
	else
		GAMEMODE:RemoveProp(pl, ent)
	end

	return ""
end
if NDB then NDB.AddChatCommand("/voteremove", CC_VoteRemove, "Votes to remove the prop you are looking at.") end

function GM:OnPhysgunReload(weapon, pl)
	CC_VoteRemove(pl, "")
end

function GM:CanPlayerEnterVehicle(pl, veh, role)
	if not pl:Alive() or pl.BerserkerCharge or pl.Stunned or pl.HealRing or pl.ChargeFireBall then return false end

	local vehbase = veh:GetVehicleParent()
	if vehbase:IsValid() and vehbase.PilotSeat == veh then
		if pl:GetPlayerClassTable().CantPilot then
			pl:PrintMessage(HUD_PRINTCENTER, "Your class can't pilot vehicles.")
			return false
		end

		if pl:IsCarrying() then
			pl:PrintMessage(HUD_PRINTCENTER, "You can't drive vehicles or control turrets while holding the flag!")
			return false
		end

		if veh.IsTurret then
			return veh:GetTeamID() == pl:Team()
		else
			local deployer = vehbase.Deployer
			if deployer and deployer:IsValid() and deployer:Team() == pl:Team() and deployer ~= pl and deployer:Alive() and CurTime() < vehbase.DeployTime + 10 then
				pl:PrintMessage(HUD_PRINTCENTER, "You can't steal recently spawned vehicles.")
				return false
			end

			return true
		end
	end

	return vehbase.Team and (pl:Team() == vehbase:Team() or vehbase:Team() == 0) or vehbase.GetTeamID and (pl:Team() == vehbase:GetTeamID() or vehbase:GetTeamID() == 0) or vehbase.PilotSeat and not vehbase.PilotSeat:GetDriver():IsValid() or vehbase.GetPilotSeat and not vehbase:GetPilotSeat():GetDriver():IsValid()
end

function GM:CanExitVehicle(veh, pl)
	pl:ExitVehicle()

	local vehbase = veh:GetVehicleParent(self)
	if vehbase:IsValid() and vehbase.Exit then
		vehbase:Exit(pl, veh)
	end

	return true
end

function GM:PlayerEnteredVehicle(pl, veh, role)
	pl:RemoveInvisibility()

	local vehbase = veh:GetVehicleParent(self)
	if vehbase:IsValid() and vehbase.Enter then
		vehbase:Enter(pl, veh, role)
		pl.LastVehicle = vehbase
	end
end

function GM:RemoveProp(ply, ent)
	local teamid = ent:GetTeamID()
	if teamid and not ent.RevokedTeamCount then
		team.AddProps(teamid, -1)
		ent.RevokedTeamCount = true
	end

	if ent.Gone then ent:Remove() return end

	if not teamid then return end

	if ent.ReversePointsThresh and ent.ReversePointsThresh < CurTime() and ent.Owner then
		for _, pl in pairs(player.GetAll()) do
			if pl:SteamID() == ent.Owner then
				pl:CenterPrint("Crafting removal penalty (-1)~sbuttons/button8.wav", "COLOR_RED", 3)
				if NDB then pl:AddSilver(-CRAFTER_CORE_DEFENSE_BONUS) end
				pl:AddFrags(-1)
				pl:AddDefense(-1)
				break
			end
		end
	end

	for i, prop in pairs(ALLPROPS) do
		if ent == prop then
			table.remove(ALLPROPS, i)
		end
	end

	ent.Gone = true
	ent:Remove()
end

function GM:PhysgunPickup(pl, ent)
	if ent:GetClass() == self.FlagEntity then return false end
	if ent:IsPlayer() then return false end
	if not ent.Owner then return false end

	if pl:IsAdmin() and ent.Owner ~= pl:SteamID() then
		pl:PrintMessage(HUD_PRINTCENTER, "This prop was spawned by <"..tostring(ent.Owner)..">")
	end

	if (ent:GetTeamID() ~= pl:Team() or ent.Owner ~= pl:SteamID()) and not pl:IsAdmin() then
		for _, pl2 in pairs(player.GetAll()) do
			if pl2:SteamID() == ent.Owner then
				pl:PrintMessage(HUD_PRINTCENTER, "This prop was spawned by "..pl2:Name().." <"..pl2:SteamID()..">")
				return false
			end
		end
		if type(ent.Owner) == "string" then
			pl:PrintMessage(HUD_PRINTTALK, "This prop was spawned by <"..tostring(ent.Owner).."> who has left the game. You now own this prop.")
		end
		ent.Owner = pl:SteamID()
	end

	if ent.Destroyed and ent.PHealth == 0 then
		pl.PropCarry = ent
		return true
	end

	return false
end

function GM:ResetAllFlags(mode)
	for _, pl in pairs(player.GetAll()) do
		pl.Carrying = nil
	end
	for _, ent in pairs(ents.FindByClass("flag")) do
		ent.Carrier = ent
		ent:SetPos(team.TeamInfo[ent:GetTeamID()].FlagPoint + Vector(0,0,38))
		ent:SetSolid(SOLID_VPHYSICS)
		ent.Phys:EnableGravity(true)
		ent.Phys:EnableMotion(mode == 2)
		if mode == 2 then
			ent.Phys:Wake()
		end
		ent:SetSkin(0)
	end
end

function GM:PlayerCanPickupWeapon(pl, wep)
	if wep.Classes then
		local myclass = pl:GetPlayerClassTable().Name
		for i, class in pairs(wep.Classes) do
			if myclass == class then return true end
		end
		return false
	end
	return true
end

function GM:GameTypePlayerDisconnected(pl)
end

GM.AlreadyLost = {}
function GM:PlayerDisconnected(pl)
	self:GameTypePlayerDisconnected(pl)

	pl:RemoveAllStatus(true, true)

	local teaminfo = team.TeamInfo[pl:Team()]
	local steamid = pl:SteamID()

	if self.GameType == "ASLT" then
		if not self.AlreadyLost[steamid] and teaminfo.Flag and teaminfo.Flag.CoreHealth < 3000 and pl.InitialSpawned + 120 < CurTime() then
			self.AlreadyLost[steamid] = true
			pl:AddPKV("AssaultLosses", 1)
			if NDB then NDB.SaveInfo(pl) end
		end
	elseif self.GameType == "KOTH" then
		local plteam = pl:Team()
		local topscore = 0
		local topteam = 0
		for _, teamid in pairs(TEAMS_PLAYING) do
			if topscore < team.GetScore(teamid) then
				topscore = team.GetScore(teamid)
				topteam = teamid
			end
		end
		if not self.AlreadyLost[steamid] and plteam ~= topteam and KOTH_TIME - 60 < topscore and pl.InitialSpawned + 120 < CurTime() then
			self.AlreadyLost[steamid] = true
			pl:AddPKV("AssaultLosses", 1)
			if NDB then NDB.SaveInfo(pl) end
		end
	elseif self.GameType == "HTF" then
		local plteam = pl:Team()
		local topscore = 0
		local topteam = 0
		for _, teamid in pairs(TEAMS_PLAYING) do
			if topscore < team.GetScore(teamid) then
				topscore = team.GetScore(teamid)
				topteam = teamid
			end
		end
		if not self.AlreadyLost[steamid] and plteam ~= topteam and HTF_TIME - 60 < topscore and pl.InitialSpawned + 120 < CurTime() then
			self.AlreadyLost[steamid] = true
			pl:AddPKV("AssaultLosses", 1)
			if NDB then NDB.SaveInfo(pl) end
		end
	end
end

function GM:PlayerDeathThink(pl)
	if pl.NextSpawnTime < CurTime() and pl:KeyDown(IN_ATTACK) then
		pl:Spawn()
	end
end

function GM:PlayerUse(pl, entity)
	return true
end

function GM:FlagTaken(selfteam, byplayer)
	umsg.Start("FTak")
		umsg.Short(selfteam)
		umsg.String(byplayer:Name())
	umsg.End()
end

function GM:FlagDropped(selfteam, byplayer)
	umsg.Start("FDro")
		umsg.Short(selfteam)
		if type(byplayer) == "string" then
			umsg.String(byplayer)
		else
			umsg.String(byplayer:Name())
		end
	umsg.End()
end

CTFCaptureAwards = {}
CTFCaptureAwards[50] = "50_caps"
CTFCaptureAwards[125] = "125_caps"
CTFCaptureAwards[250] = "250_caps"
CTFCaptureAwards[500] = "500_CTF_Captures"
CTFCaptureAwards[750] = "750_CTF_Captures"
CTFCaptureAwards[1000] = "1000_CTF_Captures"

function GM:FlagCaptured(carrier, selfteam, otherteam)
	if ENDGAME then return end

	team.AddScore(selfteam, 1)

	local carriers = team.TeamInfo[otherteam].Flag.Carriers
	local mostcarried = 0
	local mostcarriedby = carrier
	for seperatecarrier, timecarried in pairs(carriers) do
		if mostcarried < timecarried then
			mostcarried = timecarried
			mostcarriedby = seperatecarrier
		end
	end

	carrier:AddFrags(15)

	if NDB then
		carrier:AddSilver(BONUS_CAPTURE)
		carrier:AddPKV("CTFCaptures", 1)

		if CTFCaptureAwards[carrier.CTFCaptures] then
			NDB.GiveAward(carrier, CTFCaptureAwards[carrier.CTFCaptures])
		end
	end

	umsg.Start("FCap")
		umsg.String(carrier:Name())
		umsg.Short(selfteam)
		umsg.Short(otherteam)
	umsg.End()

	if OVERTIME or MAX_SCORE <= team.GetScore(selfteam) then
		self:EndGame(selfteam, {})
	end
end

function GM:CenterPrintAll(message, color, lifetime)
	BroadcastLua(string.format("GAMEMODE:CenterPrint(%q,%s,%i)", message or "", color or "nil", lifetime or 5))
end

function GM:PlayerCanCast(pl, spell)
	return not pl:InVehicle()
end

local function RealMap(map)
	return string.match(map, "(.+)%.bsp")
end

function GM:LoadNextMap()
	game.LoadNextMap()
end

function GM:EndGame(winner, slaves)
	if ENDGAME then return end
	ENDGAME = true

	slaves = slaves or {}

	self.PlayerCanCast = function() return false end

	if NDB then
		NDB.VoteMap.InitiateVoteMap(30)
	else
		timer.Simple(35, function() gamemode.Call("LoadNextMap") end)
	end
	timer.Simple(5, function() BroadcastLua("OpenVoteMenu()") end)
	timer.Simple(25, function() BroadcastLua("OpenGTVoteMenu()") end)
	VOTEMAPOVER = CurTime() + 25

	for _, pl in pairs(player.GetAll()) do
		local steamid = pl:SteamID()
		if pl:Team() == winner then
			if slaves[steamid] then
				pl:PrintMessage(HUD_PRINTTALK, "Being taken in as a slave, you and your old team members has lost this round.")
			else
				pl:PrintMessage(HUD_PRINTTALK, "You and your team members have won this round.")
			end
		elseif pl:Team() ~= TEAM_SPECTATOR then
			pl:PrintMessage(HUD_PRINTTALK, "You and your team members have lost this round.")
		end
	end

	if NDB then
		if 0 < winner then
			local winmessage = "You and your team members won "..BONUS_WIN.." Silver!"
			for _, pl in pairs(player.GetAll()) do
				local steamid = pl:SteamID()
				if CurTime() < pl.InitialSpawned + 120 then
					pl:PrintMessage(HUD_PRINTTALK, "You did not receive a win or loss due to not being in the game for more than two minutes.")
				elseif pl:Team() == winner then
					if slaves[steamid] then
						if not GAMEMODE.AlreadyLost[steamid] then
							GAMEMODE.AlreadyLost[steamid] = true
							pl:AddPKV("AssaultLosses", 1)
						end
						pl:PrintMessage(HUD_PRINTTALK, "Being taken in as a slave, you did not receive a bonus for winning. Personal wins / losses: "..pl.AssaultWins.." / "..pl.AssaultLosses)
					else
						pl:AddSilver(BONUS_WIN)
						pl:AddPKV("AssaultWins", 1)
						pl:PrintMessage(HUD_PRINTTALK, winmessage.." Personal wins / losses: "..pl.AssaultWins.." / "..pl.AssaultLosses)
					end
				elseif pl:Team() ~= TEAM_SPECTATOR and not GAMEMODE.AlreadyLost[steamid] then
					GAMEMODE.AlreadyLost[steamid] = true
					pl:AddPKV("AssaultLosses", 1)
					pl:PrintMessage(HUD_PRINTTALK, "Your team has lost the round. Personal wins / losses: "..pl.AssaultWins.." / "..pl.AssaultLosses)
				end
			end
		end
	end

	for _, pl in pairs(player.GetAll()) do
		pl:Freeze(true)
		pl:GodEnable()
	end

	umsg.Start("EndG")
		umsg.Short(winner)
	umsg.End()

	if NDB then NDB.GlobalSave() end

	hook.Add("PlayerSpawn", "FREEZENEW", function(p) p:Freeze(true) p:GodEnable() end)
end

umsg.PoolString("Auto-return")
function GM:FlagReturned(pl, myteam, faraway)
	if not pl then
		umsg.Start("FRet")
			umsg.String("Auto-return")
			umsg.Short(myteam)
			umsg.Bool(faraway)
		umsg.End()
		return
	end

	if faraway then
		if NDB then pl:AddSilver(BONUS_RETURN) end
		pl:AddFrags(3)
		pl:AddDefense(3)
	else
		pl:AddFrags(1)
		pl:AddDefense(1)
	end

	umsg.Start("FRet")
		umsg.String(pl:Name())
		umsg.Short(myteam)
		umsg.Bool(faraway)
	umsg.End()
end

function GM:PlayerDeathSound()
	return true
end

local MineAwards = {}
MineAwards[2] = "Novice_Miner"
MineAwards[4] = "Adept_Miner"
MineAwards[8] = "Master_Miner"
MineAwards[16] = "Awesome_Miner"
MineAwards[24] = "Crazy_Miner"
MineAwards[32] = "Lunatic_Miner"
MineAwards[49] = "MINER_FOURTY-NINER"

GM:AddLifeStatus("BomberKills")
GM:AddLifeStatus("HarpoonKills")
GM:AddLifeStatus("BurnKills")
GM:AddLifeStatus("RoverKills")

function GM:PlayerHurt(pl, attacker, healthremaining, damage)
	if damage > 0 then
		pl.LastDamaged = CurTime()
	end

	if attacker:IsPlayer() and attacker ~= pl then
		pl:SetLastAttacker(attacker)
	end

	if healthremaining <= 0 then
		if attacker:IsPlayer() and attacker:InVehicle() and attacker ~= pl then
			local pilot = attacker:GetVehicle():GetVehicleParent().PilotSeat:GetDriver()
			if attacker ~= pilot then
				pl.LastAttacker2 = pilot
				pl.LastAttacked2 = CurTime()
				return
			end
		end
	else
		pl:PlayPainSound()
	end
end

local function MakinAWep(wep, pos, vel, mana)
	if not wep then return end

	local ent = ents.Create(wep)
	if ent:IsValid() then
		ent:SetPos(util.TraceLine({start = pos, endpos = pos + VectorRand() * 42, filter=self}).HitPos)
		ent.Dropped = true
		ent:Spawn()
		ent.Mana = mana or ent.Mana
		ent:PhysicsInit(SOLID_VPHYSICS)
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(vel + VectorRand() * 150 + Vector(0, 0, 400))
			phys:AddAngleVelocity((vel:Length() * VectorRand() * 90))
		end
		ent:InitiateDeath(15)
	end
end

function GM:DoPlayerDeath(pl, attacker, dmginfo)
	if pl == attacker then
		pl.NextSpawnTime = CurTime() + RESPAWN_TIME_SUICIDE
		pl.Suicided = true
	else
		pl.NextSpawnTime = CurTime() + RESPAWN_TIME
	end

	local wep = pl:GetActiveWeapon()
	if wep.Droppable then
		timer.Simple(0, function() MakinAWep(wep.Droppable, pl:GetPos(), pl:GetVelocity(), wep.Mana or 0) end)
	end

	local lastattacker, lastattacked, lastattacker2, lastattacked2 = pl:GetLastAttacker()
	if (attacker == pl or not attacker:IsPlayer()) and lastattacker:IsValid() and CurTime() < pl.LastAttacked + 8 then attacker = lastattacker end

	if attacker:GetVehicleParent():IsValid() then
		attacker = attacker:GetVehicleParent()
	end

	local inflictor = dmginfo:GetInflictor()
	if inflictor:GetVehicleParent():IsValid() then
		inflictor = inflictor:GetVehicleParent()
	end

	if attacker.ScriptVehicle then
		local driver = (attacker.GetPilotSeat and attacker:GetPilotSeat() or attacker.PilotSeat):GetDriver()
		if driver:IsValid() then
			inflictor = attacker
			attacker = driver
		end
	end

	if attacker:IsValid() then
		local owner = attacker:GetOwner()
		if owner:IsPlayer() then
			attacker = owner
		end
	end

	local isassist = lastattacker2:IsValid() and lastattacker2 ~= attacker and lastattacker2 ~= pl and CurTime() <= pl.LastAttacked2 + 3
	if pl.BloodBoil and not pl.Suicided then
		pl:Gib(dmginfo)
	elseif pl:Health() < -45 then
		pl:Gib(dmginfo)
	else
		if not pl.KnockedDown then
			pl:CreateRagdoll()
		end
		if pl:GetPlayerClassTable().DeathSounds then
			pl:EmitSound(pl:GetPlayerClassTable().DeathSounds())
		else
			pl:PlayDeathSound()
		end
	end

	pl:RemoveInvisibility()

	local uid = pl:UniqueID()
	for key, timername in pairs(LifeStatusTimers) do
		timer.Destroy(uid..timername)
	end
	for key, status in pairs(LifeStatus) do
		pl[status] = nil
	end
	pl:RemoveAllStatus(true, true)

	local wascarrying
	if pl:IsCarrying() then
		wascarrying = true
		pl.Carrying:Dropped(pl)
		pl.Carrying = nil
	end

	pl.LastDeath = CurTime()
	pl:AddDeaths(1)

	umsg.Start("NextRespawn", pl)
		umsg.Float(pl.NextSpawnTime)
	umsg.End()

	if attacker == pl then
		pl:AddFrags(-1)
		if NDB then
			pl:AddPKV("CTFDeaths", 1)
		end
	elseif attacker:IsPlayer() and attacker:Team() ~= pl:Team() then
		if pl:IsCarrying() then
			attacker:AddFrags(4)
		else
			attacker:AddFrags(2)
		end

		if isassist then
			lastattacker2:AddFrags(1)
			lastattacker2:AddAssists(1)
		end

		local spawntime = CurTime() - pl.SpawnTime

		if pl:GetPos():Distance(team.TeamInfo[attacker:Team()].FlagPoint) < 1024 then
			if NDB then attacker:AddSilver(math.ceil(15 + math.min(150, spawntime * 0.25)) + BONUS_CORE_DEFENSE) end
			attacker:AddDefense(1)
			if isassist then
				if NDB then lastattacker2:AddSilver(math.ceil(5 + math.min(50, spawntime * 0.125)) + BONUS_CORE_DEFENSE * 0.5) end
				lastattacker2:AddDefense(1)
			end
		else
			if NDB then
				attacker:AddSilver(math.ceil(15 + math.min(150, spawntime * 0.25)))
				if isassist then
					lastattacker2:AddSilver(math.ceil(5 + math.min(50, spawntime * 0.125)))
				end
			end
		end

		attacker:AddKills(1)
		if NDB then
			pl:AddPKV("CTFDeaths", 1)
		end

		if NDB then
			local inflictorclass = inflictor:GetClass()
			if inflictor.IsMine then
				if not (attacker.LastMineKill == pl and CurTime() < attacker.NextMineKillTime) then
					attacker.LastMineKill = pl
					attacker.NextMineKillTime = CurTime() + 60
					local newmines = attacker.MineKills + 1
					attacker.MineKills = newmines
					for amount, award in pairs(MineAwards) do
						if amount <= newmines then
							if not attacker:HasAward(award) then
								NDB.GiveAward(attacker, award)
							end
						end
					end
				end
			elseif inflictorclass == "projectile_harpoon" then
				local newkills = (attacker.HarpoonKills or 0) + 1
				attacker.HarpoonKills = newkills
				if newkills == 1 and not attacker:HasAward("Harpwned") then
					NDB.GiveAward(attacker, "Harpwned")
				elseif newkills == 2 and not attacker:HasAward("Whaling_Man") then
					NDB.GiveAward(attacker, "Whaling_Man")
				elseif newkills == 4 and not attacker:HasAward("Ar_She_Blows") then
					NDB.GiveAward(attacker, "Ar_She_Blows")
				end
			elseif inflictorclass == "projectile_vulturebomb" then
				local newkills = (attacker.BomberKills or 0) + 1
				attacker.BomberKills = newkills
				if newkills == 5 and not attacker:HasAward("Bomberman") then
					NDB.GiveAward(attacker, "Bomberman")
				elseif newkills == 20 and not attacker:HasAward("Fatboy") then
					NDB.GiveAward(attacker, "Fatboy")
				elseif newkills == 50 and not attacker:HasAward("Beeee_17_Boamber") then
					NDB.GiveAward(attacker, "Beeee_17_Boamber")
				end
			elseif inflictorclass == "dummy_burn" then
				local newkills = (attacker.BurnKills or 0) + 1
				attacker.BurnKills = newkills
				if newkills == 3 and not attacker:HasAward("Hot_Foot") then
					NDB.GiveAward(attacker, "Hot_Foot")
				elseif newkills == 10 and not attacker:HasAward("My_Hair_Is_On_Fire") then
					NDB.GiveAward(attacker, "My_Hair_Is_On_Fire")
				elseif newkills == 15 and not attacker:HasAward("Anti_Semetic") then
					NDB.GiveAward(attacker, "Anti_Semetic")
				end
			elseif inflictorclass == "vehicle_noxbase" or inflictorclass == "roverwheel" then
				local newkills = (attacker.RoverKills or 0) + 1
				attacker.RoverKills = newkills
				if newkills == 3 and not attacker:HasAward("You_Cant_Pull_Me_Over") then
					NDB.GiveAward(attacker, "You_Cant_Pull_Me_Over")
				elseif newkills == 8 and not attacker:HasAward("Vroom_Im_A_Car") then
					NDB.GiveAward(attacker, "Vroom_Im_A_Car")
				elseif newkills == 15 and not attacker:HasAward("Get_Out_Of_The_Way") then
					NDB.GiveAward(attacker, "Get_Out_Of_The_Way")
				end
			elseif inflictor.IsAirVehicle then
				if dmginfo:GetDamageType() == DMG_CRUSH then
					if not util.TraceLine({start = pl:GetPos(), endpos = pl:GetPos() + Vector(0, 0, -350), mask = MASK_SOLID_BRUSHONLY}).Hit and not attacker:HasAward("No_Flying_Zone") then
						NDB.GiveAward(attacker, "No_Flying_Zone")
					end
					if wascarrying and self.GameType == "CTF" and pl:GetPos():Distance(team.TeamInfo[pl:Team()].FlagPoint) <= 800 and not attacker:HasAward("last-ditch_effort") then
						NDB.GiveAward(attacker, "last-ditch_effort")
					end
				end
			elseif inflictorclass == "projectile_crossbowbolt" then
				inflictor.Killed = inflictor.Killed + 1
				if inflictor.Killed == 2 and not attacker:HasAward("Multi-Skewer") then
					NDB.GiveAward(attacker, "Multi-Skewer")
				elseif inflictor.Killed == 3 and not attacker:HasAward("Shish_Kabob") then
					NDB.GiveAward(attacker, "Shish_Kabob")
				end
			end

			if attacker:GetPlayerClassTable().Name == "Warrior" and 10 <= spawntime and string.sub(inflictorclass, 1, 5) ~= "prop_" then
				attacker.WarriorKills = attacker.WarriorKills + 1
				if attacker.WarriorKills == 7 and not attacker:HasAward("Warrior_Award") then
					NDB.GiveAward(attacker, "Warrior_Award")
				end
			end

			if CTFKillAwards[attacker.CTFKills] then
				NDB.GiveAward(attacker, CTFKillAwards[attacker.CTFKills])
			end
		end
	end

	self:PlayerDeath2(pl, inflictor, attacker, lastattacker2, isassist)

	--Necromancer
	pl:CreateSoul()
end
GM:AddLifeStatus("PreInvisibleDrawWorldModel")

concommand.Add("dropflag", function(sender, command, arguments)
	if sender:IsValid() and sender:Alive() and IsValid(sender.Carrying) then
		sender.NextFlagPickup = CurTime() + 3
		sender.Carrying:Dropped(sender)
	end
end)

function GM:ShowHelp(pl)
	pl:SendLua("MakepHelp()")
end

function GM:ShowTeam(pl)
	if pl:Team() == TEAM_SPECTATOR then
		pl:SendLua("MakepSelectTeam()")
	else
		pl:SendLua("MakepClasses()")
	end
end

function GM:ShowSpare1(pl)
	pl:SendLua("MakepSpells()")
end

function GM:ShowSpare2(pl)
	pl:SendLua("MakepOptions()")
end

function GM:PlayerDeath(Victim, Inflictor, Attacker)
end

function GM:PlayerDeath2(Victim, Inflictor, Attacker, Attacker2, isassist)
	Victim:StripAmmo()

	if Inflictor and Inflictor == Attacker and Inflictor:IsPlayer() then
		Inflictor = Inflictor:GetActiveWeapon()
		if not Inflictor:IsValid() then Inflictor = Attacker end
	end

	local owner = Attacker:GetOwner()
	if owner:IsPlayer() then
		Attacker = owner
	end

	local inflictorclass = Inflictor.DisplayClass or Inflictor:GetClass()
	if Attacker == Victim then
		umsg.Start("PlayerKilledSelf")
			umsg.Entity(Victim)
			umsg.String(inflictorclass)
		umsg.End()
	elseif Attacker:IsPlayer() then
		if isassist then
			umsg.Start("PlayerKilledByPlayers")
				umsg.Entity(Victim)
				umsg.String(inflictorclass)
				umsg.Entity(Attacker)
				umsg.Entity(Attacker2)
			umsg.End()
		else
			umsg.Start("PlayerKilledByPlayer")
				umsg.Entity(Victim)
				umsg.String(inflictorclass)
				umsg.Entity(Attacker)
			umsg.End()
		end
	else
		umsg.Start("PlayerKilled")
			umsg.Entity(Victim)
			umsg.String(inflictorclass)
			umsg.String(Attacker:GetClass())
		umsg.End()
	end
end

function GM:PlayerLoadout(pl)
end

function GM:PlayerCanSuicide(pl)
	return pl:Alive()
end

local HealerAwards = {}
HealerAwards[250] = "250HP_Cleric"
HealerAwards[500] = "500HP_Cleric"
HealerAwards[750] = "750HP_Cleric"
HealerAwards[1000] = "1000HP_Cleric"
HealerAwards[1500] = "1500HP_Cleric"
HealerAwards[2500] = "2500HP_Cleric"
HealerAwards[5000] = "5000HP_Cleric"

function GM:PlayerHeal(pl, caster, amount)
	local maxhealth = pl:GetMaxHealth()
	local curhealth = pl:Health()
	pl:SetHealth(math.min(maxhealth, curhealth + amount))
	if pl ~= caster and caster:IsValid() and pl.LastAttacker ~= pl then
		local newhphealed = caster.AllyHPHealed + (pl:Health() - curhealth)
		caster.AllyHPHealed = newhphealed
		if NDB then
			for amount, award in pairs(HealerAwards) do
				if amount <= newhphealed then
					local found = false
					for _, plaward in pairs(caster.Awards) do
						if plaward == award then
							found = true
							break
						end
					end
					if not found then
						NDB.GiveAward(caster, award)
					end
				end
			end
		end
	end
end

concommand.Add("initpostentity", function(sender, command, arguments)
	if not sender.DidInitPostEntity then
		sender.DidInitPostEntity = true

		gamemode.Call("PlayerReady", sender)
	end
end)

--[[concommand.Add("nox_jointeam", function(sender, command, arguments)
	if sender:Team() == TEAM_SPECTATOR then
		local teamid = tonumber(arguments[1]) or 0
		if table.HasValue(TEAMS_PLAYING, teamid) then
			local myplayercount = team.NumPlayers(teamid)
			for i, otherteamid in pairs(TEAMS_PLAYING) do
				if otherteamid ~= teamid and team.NumPlayers(otherteamid) < myplayercount then
					sender:SendLua("surface.PlaySound(\"buttons/button2.wav\")")
					return
				end
			end

			sender:SendLua("surface.PlaySound(\"buttons/button14.wav\")")
			sender:SetTeam(teamid)
			--sender:SendLua("ClosepTeamSelect() MakepClasses()")
		end
	end
end)]]

local function DelayFeed(self, pl)
	if pl:IsValid() then
		pl:SendLua("InitTeams({"..table.concat(TEAMS_PLAYING, ",").."}) OVERTIME="..tostring(OVERTIME).." "..(pl:Team() == TEAM_SPECTATOR and "MakepTeamSelect()" or "MakepClasses()"))
		if self.FlagEntity then
			for i in pairs(team.TeamInfo) do
				if i < 9 and 0 < i then
					umsg.Start("RecFlagInfo", pl)
						umsg.Short(i)
						umsg.Vector(team.TeamInfo[i].FlagPoint)
						umsg.Entity(team.TeamInfo[i].Flag)
					umsg.End()
				end
			end
		end

		self:InitialQuery(pl)
	end
end

function GM:PlayerReady(pl)
	if pl:IsValid() then
		timer.Simple(1, function() DelayFeed(self, pl) end)
	end
end

--[[concommand.Add("chooseside", function(sender, command, arguments)
	print(arguments[1])
	if sender:Team() == TEAM_SPECTATOR then
		for _, id in pairs(TEAMS_PLAYING) do
			if arguments[1] == tostring(id) then
				sender.ChosenTeam = id
				sender:SendLua("MakepClasses()")
				return
			end
		end
	end
	sender:SendLua("MakepTeams()")
end)]]

function GM:InitialVariables(pl)
	pl.InitialSpawned = CurTime()
	pl.LastInfo = {}
	pl.LastDeath = 0
	pl.NextSpawnTime = 0
	pl.NextHealthRegen = 0
	pl.LastDamaged = 0
	pl.NextPainSound = 0
	pl.CoreDamageLevel = 0
	pl.CounterSpelled = 0
	pl.AllyHPHealed = 0
	pl.DefenseThisRound = 0
	pl.OffenseThisRound = 0
	pl.AssistsThisRound = 0
	pl.KillsThisRound = 0
	pl.MineKills = 0
	pl.NextReqInfo = 0
	pl.VehicleTimers = {}
	pl:ClearLastAttacker()
	pl:SprintDisable()
	--pl:SetCanWalk(false)
	pl:SetCanZoom(false)
end

function GM:PlayerInitialSpawn(pl)
	self:InitialVariables(pl)

	pl:SetNoCollideWithTeammates(true)
	pl:SetAvoidPlayers(true)

	if self.TeamLocks[pl:UniqueID()] then
		pl:SetTeam(self.TeamLocks[pl:UniqueID()])
	else
		pl:JoinBalancedTeam()
	end
end

function GM:InitialQuery(pl)
	if not NDB then return end

	for i, award in pairs(CTFCaptureAwards) do
		if pl.CTFCaptures >= i then
			local hasaward = false
			for _, aw in pairs(pl.Awards) do
				if aw == award then
					hasaward = true
				end
			end
			if not hasaward then
				NDB.GiveAward(pl, award)
			end
		end
	end

	for i, award in pairs(CTFKillAwards) do
		if i <= pl.CTFKills then
			local hasaward = false
			for _, aw in pairs(pl.Awards) do
				if aw == award then
					hasaward = true
				end
			end
			if not hasaward then
				NDB.GiveAward(pl, award)
			end
		end
	end

	--[[for i, award in pairs(AssaultCoresDestroyedAwards) do
		if i <= pl.AssaultCoresDestroyed then
			local hasaward = false
			for _, aw in pairs(pl.Awards) do
				if aw == award then
					hasaward = true
				end
			end
			if not hasaward then
				NDB.GiveAward(pl, award)
			end
		end
	end]]
end

function GM:CreateCamera(pl)
end

local function NoColliding(ent)
	if ent:IsValid() then
		ent:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	end
end

function GM:PlayerSpawn(pl)
	pl.NextTriggerNoXHurt = 0
	pl.NextPainSound = 0

	pl.Suicided = nil

	pl:ClearLastAttacker()

	if pl:Team() == TEAM_SPECTATOR and not pl.DeathClass or pl:GetPlayerClass() < 1 then
		pl:Spectate(OBS_MODE_ROAMING)
		return
	end

	pl.WarriorKills = 0

	if pl.DeathClass and pl:GetPlayerClass() ~= pl.DeathClass then
		pl:SetPlayerClass(pl.DeathClass)
		pl.DeathClass = nil
	end

	pl:UnSpectate()

	local cur_Class = pl:GetPlayerClass()
	if cur_Class == 1 then
		pl:ShouldDropWeapon(true)
	else
		pl:ShouldDropWeapon(false)
	end

	pl:SetRenderMode(RENDERMODE_TRANSALPHA)
	pl:SetCollisionGroup(COLLISION_GROUP_PLAYER)

	local classtab = pl:GetPlayerClassTable()
	pl:SetMana(classtab.Mana / 2, true)
	pl.SpawnTime = CurTime()
	pl.NextSpell = 0
	pl.AbilityDelays = {}
	self:SetPlayerSpeed(pl, classtab.Speed)

	pl:StopAllLuaAnimations(.1)

	if classtab.SWEP then
		pl:Give(classtab.SWEP)
	end

	if classtab.SWEPs then
		for _, swp in pairs(classtab.SWEPs) do
			pl:Give(swp)
		end
	end

	if classtab.PreferredSWEP then
		pl:SelectWeapon(classtab.PreferredSWEP)
	end

	pl:SetMaxHealth(classtab.Health)
	pl:SetHealth(classtab.Health)

	pl:SetModel(classtab.Model or "models/player/kleiner.mdl")
	pl:RefreshVoiceSet()

	pl:SendLocalPlayerSpawn()

	local teamstuff = team.TeamInfo[pl:Team()]
	if teamstuff then
		local teamcolor = teamstuff.Color
		pl:SetPlayerColor(Vector(teamcolor.r / 100, teamcolor.g / 100, teamcolor.b / 100))
	else
		pl:SetPlayerColor(Vector(1, 1, 1))
	end

	if pl.SpawnPoint then
		local sp = pl.SpawnPoint
		if sp:IsValid() and sp:IsInWorld() and sp:GetTeamID() == pl:Team() then
			local pos = sp:GetPos()
			if util.TraceLine({start = pos, endpos = pos + Vector(0, 0, 102), mask = MASK_SOLID_BRUSHONLY}).Hit or util.TraceLine({start = pos + Vector(-20, 20, 0), endpos = pos + Vector(-20, 20, 102), mask = MASK_SOLID_BRUSHONLY}).Hit or util.TraceLine({start = pos + Vector(20,-20,0), endpos = pos + Vector(20,-20,102), mask = MASK_SOLID_BRUSHONLY}).Hit or util.TraceLine({start = pos + Vector(20,20,0), endpos = pos + Vector(20,20,102), mask = MASK_SOLID_BRUSHONLY}).Hit or util.TraceLine({start = pos + Vector(-20,-20,0), endpos = pos + Vector(-20,-20,102), mask = MASK_SOLID_BRUSHONLY}).Hit then
				pl:PrintMessage(HUD_PRINTCENTER, "Your bound spawn point was glitched in a wall.")
			else
				pl:SetPos(sp:GetPos() + Vector(0, 0, 32))
				pl:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
				timer.Create(tostring(pl).."teleportnocollide", 1, 1, function() NoColliding(pl) end)
			end
		else
			pl.SpawnPoint = nil
			pl:LMR(38)
		end
	end
end

if NDB then
	NDB.AddChatCommand("/resetspawn", function(sender, text)
		if sender:IsValid() and sender.SpawnPoint then
			sender.SpawnPoint = nil
			sender:PrintMessage(HUD_PRINTTALK, "You reset your spawnpoint.")
		end

		return ""
	end, "Resets your spawn point.")
end

function GM:PlayerCantChangeClass(pl)
	return nil
end

function GM:AllowPlayerPickup(pl, ent)
	return false
end

function GM:ScalePlayerDamage(pl, hitgroup, dmginfo)
	if hitgroup == HITGROUP_HEAD then
		dmginfo:ScaleDamage(1.5)
	end
end

function GM:ScaleNPCDamage(npc, hitgroup, dmginfo)
end

function GM:EntityTakeDamage(ent, dmginfo)
	local attacker = dmginfo:GetAttacker()
	local inflictor = dmginfo:GetInflictor()
	local amount = dmginfo:GetDamage()

	if attacker == inflictor and attacker:IsProjectile() and dmginfo:GetDamageType() == DMG_CRUSH then -- Fixes projectiles doing physics-based damage.
		dmginfo:SetDamage(0)
		dmginfo:ScaleDamage(0)
		return
	end

	if dmginfo:GetDamageType() == DMGTYPE_ENERGY then
		local waterlevel = ent:WaterLevel()
		if waterlevel > 0 then
			dmginfo:SetDamage(dmginfo:GetDamage() * (1 + waterlevel * 0.125))
		end
	end

	if inflictor.DamageMultiplierBuilding and ent.PHealth then
		dmginfo:SetDamage(dmginfo:GetDamage() * inflictor.DamageMultiplierBuilding)
	elseif inflictor.DamageMultiplierVehicle and ent.ScriptVehicle then
		dmginfo:SetDamage(dmginfo:GetDamage() * inflictor.DamageMultiplierVehicle)
	end

	if ent.ProcessDamage and not ent:IsWeapon() and not ent.m_IsStatus then -- Weapons and status entities only process damage for their owners.
		ent:ProcessDamage(attacker, inflictor, dmginfo)
	end
end

function GM:PlayerShouldTakeDamage(pl, attacker)
	if not pl:Alive() then return false end

	if pl:InVehicle() then
		local vehbase = pl:GetVehicle():GetVehicleParent()
		if vehbase.PHealth then
			if vehbase and vehbase:IsValid() and vehbase.PHealth > 0 and !vehbase.NoProtectSeats then return false end
		elseif vehbase:GetVHealth() then
			if vehbase and vehbase:IsValid() and vehbase:GetVHealth() > 0 and !vehbase.NoProtectSeats then return false end
		end
	end

	if attacker:IsPlayer() then
		return attacker == pl or attacker:Team() ~= pl:Team()
	elseif attacker:GetVehicleParent():IsValid() then
		return attacker:GetVehicleParent():GetTeamID() ~= pl:Team() or pl == attacker:GetVehicleParent().LastEject
	elseif attacker.ScriptVehicle then
		return attacker:Team() ~= pl:Team() or pl == attacker.LastEject or pl.LastVehicle == attacker
	elseif attacker:IsValid() then
		return attacker:GetTeamID() ~= pl:Team()
	end

	return true
end

function GM:WeaponEquip(weapon)
end

local function CCMakeProp(sender, command, arguments)
	if not sender:Alive() or sender:GetPlayerClassTable().Name ~= "Crafter" or ENDGAME or tonumber(arguments[1]) == nil then return end

	local index = tonumber(arguments[1])
	local materialtype = table.concat(arguments, " ", 2) or ""

	local proptab = PROPTYPES[index]
	if not proptab then return end

	local isInvul = GAMEMODE.GameType == "RCTF"

	if isInvul and proptab.Type ~= "prop_prop" then
		sender:PrintMessage(HUD_PRINTTALK, "Only things in the 'Props' category can be spawned in build mode during Retro Capture the Flag!")
		return
	end

	local rightgt = true
	if proptab.GameTypes then
		rightgt = false
		for _, gt in pairs(proptab.GameTypes) do
			if GAMEMODE.GameType == gt then
				rightgt = true
				break
			end
		end
	end
	if not rightgt then
		return
	end

	if GLOBALMAXPROPS <= team.GetProps(sender:Team()) then
		sender:LMR(3)
		return
	end

	local mysteam = sender:SteamID()
	if proptab.Max then
		local count = 0
		if proptab.Type == "prop_physics" then
			for _, ent in pairs(ents.FindByClass("prop_prop")) do
				if ent.Owner == mysteam and string.lower(ent:GetModel()) == proptab.Model then
					count = count + 1
					if proptab.Max <= count then
						sender:LMR(50)
						return
					end
				end
			end
		else
			for _, ent in pairs(ents.FindByClass(proptab.Type)) do
				if ent.Owner == mysteam then
					count = count + 1
					if proptab.Max <= count then
						sender:LMR(50)
						return
					end
				end
			end
		end
	end

	local myteam = sender:Team()
	if proptab.TeamMax then
		local count = 0
		if proptab.Type == "prop_physics" then
			for _, ent in pairs(ents.FindByClass("prop_prop")) do
				if ent:GetTeamID() == myteam and string.lower(ent:GetModel()) == proptab.Model then
					count = count + 1
					if proptab.Max <= count then
						sender:LMR(51)
						return
					end
				end
			end
		else
			for _, ent in pairs(ents.FindByClass(proptab.Type)) do
				if ent:GetTeamID() == myteam then
					count = count + 1
					if proptab.TeamMax <= count then
						sender:LMR(51)
						return
					end
				end
			end
		end
	end

	if proptab.CountsTowards then
		local mastergroup = proptab.CountsTowards
		local count = 0
		local personalcount = 0
		for _, ent in pairs(ents.GetAll()) do
			if ent.CountsTowards == mastergroup then
				if ent.Owner == mysteam then
					personalcount = personalcount + 1
				end
				if ent:GetTeamID() == myteam then
					count = count + 1
				end

				if proptab.TeamMax <= count then
					sender:LMR(51)
					return
				end

				if proptab.Max and proptab.Max <= personalcount then
					sender:LMR(50)
					return
				end
			end
		end
	end

	sender.NextPropSpawn = sender.NextPropSpawn or 0
	if CurTime() < sender.NextPropSpawn then return end
	sender.NextPropSpawn = CurTime() + 1

	local vStart = sender:GetShootPos()
	local vForward = sender:GetAimVector()

	local trace = {}
	trace.start = vStart
	trace.endpos = vStart + vForward * 2048
	trace.filter = sender

	local tr = util.TraceLine(trace)

	local typ = proptab.Type
	local ent = ents.Create(typ)
	if not ent:IsValid() then return end

	if proptab.Model then
		ent:SetModel(proptab.Model)
	end

	ent.m_IsBuilding = true

	local ang = sender:EyeAngles()
	ang.yaw = ang.yaw + 180
	ang.roll = 0
	ang.pitch = 0
	if 0.95 < tr.HitNormal.z then
		ent:SetAngles(sender:GetAngles())
	else
		local ang = tr.HitNormal:Angle()
		ang.Pitch = ang.Pitch + 90
		ent:SetAngles(ang)
	end

	ent:SetPos(tr.HitPos)

	if typ == "prop_dynamic_override" then
		ent:SetKeyValue("solid", "6")
	end
	ent:SetTeamID(sender:Team())
	ent.Owner = sender:SteamID()
	local hel = proptab.PHealth
	ent.NoWater = proptab.NoWater
	ent.NoRemove = proptab.NoRemove
	ent.ReverseTerritory = proptab.ReverseTerritory
	ent.CountsTowards = proptab.CountsTowards
	if tr.Entity:IsValid() then
		ent.BasedOn = tr.Entity
	end

	ent:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	ent:Spawn()
	ent:GetPhysicsObject():EnableCollisions(false)

	local entpos = tr.HitPos - ent:NearestPoint(tr.HitPos - tr.HitNormal * 512)
	entpos = tr.HitPos + entpos
	ent:SetPos(entpos)

	ent.SolidBase = proptab.SolidBase
	ent.ClusterPrevention = proptab.ClusterPrevention

	if isInvul then
		ent.MaterialType = RESISTANCE_INVULNERABLE
		ent.PHealth = 64000
		ent.MaxPHealth = 64000
		ent.OriginalPHealth = hel
	else
		if GAMEMODE.GameType == "HVST" and proptab.Group == "Resource Management" then
			ent.PHealth = math.Round(hel/3)
			ent.MaxPHealth = math.Round(hel/3)
		else
			ent.PHealth = hel
			ent.MaxPHealth = hel
		end

		local desiredresistance = GAMEMODE.StringToResistance[materialtype]
		if desiredresistance and proptab.UsableMaterials then
			for _, mat in pairs(proptab.UsableMaterials) do
				if desiredresistance == mat then
					ent.MaterialType = mat
					break
				end
			end
		end
	end

	ent.MaterialType = ent.MaterialType or proptab.DefaultResistance
	local mat = ent.MaterialType
	if mat then
		ent.ResistanceTable = RESISTANCE_TABLES[mat]
		if proptab.MaterialOverrides and proptab.MaterialOverrides[mat] then
			if proptab.MaterialOverrides[mat] ~= "" then
				ent:SetMaterial(proptab.MaterialOverrides[mat])
			end
		elseif GAMEMODE.ResistanceMaterials[mat] then
			ent:SetMaterial(GAMEMODE.ResistanceMaterials[mat])
		end
	end

	for i=1, #TEAMS_PLAYING do
		local flagpoint = team.TeamInfo[ TEAMS_PLAYING[i] ].FlagPoint
		if IsInBox(ent, flagpoint + Vector(-96, -96, -40), flagpoint + Vector(96, 96, 128)) then
			ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
			ent:Remove()
			sender:LMR(29)
			return
		end
	end

	if ent.SolidBase and (not tr.HitWorld or tr.HitSky or tr.HitNoDraw or tr.HitNormal.z < 0.9) then
		ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
		ent:Remove()
		sender:CenterPrint("That type of structure's base must be placed on solid ground.", "COLOR_WHITE")

		return
	end

	local spawns = ents.FindByClass("info_player*")
	table.Add(spawns, ents.FindByClass("prop_spawnpoint"))
	table.Add(spawns, ents.FindByClass("gmod_player_start"))
	for _, ent2 in pairs(spawns) do
		local ent2pos = ent2:GetPos()
		for _, ent3 in pairs(ents.FindInBox(ent2pos + Vector(-17, -17, 0), ent2pos + Vector(17, 17, 73))) do
			if ent3 == ent and ent2 ~= ent then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				ent:Remove()
				sender:CenterPrint("That would be blocking a spawn point.")
				return
			end
		end
	end

	if ent.NoWater and util.PointContents(entpos) == CONTENTS_WATER then
		ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
		ent:Remove()
		sender:PrintMessage(HUD_PRINTTALK, "That type of structure can't opperate in water or lava.")
		return
	end

	local trigs = ents.FindByClass("trigger_hurt*")
	table.Add(trigs, ents.FindByClass("func_disposer"))
	for _, brushent in pairs(trigs) do
		for _, findent in pairs(ents.FindInBox(brushent:LocalToWorld(brushent:OBBMins()), brushent:LocalToWorld(brushent:OBBMaxs()))) do
			if ent == findent then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				ent:Remove()
				sender:CenterPrint( "You can't place props in that area.")
				return
			end
		end
	end

	for _, brush in pairs(ents.FindByClass("func_nofreeze")) do
		if IsInBox(ent, brush:OBBMins(), brush:OBBMaxs()) then
			ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
			ent:Remove()
			sender:CenterPrint( "Invalid spot for placement! Probably blocking something important.")
			return
		end
	end

	if ent.ClusterPrevention then
		for _, ent2 in pairs(ents.FindInSphere(entpos, 256)) do
			if ent2 ~= ent and ent2.ClusterPrevention == ent.ClusterPrevention and ent2:GetTeamID() == ent:GetTeamID() then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				ent:Remove()
				sender:CenterPrint( "The structure is too close to other friendly structures of the same frequency and is creating interference.")
				return
			end
		end
	end

	if typ == "prop_physics" then
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then phys:EnableMotion(false) end
		ent:SetHealth(99999)
	end

	sender.NextGhost = sender.NextGhost or 0
	if CurTime() < sender.NextGhost then
		ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
		ent:Remove()
		sender:CenterPrint( "You must wait "..math.ceil(sender.NextGhost - CurTime()).." seconds before spawning another prop.")
		return
	end

	local core = team.TeamInfo[ent:GetTeamID()].Flag
	local desireddistance = entpos:Distance(team.TeamInfo[ent:GetTeamID()].FlagPoint)

	if ent.ReverseTerritory then
		for _, teamid in pairs(TEAMS_PLAYING) do
			if desireddistance < entpos:Distance(team.TeamInfo[teamid].FlagPoint) then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				ent:Remove()
				sender:CenterPrint( "Can only be placed in enemy territory.")
				return
			end
		end
	end

	for _, teamid in pairs(TEAMS_PLAYING) do
		if teamid ~= sender:Team() then
			local point = team.TeamInfo[teamid].FlagPoint
			if ent:NearestPoint(point):Distance(point) < BUILD_DISTANCE_TO_ENEMY then
				ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
				ent:Remove()
				sender:PrintMessage(HUD_PRINTTALK, "Too close to an enemy home.")
				return
			end
		end
	end

	ent:SetColor(Color(0, 0, 0, 90))
	ent.Destroyed = true
	ent.PHealth = 0

	if ent.NoWater and 0 < ent:WaterLevel() then
		ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
		ent:Remove()
		sender:PrintMessage(HUD_PRINTCENTER, "That type of prop can't be placed in liquid.")
		return
	end

	if proptab.Callback then
		if proptab.Callback(sender, ent) then
			ent:EmitSound("npc/roller/mine/rmine_blip3.wav")
			ent:Remove()
			return
		end
	end

	team.AddProps(ent:GetTeamID(), 1)
	table.insert(ALLPROPS, ent)

	local effectdata = EffectData()
		effectdata:SetOrigin(ent:GetPos())
		effectdata:SetEntity(ent)
	util.Effect("propenter", effectdata)

	sender.NextGhost = CurTime() + CRAFTER_RESPAWN
	local steamid = sender:SteamID()
	for _, ent2 in pairs(ents.GetAll()) do
		if ent2 ~= ent and ent2.Destroyed and ent2.Owner == steamid then
			ent2:Remove()
			team.AddProps(ent2:GetTeamID(), -1)
		end
	end

	gamemode.Call("EvaluatePower")
end
concommand.Add("_tp_craftobject", CCMakeProp)

concommand.Add("CCChangeClass", function(sender, command, arguments)
	if not sender:IsValid() or sender:Team() == TEAM_SPECTATOR then return end
	sender.NextClassChange = sender.NextClassChange or 0
	if CurTime() < sender.NextClassChange then return end
	sender.NextClassChange = CurTime() + 0.5
	if GAMEMODE:PlayerCantChangeClass(sender) then return end
	if not arguments[1] then return end

	local class = tonumber(arguments[1])
	if not class or not CLASSES[class] or class == sender:GetPlayerClass() or CLASSES[class].Disabled then return end

	if GAMEMODE.DisabledClasses[class] then sender:PrintMessage(HUD_PRINTTALK, "That class is disabled on this map.") return end

	if CLASSES[class].Restrictions then
		for _, restriction in pairs(CLASSES[class].Restrictions) do
			if restriction == GAMEMODE.GameType then sender:PrintMessage(HUD_PRINTTALK, "That class is disabled on this gametype.") return end
		end
	end

	if NDB then
		if CLASSES[class].AwardsRequired then
			for _, award in pairs(CLASSES[class].AwardsRequired) do
				if not sender:HasAward(award) then
					sender:PrintMessage(HUD_PRINTTALK, CLASSES[class].Name.." requires the award: "..string.gsub(award, "_", " ")..", which you do not have.")
					return
				end
			end
		end
	end

	GAMEMODE:ChangeClass(sender, command, arguments, class)
end)

function GM:ChangeClass(sender, command, arguments, class)
	if sender:GetPlayerClass() < 1 then
		sender:SetPlayerClass(class)

		if GAMESTART <= CurTime() then
			sender:Spawn()
		end

		sender:SendLua("surface.PlaySound(\"npc/roller/remote_yes.wav\")")
	else
		local instantrespawn = true

		if not sender:Alive() then instantrespawn = false end

		for _, pl in pairs(player.GetAll()) do
			if pl.LastAttacker == sender and CurTime() < pl.LastAttacked + 10 then
				instantrespawn = false
				break
			end
		end

		if sender:IsCarrying() or sender:InVehicle() or instantrespawn and sender.LastAttacked and CurTime() < sender.LastAttacked + 10 then
			instantrespawn = false
		end

		if instantrespawn then
			local senderteam = sender:Team()
			for _, pl in pairs(ents.FindInSphere(sender:GetPos(), 1000)) do
				if pl:IsPlayer() and pl:Alive() and pl ~= sender and pl:Team() ~= senderteam and pl:Team() ~= TEAM_SPECTATOR then
					instantrespawn = false
					break
				end
			end
		end

		if instantrespawn then
			sender:PrintMessage(HUD_PRINTTALK, "You are now a "..CLASSES[class].Name..".")

			sender.DeathClass = class
			sender:ForceRespawn()

			for _, ent in pairs(ents.FindByClass("projectile_pixie")) do
				if ent:GetOwner() == sender then
					ent:Remove()
				end
			end
			sender:SendLua("surface.PlaySound(\"npc/roller/remote_yes.wav\")")
		else
			if sender:Alive() then
				sender:PrintMessage(HUD_PRINTTALK, "You have recently been in combat or there are nearby enemies. You will respawn as a "..CLASSES[class].Name..".")
			else
				sender:PrintMessage(HUD_PRINTTALK, "You will spawn as a "..CLASSES[class].Name..".")
			end
			sender.DeathClass = class
		end
	end
end

-- TODO: Allow spawning of vehicles at different angles. Base on the GetForward() of the player.
concommand.Add("CreateVehicle", function(sender, command, arguments)
	if not sender:IsValid() or not sender:Alive() then return end

	local vehicleclass = table.concat(arguments, " ")
	if not vehicleclass then return end

	local tab = GAMEMODE:GetVehicles()[vehicleclass]
	if not tab then return end

	if NOVEHICLES then
		sender:PrintMessage(HUD_PRINTCENTER, "Vehicles are disabled in this map.")
		return
	end

	if NOAIRVEHICLES and tab.AirVehicle then
		sender:PrintMessage(HUD_PRINTCENTER, "Air Vehicles are disabled in this map.")
		return
	end

	if NOGROUNDVEHICLES and tab.GroundVehicle then
		sender:PrintMessage(HUD_PRINTCENTER, "Ground Vehicles are disabled in this map.")
		return
	end

	if NOHOVERVEHICLES and tab.HoverVehicle then
		sender:PrintMessage(HUD_PRINTCENTER, "Hover Vehicles are disabled in this map.")
		return
	end

	local pad
	local senderteam = sender:Team()
	for _, ent in pairs(ents.FindByClass("prop_vehiclepad")) do
		local teamid = ent:GetTeamID()
		if (teamid == 0 or teamid == senderteam) and ent:NearestPoint(sender:GetPos()):Distance(sender:GetPos()) < 200 then
			pad = ent
			break
		end
	end

	if not pad then
		return sender:PrintMessage(HUD_PRINTTALK, "You are too far from a vehicle pad to spawn it.")
	end

	local padpos = pad:GetPos()

	local count = 0
	for _, ent in pairs(ents.FindByClass(vehicleclass)) do
		if ent:Team() == senderteam then
			count = count + 1
		end
	end

	if tab.Stocks <= count then
		return sender:PrintMessage(HUD_PRINTTALK, "Your team has too many of these vehicles already.")
	end

	for _, ent in pairs(ents.FindByClass("vehicle_tp*")) do
		if ent.Deployer and ent.Deployer == sender and ent:Team() == senderteam then
			ent.Destroy = 0
		end
	end

	local spawnpos = padpos + (tab.CreationOffset or Vector(0, 0, 32))

	for _, ent in pairs(ents.FindInSphere(spawnpos, 128)) do
		if string.find(ent:GetClass(), "vehicle_tp") then
			return sender:PrintMessage(HUD_PRINTTALK, "There is a vehicle blocking the pad.")
		end
	end

	if sender.VehicleTimers[tab.Name] and CurTime() < sender.VehicleTimers[tab.Name] then
		sender:PrintMessage(HUD_PRINTTALK, "You must wait "..math.ceil(sender.VehicleTimers[tab.Name] - CurTime()).." more seconds before spawning another "..tab.Name..".")
		return
	end

	if pad.ManaStorage < tab.ManaToSpawn then
		sender:PrintMessage(HUD_PRINTTALK, "The vehicle pad does not have enough Mana to spawn that vehicle.")
		return
	end

	local veh = ents.Create(vehicleclass)
	if veh:IsValid() then
		veh:SetPos(spawnpos)
		veh.Deployer = sender
		veh.DeployTime = CurTime()
		veh:Spawn()
		if veh.CreateChildren then veh:CreateChildren() end
		veh:SetTeamID(senderteam)
		veh.DieTime = CurTime() + VEHICLE_INITIALTIME

		pad.ManaStorage = pad.ManaStorage - tab.ManaToSpawn

		local effectdata = EffectData()
			effectdata:SetOrigin(veh:GetPos())
			effectdata:SetEntity(veh)
		util.Effect("SpawnEffect", effectdata)
		util.Effect("building_spawn", effectdata)

		sender.VehicleTimers[tab.Name] = CurTime() + tab.RespawnTime
		umsg.Start("RecVehTimer", sender)
			umsg.String(tab.Name)
			umsg.Float(sender.VehicleTimers[tab.Name])
		umsg.End()

		sender:PrintMessage(HUD_PRINTCENTER, tab.Name.." created!")
	end
end)

concommand.Add("ReqInfo", function(sender, command, arguments)
	if CurTime() < sender.NextReqInfo then return end
	sender.NextReqInfo = CurTime() + 0.6
	local ent = Entity(tonumber(arguments[1]) or 1)
	if ent.Info then
		local str = ent:Info(sender)
		if str and str ~= sender.LastInfo[ent] then
			sender.LastInfo[ent] = str
			umsg.Start("RecInfo", sender)
				umsg.Entity(ent)
				umsg.String(str)
			umsg.End()
		end
	end
end)

concommand.Add("requestgametype", function(sender, command, arguments)
	sender:SendLua("GAMEMODE:"..GAMEMODE.GameType.."Initialize()")
end)
