local function ForwardSpell(func, pl, spellid)
	local spell = Spells[spellid]
	if pl:IsValid() and pl:Alive() then
		if pl:StatusHook("PlayerCantCastSpell", pl, spellid) then return end

		local mana = pl:GetMana()

		if mana < spell.Mana then
			pl:SendLua("insma()")
			return
		end

		if func and not func(pl) then
			if spell.Hostile then
				pl:RemoveInvisibility()
			end

			pl:SetMana(mana - spell.Mana, true)
		end
	end
end

local function Cast(sender, command, arguments)
	if not arguments[1] then return end

	if not sender:Alive() then sender:LM(74) return end
	if sender:IsFrozen() then sender:LM(27) return end
	if CurTime() < sender.NextSpell then return end

	local spellid = NameToSpellLower[string.lower(table.concat(arguments, " "))]

	if GAMEMODE.DisabledSpells[spellid] then
		sender:LMR(54)
		return
	end

	if not spellid then
		sender:LMR(23)
		return
	end

	if not GAMEMODE:PlayerCanCast(sender, spellid) then
		return
	end

	local spelltab = Spells[spellid]

	if not spelltab.CLASSES[sender:GetPlayerClass()] then
		sender:LMR(22, spelltab.Name)
		return
	end

	if sender:StatusHook("PlayerCantCastSpell", sender, spellid) then return end

	if spelltab.Ability then
		sender.AbilityDelays[spellid] = sender.AbilityDelays[spellid] or -100
		if sender.AbilityDelays[spellid] <= CurTime() then
			if not SpellFunctions[spellid](sender) then
				local delay = spelltab.Delay
				sender.AbilityDelays[spellid] = CurTime() + delay
				sender:DI(spellid, delay)
				if spelltab.Hostile then
					sender:RemoveInvisibility()
				end
			end
		else
			sender:LM(26)
		end
	elseif sender:GetMana() < spelltab.Mana then
		sender:SendLua("insma()")
	else

		timer.Simple(spelltab.Delay, function() ForwardSpell(SpellFunctions[spellid], sender, spellid) end)
		umsg.Start("SI")
			umsg.Entity(sender)
			umsg.Short(spellid)
		umsg.End()
		sender.NextSpell = CurTime() + spelltab.Delay + 0.01
	end
end
concommand.Add("cast", Cast)

function spells.FireBolt(pl)
	local ent = ents.Create("projectile_firebolt")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceCenter(pl:GetAimVector() * 700)
		end
	end
end

function spells.IceSpear(pl)
	local ent = ents.Create("projectile_icespear")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:SetAngles(pl:GetAimVector():Angle() + Angle(0,0,90))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 1200)
		end
	end
end

function spells.Flare(pl)
	local ent = ents.Create("projectile_flare")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		local c = team.GetColor(pl:GetTeamID()) or color_white
		ent:SetColor(Color(c.r, c.g, c.b, 255))
		ent:SetPos(pl:GetShootPos())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 600)
		end
	end
end

function spells.ElectronBall(pl)
	local ent = ents.Create("projectile_electronball")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 800)
		end
	end
end

function spells.FlameSpiral(pl)
	local ent = ents.Create("projectile_flamespiral")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent.ProjectileHeading = pl:GetAimVector()
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceCenter(ent.ProjectileHeading * 250)
		end
	end
end

function spells.Sparkler(pl)
	local ent = ents.Create("projectile_sparkler")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		local teamid = pl:GetTeamID()
		ent:SetTeamID(teamid)
		local col = team.GetColor(teamid) or color_white
		ent:SetColor(Color(col.r, col.g, col.b, 255))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 1000)
		end
	end
end

function spells.Typhoon(pl)
	local tr = util.TraceLine({start = pl:GetPos() + Vector(0,0,16), endpos = pl:GetPos() + Vector(0,0,2000), mask=MASK_SOLID_BRUSHONLY})

	if tr.HitWorld and not tr.HitSky then
		pl:LMR(53)
		return true
	end

	pl:GiveStatus("typhoon", 5)
end

function spells.MagicArrow(pl)
	local ent = ents.Create("projectile_magicarrow")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:GetTeamID())
		ent:SetPos(pl:GetShootPos())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 1350)
		end
	end
end

function spells.StarBurst(pl)
	local ent = ents.Create("projectile_starburst")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent.Target = pl:GetEyeTrace().HitPos
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(Vector(0,0,900))
		end
	end
end

function spells.FireBomb(pl)
	local ent = ents.Create("projectile_firebomb")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			local aimvec = pl:GetAimVector()
			aimvec.z = math.max(aimvec.z, 0.35)
			aimvec = aimvec:GetNormal()
			phys:SetVelocityInstantaneous(aimvec * 850)
		end
		util.SpriteTrail(ent, 0, color_white, false, 48, 32, 1, 0.025, "Effects/fire_cloud2.vmt")

		pl:CustomGesture(ACT_SIGNAL_FORWARD)
	end
end

function spells.BlackHoleSun(pl)
	local ent = ents.Create("projectile_blackholesun")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector():GetNormal() * 500)
		end

		pl:CustomGesture(ACT_SIGNAL_FORWARD)
	end
end

function BurnTimer(fire, tn, damage, radius)
	if not fire:IsValid() then timer.Destroy(tn) return end

	local owner = fire:GetOwner()
	if not owner:IsValid() then
		owner = fire
	end

	local pos = fire:GetPos()

	for _, ent in pairs(ents.FindInSphere(pos, radius)) do
		if ent:IsPlayer() or ent:IsNPC() then
			ent:TakeSpecialDamage(damage, DMGTYPE_FIRE, owner, DUMMY_BURN, pos)
		end
	end
end

function spells.Burn(pl)
	local ent = ents.Create("projectile_burn")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:Team())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 2000)
		end
	end
end

function spells.StaticBall(pl)
	local count = 0
	for _, ent in pairs(ents.FindByClass("projectile_staticball")) do
		if ent:GetOwner() == pl then
			count = count + 1
		end
	end

	if count >= 4 then
		pl:LMR(36)
		return true
	end

	local ent = ents.Create("projectile_staticball")
	if ent:IsValid() then
		ent:SetPos(pl:GetShootPos())
		ent:SetOwner(pl)
		ent:Spawn()
		ent:SetTeamID(pl:Team())
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(true)
			phys:EnableDrag(false)
			phys:EnableGravity(false)
			phys:SetBuoyancyRatio(0)
			phys:SetMass(5)
			phys:Wake()
			--phys:ApplyForceCenter(pl:GetAimVector() * 4000)
		end

		pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
	end
end

local function CreateProtrusionSpike(pl, pos, teamid)
	local ent = ents.Create("projectile_protrusionspike")

	if ent:IsValid() then
		ent:SetPos(pos)
		if pl:IsValid() then
			ent:SetOwner(pl)
		end
		ent:SetTeamID(teamid)
		ent:Spawn()
	end

	local _filter = player.GetAll()
	table.Add(_filter, ents.FindByClass("projectile_protrusionspike"))
	local tr2 = util.TraceLine({start = pos, endpos = pos + Vector(0, 0, 1000), filter=_filter, mask = MASK_SOLID})
	local tr = util.TraceLine({start = tr2.HitPos, endpos = tr2.HitPos + Vector(0, 0, -10000), filter=_filter, mask = MASK_WATER + MASK_SOLID})
	if tr.Hit and tr.MatType == 83 then
		local ent2 = ents.Create("iceburg")
		if ent2:IsValid() then
			ent2:SetPos(tr.HitPos + Vector(0,0,-48))
			ent2:Spawn()
			for _, pl in pairs(ents.FindInSphere(tr.HitPos,40)) do
				if pl:IsPlayer() then
					ent2:Remove()
				end
			end
		end
	end
end

function spells.Protrusion(pl)
	local vStart = pl:GetPos() + Vector(0,0,32)
	local vForward = pl:GetAngles():Forward()
	local _filter = player.GetAll()
	local teamid = pl:GetTeamID()
	table.Add(_filter, ents.FindByClass("projectile_protrusionspike"))

	if pl:KeyDown(IN_USE) then
		local tr = util.TraceLine({start = vStart, endpos = 56 * vForward + vStart, filter = _filter, mask = MASK_SOLID})
		local tr2 = util.TraceLine({start = tr.HitPos, endpos = tr.HitPos + Vector(0, 0, -100), filter = _filter, mask = MASK_SOLID + MASK_WATER})
		local ent = ents.Create("projectile_protrusionlarge")

		if tr2.Hit then
			if ent:IsValid() then
				ent:SetPos(tr2.HitPos)
				if pl:IsValid() then
					ent:SetOwner(pl)
				end
				ent:SetTeamID(teamid)
				ent:Spawn()
				pl:CustomGesture(ACT_SIGNAL_HALT)
			end
		else
			return true
		end
	else
		local tocreate = {}

		local dist = 32
		for i=1, 8 do
			local tr = util.TraceLine({start = vStart, endpos = dist * vForward + vStart, filter = _filter, mask = MASK_SOLID})
			local tr2 = util.TraceLine({start = tr.HitPos, endpos = tr.HitPos + Vector(0, 0, -100), filter = _filter, mask = MASK_SOLID + MASK_WATER})

			if tr2.Hit then
				dist = dist + 64
				table.insert(tocreate, tr2.HitPos)
			end

			if tr.Hit then break end
		end

		if #tocreate <= 0 then return true end

		pl:CustomGesture(ACT_SIGNAL_FORWARD)

		for i, pos in ipairs(tocreate) do
			timer.Simple(i * 0.06, function() CreateProtrusionSpike( pl, pos, teamid) end)
		end
	end
end

function spells.AirHike(pl)
	if pl:IsCarrying() or pl:IsAnchored() then return true end

	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + Vector(0,0,2))
		effectdata:SetScale(40)
		effectdata:SetMagnitude(1.5)
		effectdata:SetRadius(40)
		effectdata:SetNormal(Vector(0,0,0))
	util.Effect("ThumperDust", effectdata)

	local vVel = pl:GetVelocity()
	pl:SetLocalVelocity(Vector(vVel.x, vVel.y, 400))
end

function spells.ToxicCloud(pl)
	local ent = ents.Create("projectile_toxiccloud")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:GetTeamID())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 500)
		end
	end
	pl:CustomGesture(ACT_SIGNAL_FORWARD)
end

function spells.MissilesOfMagic(pl)
	local count = 0
	for _, ent in pairs(ents.FindByClass("projectile_magicmissile")) do
		if not ent.DontCount and ent:GetOwner() and ent:GetOwner() == pl then
			count = count + 1
		end
	end
	if 8 <= count then
		pl:LMR(36)
		return true
	end

	pl:EmitSound("nox/missilesofmagic.ogg")

	local created = 0
	for i=1, 8 do
		if 4 <= created or 8 <= count then return end

		local aimvec = pl:EyeAngles()
		aimvec.yaw = aimvec.yaw + math.Rand(-15, 15)
		aimvec.pitch = aimvec.pitch + math.Rand(-5, 5)
		aimvec = aimvec:Forward()
		local ent = ents.Create("projectile_magicmissile")
		if ent:IsValid() then
			ent:SetPos(pl:GetShootPos())
			ent:SetOwner(pl)
			ent.Infravision = pl:GetStatus("infravision")
			ent:Spawn()
			ent:SetTeamID(pl:Team())
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:ApplyForceCenter(aimvec * 480)
			end
			created = created + 1
			count = count + 1
		end
	end
end

function GenericHoming(pl, effect, friendly)
	local ent = ents.Create("projectile_generichoming")
	if ent:IsValid() then
		ent:SetPos(pl:GetShootPos())
		ent:SetOwner(pl)
		if friendly then
			ent.Friendly = true
			ent:SetSkin(1)
		end
		ent:Spawn()
		ent.EffectType = effect
		ent:SetTeamID(pl:Team())

		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceCenter(pl:GetAimVector() * 750)
		end

		ent.Infravision = pl:GetStatus("infravision")

		return ent
	end
end

function spells.LesserHeal(pl, override, owner)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "LesserHeal", true)
		return
	end

	local ent = pl:GiveStatus("lesserheal", 3.5)
	ent.Healer = owner or pl
end

local function GreaterHealing(pl, target, health, uid, targetuid)
	if pl:IsValid() and not (pl.CounterSpelled and CurTime() < pl.CounterSpelled) and pl:Alive() and pl:GetVelocity():Length() < 20 and health <= pl:Health() and target:IsValid() and target:Alive() and 4 < pl:GetMana() and target:GetPos():Distance(pl:GetPos()) <= 256 and target:Health() < target:GetMaxHealth() and TrueVisible(pl:EyePos(), target:NearestPoint(pl:EyePos())) then
		pl:SetMana(math.max(pl:GetMana() - 4, 0), true)
		GAMEMODE:PlayerHeal(target, pl, 4)
		if pl ~= target then
			local effectdata = EffectData()
				effectdata:SetOrigin(pl:GetPos())
				effectdata:SetStart(target:GetPos())
			util.Effect("greaterheal", effectdata)
		end
		timer.Create(uid.."GreaterHealing"..targetuid, 0.2, 0, function() GreaterHealing(pl, target, pl:Health(), uid, targetuid) end)
		return
	end
	timer.Destroy(uid.."GreaterHealing"..targetuid)
end

-- TODO: Move to status_. GetOwner can be the caster while Skin is the entindex of the target (if any).
-- TODO: Effect for healing self.
function spells.GreaterHeal(pl)
	pl:StopIfOnGround()

	if pl:KeyDown(IN_USE) then
		local hit = NULL
		local tr = pl:TraceLine(200)
		local trent = tr.Entity
		if trent.SendLua and trent:Alive() and trent:Team() == pl:Team() and TrueVisible(pl:EyePos(), trent:NearestPoint(pl:EyePos())) then
			hit = trent
		else
			for i, ent in pairs(ents.FindInSphere(tr.HitPos, 256)) do
				if ent.SendLua and ent:Alive() and ent:Team() == pl:Team() and pl ~= ent and TrueVisible(pl:EyePos(), ent:NearestPoint(pl:EyePos())) then
					hit = ent
					break
				end
			end
		end
		if hit:IsValid() then
			timer.Create(pl:UniqueID().."GreaterHealing"..hit:UniqueID(), 0.2, 0, function() GreaterHealing(pl, hit, pl:Health(), pl:UniqueID(), hit:UniqueID()) end)
			pl:EmitSound("nox/heal.ogg", 90, 80)
			pl:CustomGesture(ACT_SIGNAL_FORWARD)
		end
	else
		timer.Create(pl:UniqueID().."GreaterHealing"..pl:UniqueID(), 0.2, 0, function() GreaterHealing(pl, pl, pl:Health(), pl:UniqueID(), pl:UniqueID()) end)
		pl:EmitSound("nox/heal.ogg", 90, 80)
		pl:CustomGesture(ACT_SIGNAL_HALT)
	end
end

function spells.DivineBolt(pl)
	pl:CustomGesture(ACT_GESTURE_RANGE_ATTACK1)

	local ent = ents.Create("projectile_divinebolt")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:GetTeamID())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 1000)
		end
	end
end

function spells.FlameStrike(pl)
	local ent = ents.Create("projectile_flamestrike")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:GetTeamID())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 1100)
		end
	end
end

function spells.SunBeam(pl)
	local ent = ents.Create("projectile_sunbeam")
	if ent:IsValid() then
		ent.StartPos = pl:GetShootPos()
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:GetTeamID())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 2000)
		end
	end
end

function spells.EnergyBolt(pl)
	pl:StopIfOnGround()
	pl:GiveStatus("energybolt")
end

local function ChannelingLife(pl, uid)
	if pl:IsValid() and not (pl.CounterSpelled and CurTime() < pl.CounterSpelled) and pl:Alive() and pl:GetVelocity():Length() < 1 and 2 < pl:Health() and pl:GetMana() < pl:GetMaxMana() then
		pl:SetMana(math.min(pl:GetMana() + 2, pl:GetMaxMana()), true)
		pl:SetHealth(pl:Health() - 1)
		pl.LastAttacker = pl
		pl.LastAttacked = CurTime()
		return
	end
	timer.Destroy(uid.."ChannelingLife")
end

function spells.ChannelLife(pl)
	--[[pl:StopIfOnGround()

	timer.Create(pl:UniqueID().."ChannelingLife", 0.2, 0, function() ChannelingLife(pl, pl:UniqueID()) end)
	pl:EmitSound("beams/beamstart5.wav", 90, 80)]]
	if pl:GetStatus("channellife") or pl:Health() <= 1 or pl:GetMaxMana() == pl:GetMana() then
		pl:LM(75)
		return true
	end

	pl:GiveStatus("channellife", 10)
	pl:CustomGesture(ACT_SIGNAL_GROUP)
end

function CounterSpellEffect(pl, pos, range)
	local myteam = pl:Team()
	local counteredsomething = false
	for _, ent in pairs(ents.FindInSphere(pos, range or 450)) do
		if ent.CounterSpell then
			local owner = ent
			local towner = ent:GetOwner()
			if towner:IsPlayer() then
				owner = towner
			end
			if (ent:GetTeamID() ~= myteam or pl == owner) and TrueVisible(ent:NearestPoint(pos), pos)  then
				counteredsomething = true
				local effectdata = EffectData()
					effectdata:SetOrigin(ent:GetPos())
				util.Effect("counterspell", effectdata, true)
				if ent.CounterSpell == COUNTERSPELL_CUSTOM then
					ent:CounterSpelled(pl)
				elseif ent.CounterSpell == COUNTERSPELL_DESTROY then
					ent:Remove()
				elseif ent.CounterSpell == COUNTERSPELL_EXPLODE then
					ent:SetOwner(pl)
					ent:SetTeamID(myteam)
					ent:Explode()
				end
			end
		elseif ent:IsPlayer() and TrueVisible(ent:NearestPoint(pos), pos) then
			ent.CounterSpelled = CurTime() + 0.2
		end
	end
	if not counteredsomething then
		sound.Play("nox/counterspell.ogg", pos, 90, math.random(95, 105))
	end
end

function spells.CounterSpell(pl)
	CounterSpellEffect(pl, pl:EyePos())

	pl:CustomGesture(ACT_SIGNAL_HALT)
end

function spells.PixieSwarm(pl)
	local ent = ents.Create("projectile_pixie")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetSkin(pl:Team())
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceCenter(pl:GetAimVector() * 800)
		end
	end
	pl:CustomGesture(ACT_SIGNAL_FORWARD)
	pl:EmitSound("nox/pixieswarm.ogg")
end

function spells.ForceOfNature(pl)
	timer.Create(pl:UniqueID().."DoFON", 1, 1, function() DoForceOfNature(pl, pl:UniqueID()) end)
	pl:Slow(1, true)
	pl:GiveStatus("weight", 1)

	local effectdata = EffectData()
		effectdata:SetEntity(pl)
		effectdata:SetMagnitude(pl:GetTeamID())
	util.Effect("forceofnaturestart", effectdata, true)

	pl:CustomGesture(ACT_SIGNAL_FORWARD)
end
GM:AddLifeStatusTimer("DoFON")

function DoForceOfNature(pl, uid)
	if not (pl:IsValid() and pl:Alive()) then
		return
	end

	local aimvec = pl:GetAimVector()
	local ent = ents.Create("projectile_forceofnature")
	if ent:IsValid() then
		ent:SetPos(pl:GetShootPos())
		ent:SetOwner(pl)
		local teamid = pl:Team()
		ent:SetSkin(teamid)
		ent:Spawn()
		ent:SetTeamID(teamid)
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 700)
		end
	end
end

local function Regeneration(pl, owner, uid)
	if not pl:IsValid() and pl:Alive() then
		timer.Destroy(uid.."Regeneration")
		pl.Regeneration = nil
		return
	end

	GAMEMODE:PlayerHeal(pl, owner, 1)
	pl:SetHealth(math.min(pl:GetMaxHealth(), pl:Health() + 1))
end

function spells.Regeneration(pl, override, owner)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "Regeneration", true)
		return
	end

	local ent = pl:GiveStatus("regeneration", 15)
	ent.Healer = owner or pl
end

function spells.Shock(pl, override)
	local mypos = pl:GetCenter()
	for _, ent in pairs(ents.FindInSphere(mypos, 64)) do
		local nearest = ent:NearestPoint(mypos)
		if ent ~= pl and TrueVisible(nearest, mypos) then
			ent:TakeSpecialDamage(30, DMGTYPE_LIGHTNING, pl, DUMMY_SHOCK, pl:GetPos())
		end
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(mypos)
	util.Effect("shock", effectdata, true, true)

	local effect2 = ents.Create("point_tesla")
	if effect2:IsValid() then
		effect2:SetKeyValue("m_flRadius", "150")
		effect2:SetKeyValue("m_SoundName", "DoSpark")
		effect2:SetKeyValue("m_Color", "255 255 255")
		effect2:SetKeyValue("texture", "effects/laser1.vmt")
		effect2:SetKeyValue("beamcount_min", "18")
		effect2:SetKeyValue("beamcount_max", "25")
		effect2:SetKeyValue("thick_min", "5")
		effect2:SetKeyValue("thick_max", "10")
		effect2:SetKeyValue("lifetime_min", "0.25")
		effect2:SetKeyValue("lifetime_max", "0.4")
		effect2:SetKeyValue("interval_min", "0.05")
		effect2:SetKeyValue("interval_max", "0.12")
		effect2:SetPos(mypos)
		effect2:Spawn()
		effect2:Fire("DoSpark", "", 0.1)
		effect2:Fire("DoSpark", "", 0.3)
		effect2:Fire("DoSpark", "", 0.5)
		effect2:Fire("kill", "", 0.8)
	end
end

function spells.ProtectFromElements(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "ProtectFromElements", true)
		return
	end

	pl:RemoveStatus("protectfromfire", false, true)
	pl:RemoveStatus("protectfromcold", false, true)
	pl:RemoveStatus("protectfromshock", false, true)
	pl:GiveStatus("protectfromelements", 30)
end

function spells.ProtectFromFire(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "ProtectFromFire", true)
		return
	end

	if IsValid(pl:GetStatus("protectfromelements")) then return true end

	pl:GiveStatus("protectfromfire", 30)
end

function spells.ProtectFromCold(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "ProtectFromCold", true)
		return
	end

	if IsValid(pl:GetStatus("protectfromelements")) then return true end

	pl:GiveStatus("protectfromcold", 30)
end

function spells.ProtectFromShock(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "ProtectFromShock", true)
		return
	end

	if IsValid(pl:GetStatus("protectfromelements")) then return true end

	pl:GiveStatus("protectfromshock", 30)
end

function spells.ProtectFromPoison(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "ProtectFromPoison", true)
		return
	end

	pl:GiveStatus("protectfrompoison", 30)
end

function spells.Vampirism(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "Vampirism", true)
		return
	end

	pl:GiveStatus("vampirism", 20)
end

function spells.Haste(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "Haste", true)
		return
	end

	pl:GiveStatus("haste", 10)
end

function spells.Slow(pl)
	local ent = ents.Create("projectile_slow")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:Team())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 900)
		end
	end
end

function spells.Hex(pl)
	GenericHoming(pl, "Hex")
end

function spells.BloodBoil(pl)
	if pl:KeyDown(IN_USE) then
		GenericHoming(pl, "BloodBoil", true)
		return
	end
	GenericHoming(pl, "BloodBoil")
end

function spells.Explosion(pl)
	GenericHoming(pl, "Explosion")
end

function spells.Stun(pl)
	GenericHoming(pl, "Stun")
end

function spells.Tag(pl)
	GenericHoming(pl, "Tag")
end

function spells.CurePoison(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "CurePoison", true)
		return
	end

	pl:CurePoison()
end

function spells.Poison(pl)
	GenericHoming(pl, "Poison")
end

function spells.Evade(pl)
	if not pl:OnGround() or pl:IsAnchored() then return true end

	if pl:IsCarrying() then
		pl:LM(30)
		return true
	end

	local eyeang = pl:EyeAngles()
	eyeang.pitch = 0
	eyeang.roll = 0
	local dir = Vector(0, 0, 0)
	if pl:KeyDown(IN_FORWARD) then
		dir = dir + eyeang:Forward()
	end
	if pl:KeyDown(IN_BACK) then
		dir = dir - eyeang:Forward()
	end
	if pl:KeyDown(IN_MOVERIGHT) then
		dir = dir + eyeang:Right()
	end
	if pl:KeyDown(IN_MOVELEFT) then
		dir = dir - eyeang:Right()
	end
	dir:Normalize()
	if dir == vector_origin then
		dir = eyeang:Forward() * -1
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos())
		effectdata:SetNormal(pl:GetForward())
		effectdata:SetScale(2)
	util.Effect("Explosion", effectdata, true)
	util.Effect("AR2Explosion", effectdata, true)

	pl:SetGroundEntity(NULL)
	pl:SetLocalVelocity(dir * 625 + Vector(0, 0, 300))
end

function spells.ForceField(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "ForceField", true)
		return
	end

	pl:GiveStatus("forcefield")
	pl:CustomGesture(ACT_SIGNAL_GROUP)
end

function spells.Lightning(pl)
	pl:LagCompensation(true)
	local tr = pl:TraceLine(1100)

	local shotpos
	local toppos
	local bottompos
	local hitent = tr.Entity
	if hitent:IsValid() then
		shotpos = hitent:GetPos()
		bottompos = util.TraceLine({start = shotpos, endpos = shotpos + Vector(0,0,-10000), filter = hitent, mask = COLLISION_GROUP_DEBRIS}).HitPos
		toppos = util.TraceLine({start = shotpos, endpos = shotpos + Vector(0,0,10000), filter = hitent, mask = COLLISION_GROUP_DEBRIS}).HitPos
		hitent:TakeSpecialDamage(36, DMGTYPE_LIGHTNING, pl, DUMMY_LIGHTNING, bottompos)
	else
		shotpos = tr.HitPos
		bottompos = util.TraceLine({start = shotpos, endpos = shotpos + Vector(0,0,-10000), filter = pl}).HitPos
		tr = util.TraceLine({start = shotpos, endpos = shotpos + Vector(0,0,10000), filter = pl})
		toppos = tr.HitPos
		if tr.Entity:IsValid() then
			hitent = tr.Entity
			hitent:TakeSpecialDamage(36, DMGTYPE_LIGHTNING, pl, DUMMY_LIGHTNING, buttonpos)
		end
	end

	for _, ent in pairs(ents.FindInBox(bottompos + Vector(-32,-32,0), toppos + Vector(32,32,0))) do
		if string.sub(ent:GetClass(), 1, 20) == "projectile_dreadnaut" and not ent.Electricity then
			ent:SetSkin(1)
			if ent:GetTeamID() == pl:Team() then
				ent.Electricity = pl
			else
				ent.Electricity = ent:GetOwner()
			end
		end
	end

	local append = math.ceil(CurTime() * 10)
	local tempent = ents.Create("info_target")
	if tempent:IsValid() then
		tempent:SetPos(bottompos)
		tempent:SetName(pl:UniqueID().."templighttarget"..append)
		tempent:Spawn()
		if hitent:IsValid() then
			tempent:SetParent(hitent)
		end
		tempent:Fire("kill", "", 0.41)
	end

	local laser = ents.Create("env_laser")
	if laser:IsValid() then
		laser:SetPos(toppos)
		laser:SetKeyValue("renderamt", "255")
		laser:SetKeyValue("rendercolor", "21 106 234")
		laser:SetKeyValue("width", "30")
		laser:SetKeyValue("texture", "Effects/laser1.vmt")
		laser:SetKeyValue("TextureScroll", "1")
		laser:SetKeyValue("damage", "0")
		laser:SetKeyValue("renderfx", "0")
		laser:SetKeyValue("LaserTarget", pl:UniqueID().."templighttarget"..append)
		laser:SetKeyValue("NoiseAmplitude", "4")
		laser:SetKeyValue("spawnflags", "33")
		laser:Spawn()
		laser:SetOwner(pl)
		laser:Fire("kill", "", 0.75)
	end
	local effect2 = ents.Create("point_tesla")
	if effect2:IsValid() then
		effect2:SetKeyValue("m_flRadius", "250")
		effect2:SetKeyValue("m_SoundName", "DoSpark")
		effect2:SetKeyValue("m_Color", "255 255 255")
		effect2:SetKeyValue("texture", "effects/laser1.vmt")
		effect2:SetKeyValue("beamcount_min", "6")
		effect2:SetKeyValue("beamcount_max", "10")
		effect2:SetKeyValue("thick_min", "20")
		effect2:SetKeyValue("thick_max", "50")
		effect2:SetKeyValue("lifetime_min", "0.5")
		effect2:SetKeyValue("lifetime_max", "1")
		effect2:SetKeyValue("interval_min", "0.1")
		effect2:SetKeyValue("interval_max", "0.25")
		effect2:SetPos(bottompos + Vector(0,0,32))
		effect2:Spawn()
		if hitent:IsValid() then
			effect2:SetParent(hitent)
		end
		effect2:Fire("DoSpark", "", 0.1)
		effect2:Fire("DoSpark", "", 0.3)
		effect2:Fire("DoSpark", "", 0.5)
		effect2:Fire("kill", "", 0.8)
	end
	local effectdata = EffectData()
		effectdata:SetOrigin(bottompos)
	util.Effect("lightning", effectdata, true, true)
	util.ScreenShake(bottompos, math.random(10,30), 150.0, 0.75, 150)
	pl:LagCompensation(false)
end

function spells.Harpoon(pl)
	if IsValid(pl.harpoon) then return true end

	local ent = ents.Create("projectile_harpoon")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos() + pl:GetAimVector() * 40)
		ent:Spawn()
		ent:SetAngles(pl:GetAimVector():Angle())
	end
	pl:CustomGesture(ACT_GMOD_GESTURE_ITEM_THROW)
end

function RestoreSpeed(pl)
	if not pl:IsValid() then return end

	GAMEMODE:SetPlayerSpeed(pl, pl:GetPlayerClassTable().Speed)
end

function spells.WarCry(pl)
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:EyePos())
	util.Effect("warcry", effectdata, true)

	pl:Stun(1, true, true) --To make sure
	pl:GiveStatus("pacifism", 1)

	local pos = pl:EyePos()
	for _, ent in pairs(ents.FindInSphere(pos, 450)) do
		if ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= pl:GetTeamID() and ent:GetManaRegeneration() ~= 0 and TrueVisible(ent:NearestPoint(pos), pos) then
			ent:ManaStun(3)
			ent:LM(31)
		end
	end

	CounterSpellEffect(pl, pos, 450)
	util.ScreenShake(pos, 7, 5, 1, 480)
	pl:CustomGesture(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
end

function spells.EyeOfTheWolf(pl)
	if pl:GetStatus("infravision") then return true end

	pl:GiveStatus("infravision", 15)
end

function spells.Infravision(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "Infravision", true)
		return
	end

	pl:GiveStatus("infravision", 15)
end

function spells.Blink(pl)
	if pl:IsCarrying() then pl:LM(30) return true end
	if not pl:CanTeleport() then pl:LMR(55) return true end

	pl:GiveStatus("blink", 2)
end

function CreateTeleportCloud(pos1, pos2, pl)
	local ent = ents.Create("teleportcloud")
	if ent:IsValid() then
		ent:SetPos(pos1)
		ent.TargetPos = pos2
		ent.Target = ent2
		if pl then
			ent.Owner = pl
			ent:SetTeamID(pl:Team())
		else
			ent.Owner = ent
			ent:SetTeamID(0)
		end
		ent:Spawn()
		ent:Think()
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(pos1)
	util.Effect("teleportsparksstart", effectdata, true)
end

function spells.Anchor(pl)
	if pl:KeyDown(IN_USE) then
		GenericHit.Anchor(pl)
		return
	end
	GenericHoming(pl, "Anchor")
end

function spells.SwapLocation(pl)
	local ent = GenericHoming(pl, "SwapLocation")
	if ent then
		ent.Inversion = INVERSION_DESTROY
	end
end

function spells.DrainMana(pl)
	pl:StopIfOnGround()
	pl:GiveStatus("drainmana")
end

function spells.Inversion(pl)
	local myteam = pl:Team()
	local pos = pl:EyePos()
	local invertedsomething = false
	for _, ent in pairs(ents.FindInSphere(pos, 390)) do
		if ent.Inversion and ent:GetTeamID() ~= myteam and IsVisible(ent:GetPos(), pos) then
			invertedsomething = true
			Invert(ent, pl)
		end
	end
	if invertedsomething then
		sound.Play("nox/inversion.ogg", pos, 80, math.Rand(95, 105))

		pl:CustomGesture(ACT_SIGNAL_FORWARD)
	end
end

function Invert(ent, pl)
	if ent.Inversion == INVERSION_CUSTOM then
		ent:Inverted(pl)
	elseif ent.Inversion == INVERSION_DESTROY then
		local effectdata = EffectData()
			effectdata:SetOrigin(ent:GetPos())
		util.Effect("counterspell", effectdata, true)
		ent:Remove()
	elseif ent.Inversion == INVERSION_SETOWNER then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		local effectdata = EffectData()
			effectdata:SetOrigin(ent:GetPos())
			effectdata:SetNormal((ent:GetPos() - pl:EyePos()):GetNormal())
			effectdata:SetMagnitude(0)
		util.Effect("inversion", effectdata)
	elseif ent.Inversion == INVERSION_SETOWNER_REVERSE then
		ent:SetOwner(pl)
		ent:GetPhysicsObject():SetVelocityInstantaneous(ent:GetVelocity() * -1)
		ent:SetTeamID(pl:Team())
		local effectdata = EffectData()
			effectdata:SetOrigin(ent:GetPos())
			effectdata:SetNormal((ent:GetPos() - pl:EyePos()):GetNormal())
			effectdata:SetMagnitude(0)
		util.Effect("inversion", effectdata)
	elseif ent.Inversion == INVERSION_SETOWNER_REVERSE_TARGET then
		ent.Target = ent:GetOwner()
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		local effectdata = EffectData()
			effectdata:SetOrigin(ent:GetPos())
			effectdata:SetNormal((ent:GetPos() - pl:EyePos()):GetNormal())
			effectdata:SetMagnitude(0)
		util.Effect("inversion", effectdata)
	elseif ent.Inversion == INVERSION_SETOWNER_REVERSE_TARGET_VELOCITY then
		ent.Target = ent:GetOwner()
		ent:SetOwner(pl)
		ent:GetPhysicsObject():SetVelocityInstantaneous(ent:GetVelocity() * -1)
		ent:SetTeamID(pl:Team())
		local effectdata = EffectData()
			effectdata:SetOrigin(ent:GetPos())
			effectdata:SetNormal((ent:GetPos() - pl:EyePos()):GetNormal())
			effectdata:SetMagnitude(0)
		util.Effect("inversion", effectdata)
	end
end

function spells.LightningArrow(pl)
	if pl:GetStatus("archerenchant_lightning") then
		pl:RemoveStatus("archerenchant*", false, true)
		return true
	end

	pl:RemoveStatus("archerenchant*", false, true)
	pl:GiveStatus("archerenchant_lightning")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
end

function spells.FireArrow(pl)
	if pl:GetStatus("archerenchant_fire") then
		pl:RemoveStatus("archerenchant*", false, true)
		return true
	end

	pl:RemoveStatus("archerenchant*", false, true)
	pl:GiveStatus("archerenchant_fire")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
end

function spells.DetonatorArrow(pl)
	if pl:GetStatus("archerenchant_detonator") then
		pl:RemoveStatus("archerenchant*", false, true)
		return true
	end

	pl:RemoveStatus("archerenchant*", false, true)
	pl:GiveStatus("archerenchant_detonator")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
end

function spells.GrappleArrow(pl)
	if pl:GetStatus("archerenchant_grapple") then
		pl:RemoveStatus("archerenchant*", false, true)
		return true
	end

	if pl:IsCarrying() then
		pl:LMR(59)
		return true
	end

	pl:RemoveStatus("archerenchant*", false, true)
	pl:GiveStatus("archerenchant_grapple")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
end

function spells.VampiricArrow(pl)
	if pl:GetStatus("archerenchant_vampiric") then
		pl:RemoveStatus("archerenchant*", false, true)
		return true
	end

	pl:RemoveStatus("archerenchant*", false, true)
	pl:GiveStatus("archerenchant_vampiric")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
end

function spells.SilverArrow(pl)
	if pl:GetStatus("archerenchant_silver") then
		pl:RemoveStatus("archerenchant*", false, true)
		return true
	end

	pl:RemoveStatus("archerenchant*", false, true)
	pl:GiveStatus("archerenchant_silver")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
end

function spells.BouncerArrow(pl)
	if pl:GetStatus("archerenchant_bouncer") then
		pl:RemoveStatus("archerenchant*", false, true)
		return true
	end

	pl:RemoveStatus("archerenchant*", false, true)
	pl:GiveStatus("archerenchant_bouncer")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
end

function spells.SpriteArrow(pl)
	if pl:GetStatus("archerenchant_sprite") then
		pl:RemoveStatus("archerenchant*", false, true)
		return true
	end

	pl:RemoveStatus("archerenchant*", false, true)
	pl:GiveStatus("archerenchant_sprite")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
end

function spells.NightWish(pl)
	if pl:GiveInvisibility() then
		pl:CustomGesture(ACT_SIGNAL_GROUP)
	else
		return true
	end
end

function spells.Scatterfrost(pl)
	local ent = ents.Create("projectile_scatterfrost")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		local aimvec = pl:GetAimVector()
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 550)
		end

		pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE)
	end
end

function spells.VenomBlade(pl)
	if pl:GetStatus("venomblade") then return true end

	pl:GiveStatus("venomblade")
end

function spells.Invisibility(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "Invisibility", true)
		return
	end

	if not pl:GiveInvisibility() then return true end
end

local function DoTeleportToTarget(pl, tr)
	tr.HitPos = tr.HitPos + tr.HitNormal * 0.01

	local vStart = tr.HitPos + Vector(0,0,37)
	if tr.Hit then
		vStart = vStart + tr.HitNormal * 2
	end

	local hits = 0

	local tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,17,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(17,17,37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,17,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(17,17,-37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,17,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(-17,17,37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,17,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(-17,17,-37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(0,0,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 37
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(0,0,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 37
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,-17,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(17,-17,37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,-17,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(17,-17,-37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end


	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,-17,37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(-17,-17,37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,-17,-37), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * Vector(-17,-17,-37):Length()
		tr.HitPos = vStart - Vector(0,0,37)
		if tr2.HitNormal.z < 0.9 then
			hits = hits + 1
		end
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(0,17,0), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 17
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(0,-17,0), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 17
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end

	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(17,0,0), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 17
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end
	tr2 = util.TraceLine({start = vStart, endpos = vStart + Vector(-17,0,0), filter=pl, mask=MASK_PLAYERSOLID})
	if tr2.Hit then
		vStart = vStart + tr2.HitNormal * 17
		tr.HitPos = vStart - Vector(0,0,37)
		hits = hits + 1
	end

	for _, v in pairs(ents.FindByClass("prop_anchorbeacon")) do
		if v:GetPos():Distance(tr.HitPos) <= v.Radius and v:ShouldAnchor(pl) then
			pl:LM(61)
			return true
		end
	end

	if 6 <= hits or not TrueVisible(pl:EyePos(), tr.HitPos) then
		pl:LM(37)
		return true
	end

	CreateTeleportCloud(pl:GetPos() + Vector(0,0,1), tr.HitPos, pl)
end

function spells.TeleportToTarget(pl)
	if pl:IsCarrying() then
		pl:LM(30)
		return true
	end

	if not pl:CanTeleport() then pl:LMR(55) return true end

	local _start = pl:GetShootPos()
	local range = 275

	-- this is a check to see if the player would cross a repel wall. since it's not solid, traces do not hit it.
	local dir = pl:GetAimVector()
	local numSpheres = 5
	local delta = range / numSpheres
	local rad = delta/2
	local pos = _start + dir * rad

	for i = 1, numSpheres do
		local spherePos = pos + dir * delta * (i - 1)
		--debugoverlay.Sphere(spherePos, rad, 5, COLOR_RED)
		for _, ent in pairs(ents.FindInSphere(spherePos, rad)) do
			if ent:IsValid() and ent:GetClass() == "repelwall" and ent:GetTeamID() ~= pl:GetTeamID() then
				pl:LM(37)
				return true
			end
		end
	end

	local tr = util.TraceLine({start = _start, endpos = _start + dir * range, filter=pl, mask=MASK_PLAYERSOLID})

	return DoTeleportToTarget(pl, tr)
end

spells.TeleportToTargetForward = spells.TeleportToTarget

function spells.TeleportToTargetBack(pl)
	if pl:IsCarrying() then
		pl:LM(30)
		return true
	end

	if not pl:CanTeleport() then pl:LMR(55) return true end

	local _start = pl:GetShootPos()
	local tr = util.TraceLine({start = _start, endpos = _start + pl:GetAimVector() * -275, filter=pl})
	return DoTeleportToTarget(pl, tr)
end

function spells.TeleportToTargetRight(pl)
	if pl:IsCarrying() then
		pl:LM(30)
		return true
	end

	if not pl:CanTeleport() then pl:LMR(55) return true end

	local _start = pl:GetShootPos()
	local tr = util.TraceLine({start = _start, endpos = _start + pl:GetRight() * 275, filter=pl})
	return DoTeleportToTarget(pl, tr)
end

function spells.TeleportToTargetLeft(pl)
	if pl:IsCarrying() then
		pl:LM(30)
		return true
	end

	if not pl:CanTeleport() then LMR(55) return true end

	local _start = pl:GetShootPos()
	local tr = util.TraceLine({start = _start, endpos = _start + pl:GetRight() * -275, filter=pl})
	return DoTeleportToTarget(pl, tr)
end

function spells.MarkLocation(pl)
	if pl:OnGround() then
		local pos = pl:GetPos()
		pl.Marker = pos
		local effectdata = EffectData()
			effectdata:SetOrigin(pos + Vector(0,0,0.5))
			effectdata:SetEntity(pl)
			effectdata:SetMagnitude(0)
		util.Effect("marker", effectdata)
	else
		pl:LM(33)
		return true
	end
end
GM:AddLifeStatus("Marker")

function spells.TeleportToMarker(pl)
	if not pl:CanTeleport() then
		pl:LMR(55)
		return true
	end

	if pl:IsCarrying() then
		pl:LM(30)
		return true
	end
	if pl.Marker then
		CreateTeleportCloud(pl:GetPos(), pl.Marker, pl)
		pl.Marker = nil
		pl:SendLua("MARKEFFECT.Live=false")
	end
end

function spells.Push(pl)
	local eyepos = pl:EyePos()
	if pl:KeyDown(IN_USE) then
		local eyepos = pl:EyePos()
		for _, ent in pairs(ents.FindInSphere(eyepos, 400)) do
			if ent:IsPlayer() then
				if not ent:IsAnchored() and ent:Team() ~= pl:Team() and TrueVisible(eyepos, ent:NearestPoint(eyepos)) then
					ent:SetLastAttacker(pl)
					ent:SetGroundEntity(NULL)
					ent:SetVelocity((pl:GetPos() - ent:GetPos()):GetNormal() * 400 + Vector(0,0,200))
				end
			elseif IsVisible(eyepos, ent:GetPos()) then
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() and phys:IsMoveable() then
					phys:ApplyForceCenter((pl:GetPos() - ent:GetPos()):GetNormal() * 40 * phys:GetMass() + Vector(0,0,16) * phys:GetMass())
				end
			end
		end
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos() + Vector(0,0,1))
			effectdata:SetMagnitude(1)
		util.Effect("pullpush", effectdata, true)
	else
		for _, ent in pairs(ents.FindInSphere(eyepos, 400)) do
			if ent:IsPlayer() then
				if not ent:IsAnchored() and ent:Team() ~= pl:Team() and TrueVisible(eyepos, ent:NearestPoint(eyepos)) then
					ent:SetGroundEntity(NULL)
					ent:SetLastAttacker(pl)
					ent:SetVelocity((pl:GetPos() - ent:GetPos()):GetNormal() * -400 + Vector(0, 0, 140))
				end
			elseif IsVisible(eyepos, ent:GetPos()) then
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() and phys:IsMoveable() then
					phys:ApplyForceCenter((pl:GetPos() - ent:GetPos()):GetNormal() * -40 * phys:GetMass() + Vector(0, 0, 16) * phys:GetMass())
				end
			end
		end
		local effectdata = EffectData()
			effectdata:SetOrigin(pl:GetPos() + Vector(0,0,1))
			effectdata:SetMagnitude(0)
		util.Effect("pullpush", effectdata, true)
	end
end

function spells.Pull(pl)
	local eyepos = pl:EyePos()
	for _, ent in pairs(ents.FindInSphere(eyepos, 400)) do
		if ent:IsPlayer() then
			if not ent:IsAnchored() and ent:Team() ~= pl:Team() and TrueVisible(eyepos, ent:NearestPoint(eyepos)) then
				ent:SetLastAttacker(pl)
				ent:SetGroundEntity(NULL)
				ent:SetVelocity((pl:GetPos() - ent:GetPos()):GetNormal() * 400 + Vector(0,0,200))
			end
		elseif IsVisible(eyepos, ent:GetPos()) then
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() and phys:IsMoveable() then
				phys:ApplyForceCenter((pl:GetPos() - ent:GetPos()):GetNormal() * 40 * phys:GetMass() + Vector(0,0,16) * phys:GetMass())
			end
		end
	end
	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + Vector(0,0,1))
		effectdata:SetMagnitude(1)
	util.Effect("pullpush", effectdata, true)
end

function spells.NapalmBomb(pl)
	local ent = ents.Create("projectile_napalmbomb")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:Spawn()

		local ang = pl:EyeAngles()
		ang.pitch = math.min(ang.pitch, -45)
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(ang:Forward() * 600)
		end

		util.SpriteTrail(ent, 0, color_white, false, 48, 32, 1, 0.025, "Effects/fire_cloud2.vmt")

		pl:CustomGesture(ACT_SIGNAL_FORWARD)
	end
end

function spells.Meteor(pl)
	--[[for _, ent in pairs(ents.FindByClass("projectile_meteor")) do
		if ent:GetOwner() == pl then
			pl:LMR(36)
			return true
		end
	end

	local _start = pl:GetShootPos()
	local filt = ents.FindByClass("projectile_*")
	table.insert(filt, pl)

	local aimpos = util.TraceLine({start = _start, endpos = _start + pl:GetAimVector() * 1000, filter = filt, mask = MASK_SOLID}).HitPos
	local groundpos = util.TraceLine({start = aimpos, endpos = aimpos + Vector(0, 0, -10240), filter = filt, mask = MASK_SOLID}).HitPos

	local tr = util.TraceLine({start = groundpos, endpos = groundpos + Vector(0, 0, 2048), mask = MASK_SOLID_BRUSHONLY})
	if tr.Hit and not tr.HitSky then
		pl:LMR(63)
		return true
	end

	local ent = ents.Create("projectile_meteor")
	if ent:IsValid() then
		ent:SetPos(tr.HitPos)
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(Vector(0, 0, tr.HitPos:Distance(groundpos) * -0.6))
		end
	end

	pl:CustomGesture(ACT_SIGNAL_HALT)]]

	if pl:IsIndoors(true) then
		pl:LMR(63)
		return true
	end

	local ent = ents.Create("projectile_meteor")
	if ent:IsValid() then
		ent:SetPos(pl:GetShootPos())
		ent:SetOwner(pl)
		ent:SetTeamID(pl:GetTeamID())
		ent:Spawn()

		local ang = pl:EyeAngles()
		ang.pitch = math.min(math.min(ang.pitch, -ang.pitch), -70)
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(ang:Forward() * 1400)
			phys:AddAngleVelocity(VectorRand() * 900)
		end
	end

	pl:CustomGesture(ACT_SIGNAL_HALT)
end

function spells.Comet(pl)
--[[	for _, ent in pairs(ents.FindByClass("projectile_comet")) do
		if ent:GetOwner() == pl then
			pl:LMR(36)
			return true
		end
	end

	local _start = pl:GetShootPos()
	local filt = ents.FindByClass("projectile_*")
	table.insert(filt, pl)

	local aimpos = util.TraceLine({start = _start, endpos = _start + pl:GetAimVector() * 1000, filter = filt, mask = MASK_SOLID}).HitPos
	local groundpos = util.TraceLine({start = aimpos, endpos = aimpos + Vector(0, 0, -10240), filter = filt, mask = MASK_SOLID}).HitPos

	local tr = util.TraceLine({start = groundpos, endpos = groundpos + Vector(0, 0, 2048), mask = MASK_SOLID_BRUSHONLY})
	if tr.Hit and not tr.HitSky then
		pl:LMR(63)
		return true
	end

	local ent = ents.Create("projectile_comet")
	if ent:IsValid() then
		ent:SetPos(tr.HitPos - Vector(0, 0, 250))
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(Vector(0, 0, tr.HitPos:Distance(groundpos) * -0.6))
		end
	end

	pl:CustomGesture(ACT_SIGNAL_HALT)]]

	if pl:IsIndoors(true) then
		pl:LMR(63)
		return true
	end

	local ent = ents.Create("projectile_comet")
	if ent:IsValid() then
		ent:SetPos(pl:GetShootPos())
		ent:SetOwner(pl)
		ent:SetTeamID(pl:GetTeamID())
		ent:Spawn()

		local ang = pl:EyeAngles()
		ang.pitch = math.min(math.min(ang.pitch, -ang.pitch), -70)
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(ang:Forward() * 1400)
			phys:AddAngleVelocity(VectorRand() * 900)
		end
	end

	pl:CustomGesture(ACT_SIGNAL_HALT)
end

util.PrecacheSound("items/medshotno1.wav")

function spells.FireSprites(pl)
	local count = 0
	for _, ent in pairs(ents.FindByClass("projectile_firesprite")) do
		if ent:GetOwner() == pl then
			count = count + 1
		end
	end

	if count >= 6 then
		pl:LMR(36)
		return true
	end

	--local target = pl:TraceHull(16000, MASK_SOLID, 4).HitPos
	local aimang = pl:GetAimVector():Angle()
	local plteam = pl:Team()
	for i=1, math.min(2, 6 - count) do
		local proj = ents.Create("projectile_firesprite")
		local heading
		if i == 1 then
			heading = (aimang:Up() + aimang:Right()):GetNormal()
		else
			heading = (aimang:Up() + aimang:Right() * -1):GetNormal()
		end
		proj:SetOwner(pl)
		proj:SetPos(pl:EyePos() + heading * 8)
		proj:SetColor(team.GetColor(pl:GetTeamID()))
		proj:Spawn()
		proj:SetTeamID(plteam)
		--proj.Target = target
		proj:GetPhysicsObject():SetVelocityInstantaneous(heading * 1300)
	end
end

local function DoJolt(pl, pos)
	for i=1, 8 do
		local ent = ents.Create("jolt")
		if ent:IsValid() then
			ent:SetPos(pos)
			ent:SetOwner(pl)
			ent:Spawn()
		end
	end
end

function spells.Jolt(pl)
	local _start = pl:GetShootPos()
	local filt = ents.FindByClass("projectile_*")
	filt = table.Add(filt, player.GetAll())
	table.insert(filt, pl)

	local __start = util.TraceLine({start = _start, endpos = _start + pl:GetAimVector() * 1000, filter=filt}).HitPos
	local tr = util.TraceLine({start = __start, endpos = __start + Vector(0, 0, 1300), mask = MASK_SOLID_BRUSHONLY, filter=filt})

	if tr.HitWorld and not tr.HitSky then
		pl:LM(56)
		return true
	end

	local pos = tr.HitPos + tr.HitNormal * 16
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
	util.Effect("joltcloud", effectdata)

	timer.Simple(1, function() DoJolt(pl, pos) end)
end

function spells.PoisonRain(pl)
	for _, ent in pairs(ents.FindByClass("projectile_poisonrain")) do
		if ent:GetOwner() == pl then
			pl:LMR(36)
			return true
		end
	end

	for _, ent in pairs(ents.FindByClass("poisonrain")) do
		if ent:GetOwner() == pl then
			pl:LMR(36)
			return true
		end
	end

	local _start = pl:GetShootPos()
	local filt = ents.FindByClass("projectile_*")
	filt = table.Add(filt, player.GetAll())
	table.insert(filt, pl)

	local tr = util.TraceLine({start = _start, endpos = _start + pl:GetAimVector() * 10000, filter=filt})

	if IsIndoors(tr.HitPos) then
		pl:LM(60)
		return true
	end

	local ent = ents.Create("projectile_poisonrain")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:GetTeamID())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 700)
		end
	end
end

function spells.HealRing(pl)
	local count = 0
	for _, ent in pairs(ents.FindByClass("healring")) do
		if ent:GetOwner() == pl then
			count = count + 1
		end
	end

	if 1 <= count then
		pl:LM(62)
		return true
	end

	local ent = ents.Create("healring")
	if ent:IsValid() then
		ent:SetPos(pl:GetPos() + Vector(0,0,16))
		ent:SetOwner(pl)
		ent:SetParent(pl)
		ent:SetTeamID(pl:Team())
		ent:Spawn()
		ent:EmitSound("nox/healringbegin.ogg")
		pl.HealRing = ent
		RestoreSpeed(pl)
	end
end

function spells.HallowedGround(pl)
	if not pl:IsOnGround() then pl:LMR(33) return true end

	if pl:GetStatus("hallowedgroundchanneling") then
		pl:RemoveStatus("hallowedgroundchanneling")
		return true
	end
	pl:GiveStatus("hallowedgroundchanneling", 5)
end

local function DoDragoonFireBall(pl, uid)
	if not pl:IsValid() or not pl:Alive() then return end

	local ent = ents.Create("projectile_dragoonfireball")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:Team())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:Wake()
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 750)
		end
	end
end

function spells.DragoonFireBall(pl)
	timer.Create(pl:UniqueID().."DoDFB", 1.25, 1, function() DoDragoonFireBall(pl, pl:UniqueID()) end)
	local effectdata = EffectData()
		effectdata:SetEntity(pl)
		effectdata:SetOrigin(pl:EyePos())
		effectdata:SetNormal(pl:GetAimVector())
	util.Effect("dragoonfireballstart", effectdata, true)
	pl:Slow(1.25, true)
	pl:GiveStatus("weight", 1.25)
	pl:CustomGesture(ACT_GMOD_GESTURE_ITEM_THROW)
end

local function SanctuaryTimer(pos, caster, teamid)
	for _, ent in pairs(ents.FindInSphere(pos, 190)) do
		if ent:IsPlayer() and ent:Alive() and TrueVisible(ent:NearestPoint(pos), pos) then
			if ent:Team() == teamid then
				GAMEMODE:PlayerHeal(ent, caster, 1)
			else
				ent.LastAttacker = caster
				ent.LastAttacked = CurTime()
				ent:SetVelocity((ent:GetPos() - pos):GetNormal() * 750)
			end
		end
	end
end

util.PrecacheSound("weapons/physcannon/physcannon_charge.wav")
function spells.Sanctuary(pl)
	if pl.ActiveSanc then pl:LMR(36) return true end

	local pos = pl:GetPos() + Vector(0, 0, 4)
	local teamid = pl:Team()
	timer.Create("sanct"..pl:UniqueID()..CurTime(), 0.1, 40, function() SanctuaryTimer(pos, pl, teamid) end)
	pl.ActiveSanc = true
	timer.Simple(4, function() pl.ActiveSanc = nil end)

	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + Vector(0,0,2.5))
		effectdata:SetEntity(pl)
		effectdata:SetMagnitude(4)
	util.Effect("sanctuary", effectdata)

	pl:CustomGesture(ACT_GESTURE_RANGE_ATTACK1)
end

function spells.Levitate(pl)
	if pl:IsAnchored() or pl:IsCarrying() then
		return true
	end

	pl:GiveStatus("levitate", 7.5)
end

function spells.DragoonFlight(pl)
	if pl:IsAnchored() or pl:IsCarrying() then
		return true
	end

	pl:GiveStatus("dragoonflight", 10)
end

function spells.BerserkerCharge(pl)
	if pl:GetStatus("stun") or pl:GetStatus("stun_noeffect") or pl:IsCarrying() then return true end

	pl:GiveStatus("berserkercharge", 2)
end

GenericHit = {}

function GenericHit.Anchor(pl, proj)
	local status = pl:GiveStatus("anchor", 10)

	if proj then
		status.Hostile = true
	end
end

function GenericHit.Slow(pl, proj)
	pl:Slow(4)
	local owner = proj:GetOwner()
	if owner:IsValid() then
		pl:SetLastAttacker(owner)
	end
end

function GenericHit.Explosion(pl, proj)
	pl:GiveStatus("explosion", 2).Attacker = proj:GetOwner()
end

function GenericHit.Tag(pl, proj)
	local owner = proj:GetOwner()
	if owner:IsValid() then
		local status = pl:GiveStatus("tag", 10)
		if status:IsValid() then
			status:SetTagOwner(owner)
		end
	end
end

function GenericHit.Stun(pl, proj)
	pl:Stun(2.5)
	local owner = proj:GetOwner()
	if owner:IsValid() then
		pl:SetLastAttacker(owner)
	end
end

function GenericHit.LesserHeal(pl, ent)
	spells.LesserHeal(pl, true, ent:GetOwner())
end

function GenericHit.Hex(pl, proj)
	local status = pl:GiveStatus("hex", 10)
	local owner = proj:GetOwner()
	if owner:IsValid() then
		pl:SetLastAttacker(owner)
	end
end

function GenericHit.BloodBoil(pl, proj)
	local status = pl:GiveStatus("bloodboil", 45)
	if status:IsValid() then
		local owner = proj:GetOwner()
		if owner:IsValid() then
			if owner:Team() ~= pl:Team() then
				pl:SetLastAttacker(owner)
				status.Hostile = true
			end

			status.BloodBoilOwner = owner
		end
	end
end

function GenericHit.ForceField(pl)
	spells.ForceField(pl, true)
end

function GenericHit.Poison(pl, proj)
	pl:Poison()
	local owner = proj:GetOwner()
	if owner:IsValid() then
		pl:SetLastAttacker(owner)
	end
end

function GenericHit.CurePoison(pl, proj)
	pl:CurePoison()
end

util.PrecacheSound("player/pl_pain5.wav")
util.PrecacheSound("player/pl_pain6.wav")
util.PrecacheSound("player/pl_pain7.wav")
function DoPoison(ent, timername)
	if ent:IsValid() and ent:Alive() then
		local damage = 3

		ent.PoisonCount = ent.PoisonCount or 8
		ent.PoisonCount = ent.PoisonCount - 1

		ent:EmitSound("player/pl_pain"..math.random(5, 7)..".wav")

		if damage < ent:Health() then
			ent:TakeSpecialDamage(damage, DMGTYPE_POISON, ent.LastAttacker)
		else
			ent:SetHealth(2)
			ent:TakeSpecialDamage(1, DMGTYPE_GENERIC, ent.LastAttacker)
		end

		if ent.PoisonCount <= 0 then
			timer.Destroy(timername)
		end
	else
		timer.Destroy(timername)
	end
end

function GenericHit.Haste(pl)
	spells.Haste(pl, true)
end

function GenericHit.Invisibility(pl)
	spells.Invisibility(pl, true)
end

function GenericHit.Infravision(pl)
	spells.Infravision(pl, true)
end

function GenericHit.ProtectFromElements(pl)
	spells.ProtectFromElements(pl, true)
end

function GenericHit.ProtectFromShock(pl)
	spells.ProtectFromShock(pl, true)
end

function GenericHit.ProtectFromFire(pl)
	spells.ProtectFromFire(pl, true)
end

function GenericHit.ProtectFromCold(pl)
	spells.ProtectFromCold(pl, true)
end

function GenericHit.ProtectFromPoison(pl)
	spells.ProtectFromPoison(pl, true)
end

function GenericHit.Vampirism(pl)
	spells.Vampirism(pl, true)
end

function GenericHit.Aegis(pl)
	spells.Aegis(pl)
end

function GenericHit.Shock(pl)
	spells.Shock(pl, true)
end

function GenericHit.Regeneration(pl, ent)
	spells.Regeneration(pl, true, ent:GetOwner())
end

function GenericHit.SwapLocation(pl, proj)
	local owner = proj:GetOwner()
	if not owner.SendLua then return end
	if not pl:CanTeleport() or pl:IsCarrying() or not owner:CanTeleport() or owner:IsCarrying() or pl:InVehicle() or owner:InVehicle() or not owner:Alive() then return end

	if IsVisible2(owner, pl) then
		pl:SetLastAttacker(owner)
		local ownerpos = owner:GetPos()
		owner:SetPos(owner:GetPos() + Vector(0, 0, 72))
		local plpos = pl:GetPos()
		pl:SetPos(ownerpos)
		owner:SetPos(plpos)
		pl:EmitSound("nox/genericprojectile.ogg")

		local effectdata = EffectData()
			effectdata:SetOrigin(plpos)
		util.Effect("teleportsparksstart", effectdata, true)
			effectdata:SetOrigin(ownerpos)
		util.Effect("teleportsparksstart", effectdata, true)
	end
end

function ExplosiveDamage(owner, from, maxrange, minrange, distmultiplier, dmgmultiplier, mindamage, typ, damagetype, ignore)
	local mypos
	damagetype = damagetype or DMGTYPE_FIRE

	if type(from) == "Vector" then
		mypos = from
	else
		mypos = from:LocalToWorld(from:OBBCenter())
	end

	local t = {}

	for _, ent in pairs(ents.FindInSphere(mypos, maxrange)) do
		if ent:IsValid() then
			local entpos = ent:NearestPoint(mypos)
			if TrueVisible(entpos, mypos) then
				if !ignore or (ignore and ent ~= owner) then
					local damage = math.max((minrange - entpos:Distance(mypos) * distmultiplier) * dmgmultiplier, mindamage)
					ent:TakeSpecialDamage(damage, damagetype, owner, typ or from, mypos)
					t[ent] = damage
				end
			end
		end
	end

	util.ScreenShake(mypos, minrange * 17, minrange * 10, math.Clamp(dmgmultiplier, 0.75, 2), maxrange * 2.5)

	return t
end

function spells.Zolt(pl)
	local ent = ents.Create("projectile_zolt")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:Team())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 400)
		end
	end
end

function spells.VolcanicBlast(pl)
	pl:GiveStatus("channelingvolcanicblast", 1.75)
end

function spells.Armageddon(pl)
	if not TrueVisible(pl:EyePos(), pl:GetPos() + Vector(0, 0, 120)) then
		pl:LMR(63)
		return true
	end

	pl:GiveStatus("channelingarmageddon", 2.25)
end

function spells.Meltdown(pl)
	if not TrueVisible(pl:EyePos(), pl:GetPos() + Vector(0, 0, 250)) then
		pl:LMR(63)
		return true
	end

	pl:GiveStatus("channelingmeltdown", 4)
end

function spells.Gust(pl)
	if timer.Exists("gustanim") then
		timer.Destroy("gustanim")
	end

	pl:ResetLuaAnimation("GUST")

	local ent = ents.Create("projectile_gust")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 1000)
		end
	end

	timer.Simple(1.25, function() pl:StopLuaAnimation("GUST", 1) end)
end

function spells.Earthquake(pl)
	if not pl:OnGround() then
		pl:LMR(64)
		return true
	end

	pl:GiveStatus("channelingearthquake", 5)
end

function spells.Geyser(pl)
	local ent = ents.Create("projectile_geyser")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetPos(pl:GetShootPos())
		ent:SetTeamID(pl:GetTeamID())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 900)
		end
	end
end

function spells.HydroPump(pl)
	pl:StopIfOnGround()
	pl:GiveStatus("channelinghydropump")
end

function spells.Whirlwind(pl)
	if pl:IsAnchored() or pl:IsCarrying() then
		pl:LMR(65)
		return true
	end

	pl:GiveStatus("whirlwind", 1.5):SetDir(pl:GetForward())
end

function spells.Aegis(pl)
	if pl:KeyDown(IN_USE) then
		GenericHoming(pl, "Aegis", true)
		return
	end

	pl:GiveStatus("aegis", 30)
end

function spells.Cauterize(pl)
	if pl:GetStatus("channelingcauterize") then
		pl:LMR(66)
		return true
	end

	pl:GiveStatus("channelingcauterize", 3)
end

function spells.Flamethrower(pl)
	pl:GiveStatus("flamethrower", 1.5)
end

function spells.SalamanderSkin(pl)
	pl:GiveStatus("salamanderskin", 30)
end

function spells.Scorch(pl)
	local ent = ents.Create("projectile_scorch")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:GetTeamID())
		ent:SetPos(pl:GetShootPos())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(pl:GetAimVector() * 250)
		end
	end
end

function spells.Sanctify(pl)
	pl:StopAllLuaAnimations()
	pl:ResetLuaAnimation("PAL_GESTURE_1")

	timer.Simple(.75, function()
		if pl:IsValid() and pl:Alive() then
			pl:EmitSound("nox/healringbegin.ogg", 100, 200)

			local effectdata = EffectData()
				effectdata:SetOrigin(pl:GetCenter())
			util.Effect("sanctify", effectdata)
		end
	end)

	timer.Simple(1, function()
		if pl:IsValid() and pl:Alive() then
			local pos = pl:GetCenter()
			for _, ent in pairs(ents.FindInSphere(pos, 200)) do
				if ent:IsPlayer() and ent:Alive() and ent:Team() == pl:Team() and TrueVisible(pos, ent:NearestPoint(pos)) then
					ent:CurePoison()
					ent:RemoveAllStatus(false, false, true)
					local status = ent:GiveStatus("sanctify", 12.5)
				end
			end
		end
	end)

	pl:GlobalCooldown(2)
	pl:GiveStatus("pacifism", 2)
end

function spells.Oversoul(pl)
	pl:GiveStatus("oversoul", 3.5)
end

function spells.Repel(pl)
	pl:StopAllLuaAnimations()
	pl:ResetLuaAnimation("PAL_GESTURE_1")

	timer.Simple(1, function()
		if pl:IsValid() and pl:Alive() then
			local dir = pl:GetForward()
			dir.z = 0
			local pos = pl:GetPos() + Vector(0, 0, 50) + dir * 50

			local tr = util.TraceLine({start=pos, endpos=pos + Vector(0, 0, -100), mask = MASK_SOLID_BRUSHONLY})
			if tr.HitWorld then
			pos = tr.HitPos + tr.HitNormal * 50
			else
				pos = pos
			end

			local ent = ents.Create("repelwall")
			if ent:IsValid() then
				ent:SetOwner(pl)
				ent:SetTeamID(pl:Team())
				ent:SetSkin(pl:Team())
				ent:SetPos(pos)
				ent:SetAngles(pl:GetAngles())
				ent:Spawn()
			end
		end
	end)

	pl:GlobalCooldown(2)
	pl:GiveStatus("pacifism", 2)
end

function spells.SacredVow(pl)
	pl:StopAllLuaAnimations()
	pl:ResetLuaAnimation("PAL_GESTURE_1")

	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetCenter())
		effectdata:SetEntity(pl)
	util.Effect("sacredvow", effectdata)


	timer.Simple(.75, function()
		if pl:IsValid() and pl:Alive() then
			local eyepos = pl:EyePos()
			local myteam = pl:Team()

			for _, ent in pairs(ents.FindInSphere(eyepos + pl:GetAimVector() * 24, 40)) do
				if ent:IsValid() and ent:IsPlayer() and ent ~= pl and ent:GetTeamID() == myteam then
					GAMEMODE:PlayerHeal(ent, pl, 15)

					if not ent:GetStatus("sacredvow") then
						local status = ent:GiveStatus("sacredvow")
						status:SetCaster(pl)
					end
				end
			end
		end
	end)

	pl:GlobalCooldown(2)
	pl:GiveStatus("pacifism", 2)
end

function spells.HolyNova(pl)
	pl:StopAllLuaAnimations()
	pl:ResetLuaAnimation("PAL_GESTURE_2")

	local ent = ents.Create("holynova")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetSkin(pl:Team())
		ent:SetPos(pl:GetPos())
		ent:Spawn()
	end

	pl:GlobalCooldown(1.75)
	pl:GiveStatus("pacifism", 1.75)
end

function spells.Smite(pl)
	pl:StopAllLuaAnimations()
	pl:ResetLuaAnimation("PAL_GESTURE_3")

	timer.Simple(.4, function()
		pl:EmitSound("npc/zombie/claw_miss1.wav", 80, math.Rand(60, 70))
	end)

	timer.Simple(.6, function()
		if pl:IsOnGround() then
			local pos1 = pl:GetCenter() + pl:GetForward() * 40
			local pos2 = pl:GetCenter() + pl:GetForward() * 40 - Vector(0, 0, 75)
			local tr = util.TraceLine({start=pos1, endpos=pos2, mask = MASK_SOLID_BRUSHONLY})

			pl:EmitSound("nox/earthquake.ogg")
			util.ScreenShake(tr.HitPos, 15, 5, 0.75, 500)
			local effectdata = EffectData()
				effectdata:SetOrigin(tr.HitPos)
			util.Effect("dust", effectdata)

			local ent = ents.Create("projectile_shockwave")
			if ent:IsValid() then
				ent:SetOwner(pl)
				ent:SetTeamID(pl:Team())
				ent:SetPos(pl:GetPos() + Vector(0, 0, ent.Radius + 1))
				ent:SetAngles(pl:GetAngles())
				ent:Spawn()
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(pl:GetForward())
				end
			end
		else
			return true
		end
	end)

	pl:GlobalCooldown(1.5)
	pl:GiveStatus("pacifism", 1.5)
end

function spells.Astra(pl, override)
	if pl:KeyDown(IN_USE) and not override then
		GenericHoming(pl, "Astra", true)
		return
	end

	pl:GiveStatus("astra")
end

function GenericHit.Astra(pl)
	spells.Astra(pl, true)
end

function spells.EvilEye(pl)
	if pl:GetStatus("evileye") then return true end

	pl:GiveStatus("evileye")
end

function spells.Rasp(pl)
	local ent = ents.Create("projectile_rasp")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:SetAngles(pl:GetAngles())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceCenter(pl:GetAimVector() * 700)
		end
	end
end

function spells.Ruin(pl)
	GenericHoming(pl, "Ruin")
end

function GenericHit.Ruin(pl, proj)
	local status = pl:GiveStatus("Ruin", 15)
	local owner = proj:GetOwner()
	if owner:IsValid() then
		pl:SetLastAttacker(owner)
	end
end

function spells.Petrify(pl)
	if pl:GetStatus("channelingpetrify") then return true end
	pl:StopIfOnGround()
	pl:GiveStatus("channelingpetrify", 3)
end

function spells.ThreadLightly(pl)
	local status = pl:GetStatus("invisibility")
	if status then
		local status = pl:GetStatus("treadlightly")
			if status then
				pl:RemoveStatus("treadlightly", false, true)
				return true
			else
				pl:GiveStatus("treadlightly")
			end
	else
		pl:CenterPrint("You must be invisible to use this ability.")
		return true
	end
end

function spells.Brute(pl)
	local pos = pl:EyePos()
	pl:Stun(1, true, true)
	pl:GiveStatus("pacifism", 1)
	util.ScreenShake(pos, 100, 0.1, 1.5, 480)
	status = pl:GiveStatus("brute", 10)
	pl:CustomGesture(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
end

--Spell Saber
function spells.SanguineBlade(pl)
	if pl:GetStatus("spellsaber_sanguineblade") then
		pl:RemoveStatus("spellsaber*", false, true)
		return true
	end

	pl:RemoveStatus("spellsaber*", false, true)
	pl:GiveStatus("spellsaber_sanguineblade")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE)
end

function spells.StormBlade(pl)
	if pl:GetStatus("spellsaber_stormblade") then
		pl:RemoveStatus("spellsaber*", false, true)
		return true
	end

	pl:RemoveStatus("spellsaber*", false, true)
	pl:GiveStatus("spellsaber_stormblade")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE)
end

function spells.FlameBlade(pl)
	if pl:GetStatus("spellsaber_flameblade") then
		pl:RemoveStatus("spellsaber*", false, true)
		return true
	end

	pl:RemoveStatus("spellsaber*", false, true)
	pl:GiveStatus("spellsaber_flameblade")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE)
end

function spells.NullBlade(pl)
	if pl:GetStatus("spellsaber_nullblade") then
		pl:RemoveStatus("spellsaber*", false, true)
		return true
	end

	pl:RemoveStatus("spellsaber*", false, true)
	pl:GiveStatus("spellsaber_nullblade")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE)
end

function spells.CorruptedBlade(pl)
	if pl:GetStatus("spellsaber_corruptblade") then
		pl:RemoveStatus("spellsaber*", false, true)
		return true
	end

	pl:RemoveStatus("spellsaber*", false, true)
	pl:GiveStatus("spellsaber_corruptblade")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE)
end

function spells.ShockwaveBlade(pl)
	if pl:GetStatus("spellsaber_shockblade") then
		pl:RemoveStatus("spellsaber*", false, true)
		return true
	end

	pl:RemoveStatus("spellsaber*", false, true)
	pl:GiveStatus("spellsaber_shockblade")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE)
end

function spells.FrostBlade(pl)
	if pl:GetStatus("spellsaber_frostblade") then
		pl:RemoveStatus("spellsaber*", false, true)
		return true
	end

	pl:RemoveStatus("spellsaber*", false, true)
	pl:GiveStatus("spellsaber_frostblade")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE)
end

function spells.SwordThrow(pl)
	for _, ent in pairs(ents.FindByClass("projectile_swordthrow")) do

		if pl:IsCarrying() then pl:LMR(30) return true end
		if not pl:CanTeleport() then pl:LMR(55) return true end

		if ent.OriginalOwner == pl then
			if ent:GetOwner() == pl then
				pl:GiveStatus("swordwarp")
			end
			return true
		end
	end

	pl:EmitSound("weapons/slam/throw.wav", 80, math.Rand(95, 105))
	local ent = ents.Create("projectile_swordthrow")
	if ent:IsValid() then
		ent.OriginalOwner = pl
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:Spawn()
		ent:SetAngles(Angle(pl:EyeAngles().pitch + 90,pl:EyeAngles().yaw,0))
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceCenter(pl:GetAimVector() * 700)
			phys:AddAngleVelocity(Vector(-2000,0,0))
		end
	end
	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_GRENADE)
	pl:RemoveStatus("weapon_spell_saber", false, true)
end

function spells.BladeSpirit(pl)
	if pl:GetStatus("blade_spirit") then
		if pl:GetStatus("blade_spirit"):GetBlades() == 3 then
			pl:LMR(36)
			return true
		else
			pl:GiveStatus("blade_spirit"):SetBlades(3)
		end
	else
		pl:GiveStatus("blade_spirit"):SetBlades(3)
	end
end

--Necromancer
function GenericHit.ManaSickness(pl, proj)
	pl:GiveStatus("manasickness", 10)
end

function spells.ManaSickness(pl)
	GenericHoming(pl, "ManaSickness")
end

function spells.FleshWound(pl)
	local soul = pl:FindNearbySoul()

	if !IsValid(soul) then pl:LMR(86) return true end

	local pos = soul:GetPos()

	local effectdata = EffectData()
		effectdata:SetOrigin( pos )
		effectdata:SetEntity( soul:GetOwner() or pl )
	util.Effect("soulexplosion", effectdata)

	soul:Remove()

	local e = EffectData()
		e:SetOrigin( pos )
		e:SetEntity( pl )
	util.Effect( "fleshwoundspawn", e)


	for _, ent in ipairs(ents.FindInSphere(pos, 350)) do
		if ent:IsPlayer() and ent:Alive() and TrueVisible(ent:NearestPoint(pos), pos) then
			if ent:Team() == pl:Team() then
				ent:GiveStatus("fleshwound", 30)
			end
		end
	end
end

function spells.ArcaneExplosion(pl, override)
	local mypos = pl:LocalToWorld(pl:OBBCenter())
	ExplosiveDamage(pl, mypos, 125, 125, 1, 0.3, 1, _G.DUMMY_ARCANEEXPLOSION, DMGTYPE_FIRE, true)

	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos() + vector_up*4)
		effectdata:SetNormal(vector_up)
	util.Effect("necroexplosion", effectdata)

	pl:CustomGesture(ACT_SIGNAL_HALT)
end

function spells.SoulExplosion(pl, override)

	local soul = pl:FindNearbySoul( 420 )

	if !IsValid(soul) then pl:LMR(86) return true end

	local pos = soul:GetPos()

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetEntity(soul:GetOwner() or pl)
	util.Effect("soulexplosion", effectdata)

	soul:Remove()

	ExplosiveDamage(pl, pos, 170, 170, 1, 0.66, 2, _G.DUMMY_SOULEXPLOSION, DMGTYPE_FIRE)
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(vector_up)
	util.Effect("rovercannonexplosion", effectdata)

	pl:CustomGesture(ACT_SIGNAL_FORWARD)

end

local function BloodWellTimer(pos, caster, teamid)
	for _, ent in pairs(ents.FindInSphere(pos, 190)) do
		if ent:IsPlayer() and ent:Alive() and TrueVisible(ent:NearestPoint(pos), pos) and ent:Team() == teamid then
			GAMEMODE:PlayerHeal(ent, caster, 1)
		end
	end
end

function spells.BloodWell(pl)
	if pl.ActiveBloodWell then pl:LMR(36) return true end

	local soul = pl:FindNearbySoul()

	if !IsValid(soul) then pl:LMR(86) return true end

	local pos = soul:GetPos()

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetEntity(soul:GetOwner() or pl)
	util.Effect("soulexplosion", effectdata)

	local e = EffectData()
		e:SetOrigin( pos )
		e:SetEntity( pl )
	util.Effect( "fleshwoundspawn", e)

	for _, ent in ipairs(ents.FindInSphere(pos, 350)) do
		if ent:IsPlayer() and ent:Alive() and TrueVisible(ent:NearestPoint(pos), pos) then
			if ent:Team() == pl:Team() then
				ent:GiveStatus("fleshwound", 15)
			end
		end
	end

	soul:Remove()

	local teamid = pl:Team()
	timer.Create("bloodwell"..pl:UniqueID()..CurTime(), 0.1, 50, function() BloodWellTimer(pos, pl, teamid) end)
	pl.ActiveBloodWell = true
	timer.Simple(5, function() pl.ActiveBloodWell = nil end)

	local effectdata = EffectData()
		effectdata:SetOrigin(pos+vector_up*25)
		effectdata:SetEntity(pl)
		effectdata:SetMagnitude(5)
	util.Effect("bloodwell", effectdata)

	pl:CustomGesture(ACT_SIGNAL_HALT)
end

local function PowerWellTimer(pos, caster, teamid)
	for _, ent in pairs(ents.FindInSphere(pos, 160)) do
		if ent:IsPlayer() and ent:Alive() and TrueVisible(ent:NearestPoint(pos), pos) then
			if ent:Team() != teamid then
				ent:TakeSpecialDamage(4, DMGTYPE_ARCANE, caster, _G.DUMMY_POWERWELL, ent:GetPos())
			end
		end
	end
end


function spells.PowerWell(pl)
	if pl.ActivePowerWell then pl:LMR(36) return true end

	local soul = pl:FindNearbySoul()

	if !IsValid(soul) then pl:LMR(86) return true end

	local pos = soul:GetPos()

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetEntity(soul:GetOwner() or pl)
	util.Effect("soulexplosion", effectdata)

	soul:Remove()

	local teamid = pl:Team()
	timer.Create("bloodwell"..pl:UniqueID()..CurTime(), 0.1, 60, function() PowerWellTimer(pos, pl, teamid) end)
	pl.ActivePowerWell = true
	timer.Simple(6, function() pl.ActivePowerWell = nil end)

	local effectdata = EffectData()
		effectdata:SetOrigin(pos+vector_up*30)
		effectdata:SetEntity(pl)
		effectdata:SetMagnitude(6)
	util.Effect("powerwell", effectdata)

	pl:CustomGesture(ACT_SIGNAL_HALT)
end

function spells.CursedSkulls(pl)
	for _, ent in pairs(ents.FindByClass("projectile_cursedskull")) do
		if ent:GetOwner() == pl then
			ent:Remove()
		end
	end

	local col = Color(185, 170, 45)
	for i = 1, 3 do
		local ent = ents.Create("projectile_cursedskull")
		if ent:IsValid() then
			ent:SetPos(pl:GetPos() + Vector(0, 0, 32) + VectorRand() * 16)
			ent:SetOwner(pl)
			ent:Spawn()
			ent:SetColor(col)
			ent:SetTeamID(pl:Team())
		end
	end

	pl:CustomGesture(ACT_GMOD_GESTURE_TAUNT_ZOMBIE)
	pl:EmitSound("npc/zombie/zombie_alert"..math.random(3)..".wav")
end

function spells.FistOfVengeance(pl)
	for _, ent in pairs(ents.FindByClass("projectile_fist")) do
		if ent:GetOwner() == pl then
			pl:LMR(36)
			return true
		end
	end

	local _start = pl:GetShootPos()
	local filt = ents.FindByClass("projectile_*")
	table.insert(filt, pl)

	local aimpos = util.TraceLine({start = _start, endpos = _start + pl:GetAimVector() * 1000, filter = filt, mask = MASK_SOLID}).HitPos
	local groundpos = util.TraceLine({start = aimpos, endpos = aimpos + Vector(0, 0, -10240), filter = filt, mask = MASK_SOLID}).HitPos

	local tr = util.TraceLine({start = groundpos, endpos = groundpos + Vector(0, 0, 1536), mask = MASK_SOLID_BRUSHONLY})
	if tr.Hit and not tr.HitSky then
		pl:LMR(63)
		return true
	end

	local ent = ents.Create("projectile_fist")
	if ent:IsValid() then
		ent:SetPos(tr.HitPos)
		ent:SetAngles(Angle(0, pl:GetAngles().yaw - 180, 0))
		ent:SetOwner(pl)
		ent.Destination = groundpos
		ent:SetTeamID(pl:Team())
		ent:SetColor(team.GetColor(pl:GetTeamID()))
		ent:Spawn()
	end
	sound.Play("nox/fistofvengeance.ogg", groundpos, 160, 100)
	pl:CustomGesture(ACT_SIGNAL_FORWARD)
end

function spells.ArrowVolley(pl)
	if pl:GetStatus("archerenchant_volley") then
		pl:RemoveStatus("archerenchant*", false, true)
		return true
	end

	pl:RemoveStatus("archerenchant*", false, true)
	pl:GiveStatus("archerenchant_volley")

	pl:CustomGesture(ACT_HL2MP_GESTURE_RANGE_ATTACK_CROSSBOW)
end

function spells.Protometeor(pl)
	for _, ent in pairs(ents.FindByClass("projectile_protometeor")) do
		if ent:GetOwner() == pl then
			pl:LMR(36)
			return true
		end
	end

	local pos = pl:GetPos()

	local startpos = {}

	local attempts = 5

	local declmax = 50
	local forw = pl:GetForward()
	local up = pl:GetUp()
	local vec = Vector(1, 1, 1) * 125
	local tr1 = {start = pos, mask = MASK_SOLID_BRUSHONLY}
	local tr2 = {mins = -vec, maxs = vec, mask = MASK_SOLID_BRUSHONLY}

	local xydir = forw:Angle()
	for i = 1, attempts do
		local ang = up:Angle()
		for j = 1, attempts do
			ang:RotateAroundAxis(-1 * xydir:Right(), declmax/attempts)

			local dir = ang:Forward()
			tr1.endpos = pos + dir * 100000
			local pretrace = util.TraceLine(tr1)
			if pretrace.Hit and pretrace.HitSky and pretrace.HitPos:Distance(pos) > 500 then
				tr2.start = pretrace.HitPos + -dir * 250
				tr2.endpos = pos + dir * 210
				local trace = util.TraceHull(tr2)

				if not trace.Hit then
					table.insert(startpos, pretrace.HitPos)
					if DEBUG then
						dur = 10
						debugoverlay.Line(tr1.start, pretrace.HitPos, dur, COLOR_YELLOW, true)
						debugoverlay.Box(tr2.start, -vec, vec, dur, COLOR_RED, true)
						debugoverlay.Box(tr2.endpos, -vec, vec, dur, COLOR_RED, true)
					end
				end
			end
		end
		xydir:RotateAroundAxis(up, 360/attempts)
	end

	if #startpos > 0 then
		local start = table.Random(startpos)
		local dir = (pos - start):GetNormal()
		local dist = start:Distance(pos)

		local speed = dist/3.5

		local ent = ents.Create("projectile_protometeor")
		if ent:IsValid() then
			ent:SetOwner(pl)
			ent:SetTeamID(pl:GetTeamID())
			ent:SetPos(start)
			ent:SetAngles(dir:Angle())
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(dir * speed)
			end
		end

		pl:CustomGesture(ACT_SIGNAL_HALT)
	else
		pl:LMR(63)
		return true
	end
end

function spells.Death(pl)
	local radius = 100
	local effectdata = EffectData()
		effectdata:SetEntity(pl)
		effectdata:SetMagnitude(radius)
	util.Effect("deathcloud", effectdata)

	local targets = {}
	for _, ent in pairs(ents.FindInSphere(pl:GetCenter(), 150)) do
		if ent:IsValid() and ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= pl:GetTeamID() and TrueVisible(pl:GetCenter(), ent:GetCenter()) and ent:Health() < math.ceil(ent:GetMaxHealth()/4) then
			table.insert(targets, ent)
		end
	end

	if #targets > 0 then
		for _, target in pairs(targets) do
			local health = target:Health()

			target:RemoveAllStatus(false, false, false)
			target:TakeSpecialDamage(health, DMGTYPE_GENERIC, pl, DUMMY_DEATH)

			local effectdata = EffectData()
				effectdata:SetOrigin(target:GetPos())
				effectdata:SetStart(pl:GetPos())
			util.Effect("death", effectdata)

			GAMEMODE:PlayerHeal(pl, pl, health * 2)
		end
	else
		pl:LMR(89)
	end
end

function spells.Voidwalk(pl)
	if not pl:OnGround() or pl:IsAnchored() or pl:GetStatus("stun") or pl:GetStatus("stun_noeffect") then return true end

	if pl:IsCarrying() then
		pl:LM(90)
		return true
	end

	local eyeang = pl:EyeAngles()
	eyeang.pitch = 0
	eyeang.roll = 0
	local dir = Vector(0, 0, 0)
	if pl:KeyDown(IN_FORWARD) then dir = dir + eyeang:Forward() end
	if pl:KeyDown(IN_BACK) then dir = dir - eyeang:Forward() end
	if pl:KeyDown(IN_MOVERIGHT) then dir = dir + eyeang:Right() end
	if pl:KeyDown(IN_MOVELEFT) then dir = dir - eyeang:Right() end
	dir:Normalize()
	if dir == vector_origin then dir = eyeang:Forward() end

	dir = dir:Angle()

	pl:GiveStatus("voidwalk", .75):SetDir(dir)
end

function spells.Leap(pl)
	if not pl:OnGround() then return true end

	if pl:IsCarrying() or pl:IsAnchored() then
		pl:LM(65)
		return true
	end

	pl:ResetLuaAnimation("WARRIOR_LEAP")
	timer.Simple(.3, function()
		if pl:IsValid() then pl:GiveStatus("leap") end
	end)
end

function spells.Shadowstorm(pl)
	if not pl:OnGround() then return true end

	local ent = ents.Create("shadowstorm")
	if ent:IsValid() then
		ent:SetPos(pl:GetPos())
		ent:SetOwner(pl)
		ent:SetTeamID(pl:GetTeamID())
		ent:Spawn()
		ent:Fire("kill", "", 6)
	end
end

function spells.NetherBomb(pl)
	for _, ent in pairs(ents.FindByClass("netherbomb")) do
		if ent:GetOwner() == pl then
			ent:Detonate()
			return
		end
	end

	local eyepos = pl:EyePos()
	local dir = pl:GetAimVector()
	local tr = util.TraceLine({start = eyepos, endpos = eyepos + dir * 70, filter = pl, mask = MASK_PLAYERSOLID})
	if tr.Hit and not tr.Entity:IsPlayer() and tr.Entity:GetClass() ~= "flag_htf" and tr.Entity:GetClass() ~= "flag" then
		local spawns = ents.FindByClass("info_player*")
		table.Add(spawns, ents.FindByClass("prop_spawnpoint"))
		table.Add(spawns, ents.FindByClass("gmod_player_start"))
		for _, ent in pairs(spawns) do
			if ent:GetPos():Distance(pl:GetPos()) <= 125 then pl:LM(92) return true end
		end

		timer.Create(pl:UniqueID().."DoNetherBomb", 2, 1, function() PlantNetherBomb(pl, pl:UniqueID()) end)
		pl:Slow(2, true)
		pl:GiveStatus("weight", 2)
		pl:GiveStatus("pacifism", 2)
		pl:LM(93)
		pl:CustomGesture(ACT_GMOD_GESTURE_ITEM_PLACE)
	else
		pl:LM(91)
	end

	return true
end

function PlantNetherBomb(pl, uid)
	if not (pl:IsValid() and pl:Alive()) then return end

	local eyepos = pl:EyePos()
	local dir = pl:GetAimVector()
	local tr = util.TraceLine({start = eyepos, endpos = eyepos + dir * 70, filter = pl, mask = MASK_PLAYERSOLID})
	if tr.Hit and not tr.Entity:IsPlayer() and tr.Entity:GetClass() ~= "flag_htf" and tr.Entity:GetClass() ~= "flag" then
		local spawns = ents.FindByClass("info_player*")
		table.Add(spawns, ents.FindByClass("prop_spawnpoint"))
		table.Add(spawns, ents.FindByClass("gmod_player_start"))
		for _, ent in pairs(spawns) do
			if ent:GetPos():Distance(pl:GetPos()) <= 125 then pl:LM(92) return true end
		end

		pl:LM(94)
		local ent = ents.Create("netherbomb")
		if ent:IsValid() then
			ent:SetPos(tr.HitPos - dir * 5)
			ent:SetOwner(pl)
			ent:SetTeamID(pl:GetTeamID())
			ent:SetAttach(tr.Entity)
			ent:SetNormal(tr.HitNormal)
			if not tr.HitWorld then ent:SetParent(tr.Entity) end
			ent:Spawn()
		end
	else
		pl:LM(91)
	end
end

function spells.DragoonDash(pl)
	if pl:GetStatus("stun") or pl:GetStatus("stun_noeffect") or pl:IsCarrying() then return true end

	pl:GiveStatus("dragoondash", 5)
end

function spells.DragonBlood(pl)
	pl:StopIfOnGround()
	pl:GiveStatus("dragonbloodchannel")
end

function spells.FieryTalon(pl)
	pl:ResetLuaAnimation("FIERYTALON")
	for i=1,5 do
		local aimvec = pl:EyeAngles():Forward() * 1500 - pl:EyeAngles():Right() * (240 - 80 * i)

		local ent = ents.Create("projectile_burn")
		if ent:IsValid() then
			ent:SetOwner(pl)
			ent:SetPos(pl:GetShootPos())
			ent:SetTeamID(pl:Team())
			ent:SetColor(team.GetColor(pl:GetTeamID()))
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(aimvec)
			end
		end
	end
end

function spells.Discharge(pl)
	local ent = ents.Create("projectile_discharge")
	if ent:IsValid() then
		ent:SetOwner(pl)
		ent:SetTeamID(pl:Team())
		ent:SetPos(pl:GetShootPos())
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:ApplyForceCenter(pl:GetAimVector() * 1100)
		end
	end
end
