GM.Name = "Retro TeamPlay"
GM.Author = "William \"JetBoom\" Moodhe"
GM.Email = "jetboom@yahoo.com"
GM.Website = "http://www.noxiousnet.com"
GM.Credits = {
	{"William \"JetBoom\" Moodhe", "jetboom@yahoo.com", "Project Lead / Programmer"},
	{"ptown2", "xptown2x@gmail.com", "GMOD13 Conversion / Programmer"},
	{"ZC0M", "zcom403@gmail.com", "Re-code and general bug fixing."},
	{"Westwood Studios", "-", "Ideas, sounds, concepts"},
	{"Kevtheman111", "-", "Sound faceposer-syncing"},
	{"Dynamix", "http://www.dynamix.com", "Some explosion sounds"},
	{"Skirdge", "-", "Various content additions and bugfixes."},
	{"Sam Za Nemesis", "samuelgames@gmail.com", "Various content additions and bugfixes."}
}

include("buffthefps.lua")
include("nixthelag.lua")

include("nox_teams.lua")

include("obj_entity_extend.lua")
include("obj_player_extend.lua")

include("sh_globals.lua")
include("sh_props.lua")
include("sh_register.lua")
include("sh_animations.lua")
include("sh_voicesets.lua")
include("sh_colors.lua")
include("sh_luaanimations.lua")

include("modules/sh_statushook.lua")

GM.GameType = "CTF"
GM.FlagEntity = "flag"
GM.DisabledSpells = {}
GM.DisabledClasses = {}

function GetSWEPClassName(foldername)
	return string.match(foldername, ".-[/\\](.+)")
end

function BulletCallback(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValid() then
		ent:TakeSpecialDamage(dmginfo:GetDamage(), DMGTYPE_PIERCING, attacker, dmginfo:GetInflictor())
		return {damage = false, effects = true}
	end
end

function GM:PlayerFootstep(pl, vPos, iFoot, strSoundName, fVolume, pFilter)
end

function GM:SetPropTypeNames()
	for k, v in pairs(PROPTYPES) do
		if v.Type ~= "prop_prop" then
			local stored = scripted_ents.GetStored(v.Type)
			if stored then
				stored.t.Name = v.Name
			end
		end
	end
end

function GM:PrecacheSounds()
	util.PrecacheSound("weapons/physcannon/physcannon_charge.wav")
	util.PrecacheSound("npc/roller/mine/rmine_blip3.wav")
	util.PrecacheSound("npc/roller/mine/rmine_predetonate.wav")
	util.PrecacheSound("npc/manhack/bat_away.wav")
	
	for _, filename in pairs(file.Find("sound/nox/*.wav", "MOD")) do
		util.PrecacheSound("nox/"..filename)
	end
	for _, filename in pairs(file.Find("sound/nox/*.mp3", "MOD")) do
		util.PrecacheSound("nox/"..filename)
	end
end

function GM:ParseParticleManifests()
	game.AddParticles("particles/zolt.pcf")
	game.AddParticles("particles/nox.pcf")
	game.AddParticles("particles/noxa.pcf")
end


function GM:GetVehicles()
	if not self.CachedVehicles then
		local cached = {}

		for classname in pairs(scripted_ents.GetList()) do
			local stored = scripted_ents.GetStored(classname)
			if stored and stored.t.ScriptVehicle and not stored.t.Hidden and not string.find(classname, "_base", 1, true) then
				cached[classname] = stored.t
			end
		end

		self.CachedVehicles = cached
	end

	return self.CachedVehicles
end

--[[function GM:ShouldCollide(enta, entb)
	if enta.IsProjectile then
		if entb:IsPlayer() then return enta:GetTeamID() ~= entb:Team() end
		if entb.IsProjectile then return enta:GetTeamID() ~= entb:GetTeamID() or entb:GetTeamID() == nil end
	end

	if entb.IsProjectile then
		if enta:IsPlayer() then return entb:GetTeamID() ~= enta:Team() end
		if enta.IsProjectile then return entb:GetTeamID() ~= enta:GetTeamID() or enta:GetTeamID() == nil end
	end
end]]

local function spellsort(a, b)
	return string.lower(Spells[a].Name) < string.lower(Spells[b].Name)
end
function GM:SetUpCastableSpells()
	for classindex, classtab in pairs(CLASSES) do
		local castable = {}

		for spellindex, spelltab in ipairs(Spells) do		
			if spelltab.CLASSES[classindex] then
				table.insert(castable, spellindex)
			end
		end

		table.sort(castable, spellsort)
		classtab.CastableSpells = castable
	end
end

function GM:GetRagdollEyes(pl)
	local Ragdoll = pl:GetRagdollEntity()
	if not Ragdoll then return end

	local att = Ragdoll:GetAttachment(Ragdoll:LookupAttachment("eyes"))
	if att then
		att.Pos = att.Pos + att.Ang:Forward() * -1
		att.Ang = att.Ang

		return att.Pos, att.Ang
	end
end

function GM:PlayerStepSoundTime(pl, iType, bWalking)
	if iType == STEPSOUNDTIME_NORMAL or iType == STEPSOUNDTIME_WATER_FOOT then
		return math.max(520 - pl:GetVelocity():Length(), 200)
	end

	if iType == STEPSOUNDTIME_ON_LADDER then
		return 500
	end

	if iType == STEPSOUNDTIME_WATER_KNEE then
		return 650
	end

	return 350
end

function GM:SetPlayerSpeed(pl, speed)
	pl:SetWalkSpeed(speed)
	pl:SetRunSpeed(speed)
	pl:SetMaxSpeed(speed)

	if speed == 1 or pl.HealRing or pl.ChargeFireBall then
		pl:SetJumpPower(0)
	else
		pl:SetJumpPower(180)
	end
end

function GM:Move(pl, move)
	if hook.Run("PreMove", pl, move) then return end

	if pl.GrappleBeam and pl.GrappleBeam:IsValid() and pl.GrappleBeam:GetSkin() == 1 then
		local grapplepos = pl.GrappleBeam:GetPos()
		local plpos = pl:GetPos()
		if 24 < plpos:Distance(grapplepos) then
			move:SetVelocity(700 * (grapplepos - plpos):GetNormal())
		end
	elseif pl.HealRing or pl.ChargeFireBall then
		move:SetMaxSpeed(0)
		move:SetMaxClientSpeed(0)
	end

	if move:GetForwardSpeed() < 0 then
		move:SetMaxSpeed(move:GetMaxSpeed() * 0.65)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.65)
	elseif move:GetForwardSpeed() == 0 then
		move:SetMaxSpeed(move:GetMaxSpeed() * 0.85)
		move:SetMaxClientSpeed(move:GetMaxClientSpeed() * 0.85)
	end

	if pl:Crouching() and pl:OnGround() then
		move:SetMaxSpeed(math.min(move:GetMaxSpeed(), 110))
		move:SetMaxClientSpeed(math.min(move:GetMaxClientSpeed(), 110))
	end

	if hook.Run("PostMove", pl, move) then
		return true
	end
end

function GM:GetFallDamage(pl, speed)
	return speed * 0.02
end

--[[function GM:PlayerTraceAttack(ply, dmginfo, dir, trace)
	return false
end]]

function GM:PhysgunPickup(pl, ent)
	return false
end

function GM:PhysgunDrop(pl, ent)
end

function GM:SetupMove(pl, move)
end

function GM:FinishMove(pl, move)
end

function GM:ContextScreenClick(aimvec, mousecode, pressed, ply)
end

function GM:GetGameDescription()
	return self.Name
end

function IsVisible(posa, posb)
	if posa == posb then return true end
	return not util.TraceLine({start = posa, endpos = posb, mask = COLLISION_GROUP_DEBRIS}).HitWorld
end

function IsVisible2(ent, ent2)
	return ent:VisibleVec(ent2:EyePos()) or ent2:VisibleVec(ent:EyePos())
end

function IsVisible3(posa, posb)
	return not util.TraceLine({start = posa, endpos = posb, filter = player.GetAll()}).HitWorld
end

function IsVisible4(posa, posb, _filter)
	local tr = util.TraceLine({start = posa, endpos = posb, filter = _filter, mask = COLLISION_GROUP_DEBRIS})

	if tr.HitWorld then return false end

	local trent = tr.Entity
	if trent:IsValid() then
		return not string.find(trent:GetClass(), "prop_")
	end

	return true
end

function MeleeVisible(posa, posb, _filter)
	return not util.TraceLine({start = posa, endpos = posb, filter = _filter}).Hit
end

function TrueVisible(posa, posb)
	local filt = ents.FindByClass("projectile_*")
	filt = table.Add(filt, ents.FindByClass("npc_*"))
	filt = table.Add(filt, ents.FindByClass("prop_physics*"))
	filt = table.Add(filt, ents.FindByClass("prop_vehicle*"))
	filt = table.Add(filt, ents.FindByClass("obelisk"))
	filt = table.Add(filt, ents.FindByClass("netherbomb"))
	filt = table.Add(filt, ents.FindByClass("vehicle*"))
	if GAMEMODE.FlagEntity then
		filt = table.Add(filt, ents.FindByClass(GAMEMODE.FlagEntity))
	end
	filt = table.Add(filt, player.GetAll())

	return not util.TraceLine({start = posa, endpos = posb, filter = filt}).Hit
end

-- Where should the entity at posa fire its projectile, travelling at speeda, to hit an entity with linear velocity velb currently at posb?
-- We want |posb + velb * t - posa| = speeda * t where t is time. After solving for t and monkeying around with the math here's the result.
function PredictedCollision(posa, speeda, posb, velb)
	local vec = posb - posa
	local a = velb:DotProduct(velb) - speeda * speeda
	local b = 2 * vec:DotProduct(velb)
	local c = vec:DotProduct(vec)

	local disc = b*b - 4*a*c
	if disc < 0 then return false end -- no collision possible
	disc = math.sqrt(disc)
	
	local t1 = (-1 * b + disc)/(2 * a)
	local t2 = (-1 * b - disc)/(2 * a)
	
	if t1 < t2 and t1 >= 0 then 
		return posb + velb * t1
	elseif t2 >= 0 then
		return posb + velb * t2
	end
end

function IsGlitched(ent, pl, passive)
	local filtertab = ents.GetAll()
	for i=1, #filtertab do
		local ent = filtertab[i]

		if ent and ent:IsValid() and ent:GetClass() == "func_wall_toggle" then
			table.remove(filtertab, i)
			i = i - 1
		end
	end

	if util.TraceLine({start = pl:GetShootPos(), endpos = ent:GetPos(), mask=MASK_SOLID_BRUSHONLY}).Hit then
		if pl and pl.PrintMessage then
			pl:CenterPrint( "You cannot place props inside walls.")
		end
		return true
	end

	if util.TraceLine({start = pl:GetShootPos(), endpos = ent:GetPos(), mask=MASK_SOLID_BRUSHONLY}).Hit then
		if pl and pl.PrintMessage then
			pl:CenterPrint( "You cannot place props inside walls.")
		end
		return true
	end

	if util.TraceLine({start = pl:GetShootPos(), endpos = ent:GetPos(), filter=filtertab}).Hit then
		if pl and pl.PrintMessage then
			pl:CenterPrint( "You cannot place props inside the team separator wall.")
		end
		return true
	end

	local trigs = ents.FindByClass("trigger_hurt")
	table.Add(trigs, ents.FindByClass("func_disposer"))
	for _, brushent in pairs(trigs) do
		for _, findent in pairs(ents.FindInBox(brushent:LocalToWorld(brushent:OBBMins()), brushent:LocalToWorld(brushent:OBBMaxs()))) do
			if ent == findent then
				if pl and pl.PrintMessage then
					pl:CenterPrint( "You can not place props in that area.")
				end
				return true
			end
		end
	end

	return false
end

function ToMinutesSeconds(TimeInSeconds)
	local iMinutes = math.floor(TimeInSeconds / 60.0)
	return string.format("%0d:%02d", iMinutes, math.floor(TimeInSeconds - iMinutes * 60))
end

function util.ToMinutesSecondsMilliseconds(seconds)
	local minutes = math.floor(seconds / 60)
	seconds = seconds - minutes * 60

	local milliseconds = math.floor(seconds % 1 * 100)

    return string.format("%02d:%02d.%02d", minutes, math.floor(seconds), milliseconds)
end

function timer.SimpleEx(delay, action, ...)
	if ... == nil then
		timer.Simple(delay, action)
	else
		local a, b, c, d, e, f, g, h, i, j, k = ...
		timer.Simple(delay, function() action(a, b, c, d, e, f, g, h, i, j, k) end)
	end
end

function timer.CreateEx(timername, delay, repeats, action, ...)
	if ... == nil then
		timer.Create(timername, delay, repeats, action)
	else
		local a, b, c, d, e, f, g, h, i, j, k = ...
		timer.Create(timername, delay, repeats, function() action(a, b, c, d, e, f, g, h, i, j, k) end)
	end
end
