function PROPGENERICREMOVALTHINK(self)
	GAMEMODE:RemoveProp(NULL, self)
end

function VEHICLEGENERICPROCESSDAMAGE(self, attacker, inflictor, dmginfo)
	if attacker:IsValid() and attacker:GetTeamID() == self:GetTeamID() and attacker ~= self then return end

	local damage = dmginfo:GetDamage()
	local dmgtype = dmginfo:GetDamageType()

	if dmgtype == DMGTYPE_POISON then return end

	if dmgtype ~= DMGTYPE_GENERIC and dmgtype ~= DMGTYPE_IMPACT then
		self.IgnoreDamageTime = CurTime()
	end

	if dmgtype == DMGTYPE_FIRE then
		damage = damage * 2
	end

	if attacker:IsValid() then
		self.LastAttacked = CurTime()
		self.Attacker = attacker
	end
	self.Inflictor = inflictor

	local newhealth = self:GetVHealth() - damage
	self:SetVHealth(newhealth)

	local driver = self.PilotSeat:GetDriver()
	if driver:IsValid() then
		driver.LastAttacker = attacker
		driver.LastAttacked = CurTime()
	end

	if newhealth <= 0 then
		if attacker:IsValid() then
			self.Attacker = attacker
		end
		self.Inflictor = inflictor
		self.DoDestroy = true
	elseif newhealth < self.MaxHealth * 0.3 and not self.Ignited then
		local effectdata = EffectData()
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(1)
		for i=1, math.random(1, 2) do
			local pos = self:GetPos() + VectorRand() * 32
			local ent = ents.Create("env_fire_trail")
			if ent:IsValid() then
				ent:SetPos(pos)
				ent:Spawn()
				ent:SetParent(self)
				effectdata:SetOrigin(pos)
				util.Effect("Explosion", effectdata)
			end
		end
		self.Ignited = true
	end
end

function PROPGENERICPROCESSDAMAGE(self, attacker, inflictor, dmginfo)
	local myteam = self:GetTeamID()
	if self.Gone or attacker:GetTeamID() == myteam then return end

	local damage = dmginfo:GetDamage()
	local dmgtype = dmginfo:GetDamageType()

	if dmgtype then
		local resistancetable = self.ResistanceTable
		if resistancetable and resistancetable[dmgtype] then
			damage = damage * resistancetable[dmgtype]
		end
	end

	if self.Destroyed then
		damage = damage * 1.5
	else
		local magusshield = self.MagusShield
		if magusshield and magusshield:IsValid() and magusshield:GetTeamID() == myteam then
			local absorbdamage = damage * 0.85
			damage = damage * 0.15

			local manausage = math.min(absorbdamage, magusshield.ManaStorage)
			absorbdamage = absorbdamage - manausage

			local healthusage = math.min(absorbdamage, magusshield.PHealth)
			absorbdamage = absorbdamage - healthusage

			magusshield.ManaStorage = math.floor(magusshield.ManaStorage - manausage)

			if 0 < healthusage then
				magusshield:TakeDamage(healthusage, attacker, inflictor)
			end
		end
	end

	if self.Gone then return end

	self.LastTakeDamage = CurTime()

	if self.PHealth <= damage then
		if attacker.AssaultOffense and not self.Destroyed then
			if self.OffenseBonus then
				attacker:AddOffense(self.OffenseBonus)
			end
			if NDB and self.MoneyBonus then
				attacker:AddSilver(self.MoneyBonus)
			end
			if self.FragsBonus then
				attacker:AddFrags(3)
			end
		end

		self.PHealth = 0
		self.Destroyed = true
		self.Gone = true

		if self.DestructionEffect then
			self:DestructionEffect(damage, attacker, inflictor)
		end

		self.Think = PROPGENERICREMOVALTHINK
	else
		self.PHealth = math.ceil(self.PHealth - damage)

		if not self.NoSetColorOnDamage then
			local col = team.GetColor(self:GetTeamID())
			local brit = self.PHealth / self.MaxPHealth

			if self.Destroyed then
				self:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), math.ceil(brit * 240)))
			else
				self:SetColor(Color(math.ceil(col.r * brit), math.ceil(col.g * brit), math.ceil(col.b * brit), 255))
			end
		end
	end
end

function PROPGENERICDESTRUCTIONEFFECT(self)
	local effectdata = EffectData()
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetOrigin(self:GetPos())
	util.Effect("explosion", effectdata, true, true)
end

function PROPGENERICDESTRUCTIONEFFECT2(self)
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("firebombexplosion", effectdata, true, true)
end