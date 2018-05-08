AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_c17/canister_propane01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
	end

	local myteam = self:GetTeamID()
	local col = team.TeamInfo[myteam].Color
	self:SetColor(Color(col.r, col.g, col.b, 255))

	self:SetName(myteam)
	team.SetScore(myteam, CORE_HEALTH)

	self.NextDamageEffect = 0
	self.NextMsg = 0
	self.CoreHealth = CORE_HEALTH
	self:Fire("heal", "", CORE_HEAL_TIME)
	self.WarningHealth = CORE_HEALTH * 0.005
	self.ManaStorage = 0
	self.MaxManaStorage = CORE_MAX_MANA

	local effect2 = ents.Create("point_tesla")
	if effect2:IsValid() then
		effect2:SetKeyValue("m_flRadius", "250")
		effect2:SetKeyValue("m_SoundName", "DoSpark")
		effect2:SetKeyValue("m_Color", col.r.." "..col.g.." "..col.b)
		effect2:SetKeyValue("texture", "effects/laser1.vmt")
		effect2:SetKeyValue("beamcount_min", "6")
		effect2:SetKeyValue("beamcount_max", "10")
		effect2:SetKeyValue("thick_min", "20")
		effect2:SetKeyValue("thick_max", "50")
		effect2:SetKeyValue("lifetime_min", "0.5")
		effect2:SetKeyValue("lifetime_max", "1")
		effect2:SetKeyValue("interval_min", "0.1")
		effect2:SetKeyValue("interval_max", "0.25")
		effect2:SetPos(self:GetPos() + Vector(0, 0, 75))
		effect2:Spawn()
		effect2:SetParent(self)
		self.Tesla = effect2
	end

	self:SetImmunity(120)

	self.Think = nil
end

function ENT:AcceptInput(name, activator, caller)
	if name == "heal" then
		self:Fire("heal", "", CORE_HEAL_TIME)
		if self.CoreHealth > 0 then
			if OVERTIME then
				self.CoreHealth = math.max(1, self.CoreHealth - CORE_OVERTIME_DAMAGE)
			else
				self.CoreHealth = math.min(CORE_HEALTH, self.CoreHealth + CORE_HEAL)
			end

			team.SetScore(self:GetTeamID(), self.CoreHealth)
			local col = team.GetColor(self:GetTeamID())
			local brit = self.CoreHealth / CORE_HEALTH
			self:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), 255))
		end

		return true
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:ManaReceived(from, amount)
	if OVERTIME then return true end

	if 0 < self.ManaStorage then
		self:SetMaterial("models/shiny")
	end
	SetGlobalInt("shield"..self:GetTeamID(), self.ManaStorage)
end

function ENT:Spark()
	self.Tesla:Fire("DoSpark", "", 0.1)
	self.Tesla:Fire("DoSpark", "", 0.3)
	self.Tesla:Fire("DoSpark", "", 0.5)
end

local Slaves = {}
function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	local immunity = self:GetImmunity() - CurTime()
	if not (attacker == NULL and inflictor == NULL) and self.Destroyed or attacker:GetTeamID() == self:GetTeamID() or immunity > 0 then return end

	inflictor = inflictor or attacker or self
	if inflictor:IsPlayer() then
		local wep = inflictor:GetActiveWeapon()
		if wep:IsValid() then inflictor = wep end
	end

	local damage = dmginfo:GetDamage()
	local dmgtype = dmginfo:GetDamageType()

	if dmgtype == DMGTYPE_POISON then return end

	if dmgtype == DMGTYPE_FIRE or dmgtype == DMGTYPE_SHOCK then
		damage = damage * 1.5
	elseif dmgtype == DMGTYPE_ICE then
		damage = damage * 0.5
	end

	local pierces = inflictor.ScriptVehicle or inflictor.DamagesCore or attacker == self

	if not pierces then
		damage = damage * 0.6666
	end

	damage = math.ceil(damage)

	local myteam = self:GetTeamID()
	local myteammembers = team.NumPlayers(myteam)

	if 0 < self.ManaStorage then
		local todrain = math.min(self.ManaStorage, damage)
		self.ManaStorage = math.max(0, self.ManaStorage - damage)
		damage = damage - todrain
		if self.ManaStorage <= 0 then
			self:SetMaterial("")
		end
		SetGlobalInt("shield"..myteam, self.ManaStorage)
	end

	if damage <= 0 then return end

	if self.CoreHealth <= damage then
		self:SetColor(Color(0, 0, 0, 255))
		self.CoreHealth = 0
		team.SetScore(myteam, 0)
		self.Destroyed = true

		if myteammembers > 0 and attacker.AssaultCoresDestroyed then
			attacker:AddPKV("AssaultCoresDestroyed", 1)
			attacker:AddOffense(5)
			attacker:PrintMessage(HUD_PRINTTALK, "You delivered the final blow to the enemy Core!")

			if NDB then
				attacker:AddSilver(BONUS_CORE_DESTROYED)
			end
		end

		local effectdata = EffectData()
			effectdata:SetRadius(1)
			effectdata:SetMagnitude(1)
			effectdata:SetScale(1)
			effectdata:SetOrigin(self:GetPos())
		util.Effect("FireBombExplosion", effectdata, true, true)

		function self:Think()
		end

		if #TEAMS_PLAYING == 2 then
			for k, v in pairs(TEAMS_PLAYING) do
				if v ~= myteam then
					GAMEMODE:EndGame(v, Slaves)
					return
				end
			end
		else
			GAMEMODE:CenterPrintAll("The "..team.GetName(myteam).." core has been destroyed!")

			for _, ent in pairs(ents.GetAll()) do
				if ent.PHealth and ent:GetTeamID() == myteam then
					ent:Remove()
				end
			end

			for k, v in ipairs(TEAMS_PLAYING) do
				if v == myteam then
					table.remove(TEAMS_PLAYING, k)
					break
				end
			end
			BroadcastLua("TEAMS_PLAYING={"..table.concat(TEAMS_PLAYING, ",").."}")
			for _, pl in pairs(player.GetAll()) do
				if pl:Team() == myteam then
					pl:JoinBalancedTeam(true) --pl:JoinLeastPopulatedTeam()
					pl:ForceRespawn()
					pl:PrintMessage(HUD_PRINTTALK, "Your team has been eliminated. You are now a slave of the "..team.GetName(pl:Team()).." team!")
					Slaves[pl:SteamID()] = true
				end
			end
		end
	else
		self.CoreHealth = math.ceil(self.CoreHealth - damage)
		team.SetScore(myteam, self.CoreHealth)
		local col = team.GetColor(myteam)
		local brit = self.CoreHealth / CORE_HEALTH
		self:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), 255))

		if math.ceil(self.CoreHealth * 0.005) < self.WarningHealth then
			self.WarningHealth = math.ceil(self.CoreHealth * 0.005)
			local message = "Your core is at "..math.ceil(self.CoreHealth * 0.01).."% health!"
			for _, pl in pairs(team.GetPlayers(myteam)) do
				pl:CenterPrint(message, "COLOR_RED", 3)
			end
		end

		if self.NextDamageEffect < CurTime() then
			self.NextDamageEffect = CurTime() + math.Rand(2, 3.5)
			self:Spark()
		end
	end
end
