local meta = FindMetaTable("Player")
if not meta then return end

meta.OldFreeze = meta.Freeze
meta.OldSetTeam = meta.SetTeam

function meta:RemoveInvisibility()
	if self.status_invisibility and self.status_invisibility:IsValid() then
		self.status_invisibility:Remove()
	end
end

function meta:GiveInvisibility()
	if self.status_invisibility and self.status_invisibility:IsValid() or self:IsCarrying() then return false end

	self:GiveStatus("invisibility")

	return true
end

function meta:Think()
	if CurTime() >= self.NextHealthRegen and CurTime() >= self.LastDamaged + 4 and self:Alive() and self:Health() < self:GetMaxHealth() and not self:IsCarrying() then
		self.NextHealthRegen = CurTime() + 1
		self:SetHealth(self:Health() + 1)
	end
end

function meta:CustomGesture(gesture)
	if not gesture then return end
	--self:DoAnimationEvent(gesture)
	self:AnimRestartGesture(GESTURE_SLOT_CUSTOM, gesture, true)
	umsg.Start("cusges")
		umsg.Entity(self)
		umsg.Short(gesture)
	umsg.End()
end

function meta:SendSound(snd)
	self:SendLua("surface.PlaySound(\""..snd.."\")")
end

function meta:CenterPrint(message, color, lifetime)
	self:SendLua(string.format("GAMEMODE:CenterPrint(%q,%s,%i)", message or "", color or "nil", lifetime or 5))
end

function meta:FixModelAngles(velocity)
	local eye = self:EyeAngles()
	self:SetLocalAngles(eye)
	self:SetPoseParameter("move_yaw", math.NormalizeAngle(velocity:Angle().yaw - eye.y))
end

local function teamsort(a, b)
	local numa, numb = team.NumPlayers(a), team.NumPlayers(b)

	if numa == numb then
		return team.TotalFrags(a) < team.TotalFrags(b)
	end

	return numa < numb or numa < numb + 1 and team.TotalFrags(a) <= team.TotalFrags(b) - 100
end

function meta:JoinBalancedTeam(override)
	if not override then
		local previd = GAMEMODE.TeamLocks[self:UniqueID()]
		if previd then
			self:SetTeam(previd)
			return
		end
	end

	local sortedteams = table.Copy(TEAMS_PLAYING)
	table.sort(sortedteams, teamsort)

	self:SetTeam(sortedteams[1])
end

function meta:TeamValue()
	return math.max(   0.2, (self.CTFKills or 0) / math.max(self.CTFDeaths or 1, 1) + ((self.AssaultWins or 0) / math.max(1, self.AssaultLosses or 1)) * 2  )
end

function meta:Channeling(tim)
	local status = self:GiveStatus("channeling", tim)
	if IsValid(status) then
		status:SetDieTime(CurTime() + tim)
	end
end

function meta:GlobalCooldown(tim)
	local status = self:GiveStatus("globalcooldown", tim)
	if IsValid(status) then
		status:SetDieTime(CurTime() + tim)
	end
end

function meta:SoftFreeze(tim)
	local status = self:GiveStatus("frozen", tim)
	if IsValid(status) then
		status:SetDieTime(CurTime() + tim)
	end
end

function meta:Slow(tim, noeffect)
	local status = self:GiveStatus(noeffect and "slow_noeffect" or "slow", tim)
	if IsValid(status) then
		status:SetDieTime(CurTime() + tim)
	end
end

function meta:Stun(tim, force, noeffect)
	if not force and self:GetPlayerClassTable().NoStun then
		self:Slow(tim)
		return
	end

	local status = self:GiveStatus(noeffect and "stun_noeffect" or "stun", tim)
	if IsValid(status) then
		status:SetDieTime(CurTime() + tim)
	end
end

function meta:ManaStun(tim, force)
	if force or 0 < self:GetManaRegeneration() then
		local status = self:GiveStatus("manastun", tim)
		if IsValid(status) then
			status:SetColor(Color(tim, 255, 255, 255))
			status:SetDieTime(CurTime() + tim)
		end
	end
end

local function nocollidetimer(self, timername)
	for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if e:IsPlayer() and e ~= self and GAMEMODE:ShouldCollide(self, e) then
			return
		end
	end

	self:SetCollisionGroup(COLLISION_GROUP_PLAYER)
	timer.Destroy(timername)
end

function meta:TemporaryNoCollide()
	if self:GetCollisionGroup() ~= COLLISION_GROUP_PLAYER then return end

	for _, e in pairs(ents.FindInBox(self:WorldSpaceAABB())) do
		if e:IsPlayer() and e ~= self and GAMEMODE:ShouldCollide(self, e) then
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)

			local timername = "TemporaryNoCollide"..self:UniqueID()
			timer.Create(timername, 0, 0, function() nocollidetimer(self, timername) end)

			return
		end
	end
end

if not meta.OldDrawViewModel then
	meta.OldDrawViewModel = meta.DrawViewModel
	meta.OldDrawWorldModel = meta.DrawWorldModel

	local function OldDrawViewModel(self, bDraw)
		if self:IsValid() then
			self:OldDrawViewModel(bDraw)
		end
	end

	function meta:DrawViewModel(bDraw)
		self.m_DrawViewModel = bDraw
		timer.Simple(0, function() OldDrawViewModel(self, bDraw) end)
	end

	local function OldDrawWorldModel(self, bDraw)
		if self:IsValid() then
			self:OldDrawWorldModel(bDraw)
		end
	end

	function meta:DrawWorldModel(bDraw)
		self.m_DrawWorldModel = bDraw
		timer.Simple(0, function() OldDrawWorldModel(self, bDraw) end)
	end

	function meta:GetDrawViewModel()
		return self.m_DrawViewModel
	end

	function meta:GetDrawWorldModel()
		return self.m_DrawWorldModel
	end
end

function meta:TriggerAegis(from)
	local ent = self.status_aegis
	if ent and ent:IsValid() and ent:GetCounter() > 0 then
		ent:SetCounter(ent:GetCounter() - 1)
		ent:CreateSpike(from and from:IsValid() and self:NearestPoint(from:LocalToWorld(from:OBBCenter())) or self:LocalToWorld(self:OBBCenter()))
		return true
	end

	return false
end

function meta:IsFrozen()
	return self.m_IsFrozen
end

function meta:Freeze(bFreeze)
	self.m_IsFrozen = bFreeze
	self:OldFreeze(bFreeze)
end

function meta:SetTeamID(iTeam)
	self:SetTeam(iTeam)
end

function meta:SetTeam(id)
	self:OldSetTeam(id)
	if table.HasValue(TEAMS_PLAYING, id) then
		GAMEMODE.TeamLocks[self:UniqueID()] = id
	end
end

function meta:LMR(int, args)
	umsg.Start("lmr", self)
		umsg.Short(int)
		umsg.String(args or "")
	umsg.End()
end

function meta:LMG(int, args)
	umsg.Start("lmg", self)
		umsg.Short(int)
		umsg.String(args or "")
	umsg.End()
end

function meta:LM(int, args)
	umsg.Start("lm", self)
		umsg.Short(int)
		umsg.String(args or "")
	umsg.End()
end

function meta:SendLocalPlayerSpawn()
	umsg.Start("sp", self)
		umsg.Short(self:GetPlayerClass())
	umsg.End()
end

function meta:SetLastAttacker(attacker)
	if attacker ~= self.LastAttacker then
		self.LastAttacker2 = self.LastAttacker
		self.LastAttacked2 = self.LastAttacked
	end
	if attacker ~= self then
		self.LastAttacker = attacker
		self.LastAttacked = CurTime()
	end
end

function meta:GetLastAttacker()
	return self.LastAttacker, self.LastAttacked, self.LastAttacker2, self.LastAttacked2
end

function meta:ClearLastAttacker()
	self.LastAttacker = NULL
	self.LastAttacked = 0
	self.LastAttacker2 = NULL
	self.LastAttacked2 = 0
end

function meta:RemoveAllStatus(bSilent, bInstant, sHostile)
	if bInstant then
		for _, ent in pairs(ents.FindByClass("status_*")) do
			if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
				if sHostile and ent.Hostile then
					ent:Remove()
				elseif not sHostile then
					ent:Remove()
				end
			end
		end
	else
		for _, ent in pairs(ents.FindByClass("status_*")) do
			if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
				if sHostile and ent.Hostile then
					ent.SilentRemove = bSilent
					ent:SetDieTime(1)
				elseif not sHostile then
					ent.SilentRemove = bSilent
					ent:SetDieTime(1)
				end
			end
		end
	end
end

function meta:RemoveStatus(sType, bSilent, bInstant, sExclude)
	local removed = false

	for _, ent in pairs(ents.FindByClass("status_"..sType)) do
		if ent:GetOwner() == self and not (sExclude and string.sub(ent:GetClass(), 1, #("status_"..sExclude)) == "status_"..sExclude) then
			if bInstant then
				ent:Remove()
			else
				ent.SilentRemove = bSilent
				ent:SetDieTime(1)
			end
			removed = true
		end
	end

	return removed
end

function meta:GetStatus(sType)
	local ent = self["status_"..sType]
	if ent and ent:IsValid() and ent.Owner == self then
		return ent
	else
		return false
	end
end

function meta:GetAllStatuses(onlyHostile)
	local statuses = {}
	
	for _, ent in pairs(ents.FindByClass("status_*")) do
		if not ent.NoRemoveOnDeath and ent:GetOwner() == self then
			if onlyHostile then
				if ent.Hostile then table.insert(statuses, ent) end
			else
				table.insert(statuses, ent)
			end
		
		end
	end
	
	return statuses
end

function meta:GiveStatus(sType, fDie)
	local cur = self:GetStatus(sType)
	if cur then
		if fDie then
			cur:SetDieTime(CurTime() + fDie)
		end
		cur:SetPlayer(self, true)
		return cur
	else
		local ent = ents.Create("status_"..sType)
		if self:StatusWeaponHook("StatusImmunity", ent) then
			ent:Remove()
			return
		end
		if ent:IsValid() then
			ent:Spawn()
			if fDie then
				ent:SetDieTime(CurTime() + fDie)
			end
			ent:SetPlayer(self)
			return ent
		end
	end
end

function meta:TeamWeight()
	if NDB then
		return math.min(8000, (self.CTFKills / math.max(1, self.CTFDeaths)) * self.CTFKills + (self.AssaultWins / math.max(1, self.AssaultLosses)) * self.AssaultWins * 50 + self.AssaultDefense + self.AssaultOffense) * 0.5
	end

	return 1
end

function meta:IsPoisoned()
	return timer.Exists(self:UniqueID().."Poisoned")
end

function meta:Poison(ticks, delay, override)
	if not self:Alive() or self:IsPoisoned() and not override or self.ProtectFromPoison or self:GetPlayerClassTable().PoisonImmune then return end

	ticks = ticks or 8
	delay = delay or 2

	self.PoisonCount = math.max(ticks, self.PoisonCount or 0)
	local timername = self:UniqueID().."Poisoned"
	timer.Create(timername, delay, 0, function() DoPoison(self, timername) end)

	self:EmitSound("nox/poisonon.ogg")

	self:DI(NameToSpell.Poison, ticks * delay)
end
GM:AddLifeStatusTimer("Poisoned")

function meta:CurePoison()
	self:DI(NameToSpell.Poison, 0)
	self:EmitSound("nox/heal.ogg")

	if self:GetStatus("venom") then self:RemoveStatus("venom") end
	timer.Destroy(self:UniqueID().."Poisoned")
end

function meta:ProcessDamage(attacker, inflictor, dmginfo)
	if not GAMEMODE:PlayerShouldTakeDamage(self, attacker) then dmginfo:SetDamage(0) return end
	
	if self:IsPlayer() and self:InVehicle() then
		dmginfo:ScaleDamage(0.6666)
	end

	self:StatusWeaponHook("ProcessDamage", attacker, inflictor, dmginfo)

	if attacker:IsPlayer() and attacker ~= self then
		if attacker:GetStatus("vampirism") then
			attacker:SetHealth(math.min(attacker:GetMaxHealth(), attacker:Health() + dmginfo:GetDamage() * 0.5))
			if 14 < dmginfo:GetDamage() then
				attacker:EmitSound("npc/waste_scanner/grenade_fire.wav", 80, 120)
			end
			local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
				effectdata:SetStart(attacker:GetPos())
			util.Effect("greaterheal", effectdata)
		end
		
		if attacker:GetStatus("spellsaber_sanguineblade") and attacker:GetMana() >= 25 then
			if inflictor:GetClass() == "weapon_melee_spellsaber" or inflictor:GetClass() == "projectile_swordthrow" then
				attacker:GetWeapon("weapon_melee_spellsaber").VampPool = attacker:GetWeapon("weapon_melee_spellsaber").VampPool + dmginfo:GetDamage()
				local effectdata = EffectData()
					effectdata:SetOrigin(self:GetPos())
					effectdata:SetStart(attacker:GetPos())
				util.Effect("greaterheal", effectdata)
			end
		end
		
		if attacker:IsPlayer() and inflictor:GetClass() == "projectile_vampiricarrow" and attacker ~= self then
			local damage = dmginfo:GetDamage()
			
			local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
				effectdata:SetStart(attacker:GetPos())
			util.Effect("greaterheal", effectdata)

			attacker:SetHealth(math.min(attacker:GetMaxHealth(), attacker:Health() + damage))
		end
	end

	self:StatusWeaponHook("PostProcessDamage", attacker, inflictor, dmginfo)
end

function meta:DI(spellid, ttime)
	umsg.Start("DI", self)
		umsg.Short(spellid)
		umsg.Float(ttime)
	umsg.End()
end

function meta:IsCarrying()
	return self.Carrying
end

function meta:ForceRespawn()
	self:StripWeapons()

	self.LastDeath = CurTime()
	self:RemoveAllStatus(true, true)
	self:Spawn()
	self.SpawnTime = CurTime()
end

function meta:BloodSpray(pos, num, dir, force)
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetMagnitude(num)
		effectdata:SetRadius(self.BloodDye or 0)
		effectdata:SetNormal(dir)
		effectdata:SetScale(force)
		effectdata:SetEntity(self)
	util.Effect("bloodstream", effectdata, true, true)
end

function meta:Gib(dmginfo)
	self.Gibbed = true
	local effectdata = EffectData()
		effectdata:SetEntity(self)
		effectdata:SetOrigin(self:EyePos())
		if dmginfo then
			effectdata:SetScale(dmginfo:GetDamageType())
		end
		effectdata:SetRadius(self.BloodDye or 0)
	util.Effect("gib_player", effectdata, true, true)
end

local OffenseAwards = {}
OffenseAwards[30] = "Copper_Offense"
OffenseAwards[60] = "Iron_Offense"
OffenseAwards[100] = "Steel_Offense"
OffenseAwards[150] = "Titanium_Offense"
OffenseAwards[175] = "Diamond_Offense"
OffenseAwards[250] = "Ultimate_Offense"

function meta:AddOffense(amount)
	local newdef = self.OffenseThisRound + amount
	self.OffenseThisRound = newdef
	if NDB then
		self:AddPKV("AssaultOffense", amount)
	end

	--self:SetNetworkedString("tpstats", self.KillsThisRound.."@"..self.AssistsThisRound.."@"..self.OffenseThisRound.."@"..self.DefenseThisRound)

	if NDB then
		for amount, award in pairs(OffenseAwards) do
			if amount <= newdef then
				if not self:HasAward(award) then
					NDB.GiveAward(self, award)
				end
			end
		end
	end
end

local DefenseAwards = {}
DefenseAwards[10] = "Copper_Defense"
DefenseAwards[20] = "Iron_Defense"
DefenseAwards[35] = "Steel_Defense"
DefenseAwards[50] = "Titanium_Defense"
DefenseAwards[75] = "Diamond_Defense"
DefenseAwards[100] = "Ultimate_Defense"

function meta:AddDefense(amount)
	local newdef = self.DefenseThisRound + amount
	self.DefenseThisRound = newdef
	self:SetNetworkedString("tpstats", self.KillsThisRound.."@"..self.AssistsThisRound.."@"..self.OffenseThisRound.."@"..self.DefenseThisRound)

	if NDB then
		self:AddPKV("AssaultDefense", amount)
		for amount, award in pairs(DefenseAwards) do
			if amount <= newdef then
				if not self:HasAward(award) then
					NDB.GiveAward(self, award)
				end
			end
		end
	end
end

function meta:AddAssists(amount)
	local newdef = self.AssistsThisRound + amount
	self.AssistsThisRound = newdef
	if NDB then
		self:AddPKV("TeamPlayAssists", amount)
	end

	self:SetNetworkedString("tpstats", self.KillsThisRound.."@"..self.AssistsThisRound.."@"..self.OffenseThisRound.."@"..self.DefenseThisRound)
end

function meta:AddKills(amount)
	local newdef = self.KillsThisRound + amount
	self.KillsThisRound = newdef
	if NDB then
		self:AddPKV("CTFKills", amount)
	end

	self:SetNetworkedString("tpstats", self.KillsThisRound.."@"..self.AssistsThisRound.."@"..self.OffenseThisRound.."@"..self.DefenseThisRound)
end

--Necromancer stuff
function meta:CreateSoul()
	local s = ents.Create( "soul" )
		s:SetPos( self:GetPos() + vector_up * 25 )
		s:SetOwner( self )
	s:Spawn()
end

function meta:FindNearbySoul( dist )
	local mypos = self:LocalToWorld(self:OBBCenter())
	for _, ent in pairs(ents.FindInSphere(mypos, dist or 325)) do
		local nearest = ent:NearestPoint(mypos)
		if IsValid(ent) and ent:GetClass() == "soul" then
			return ent
		end
	end
end