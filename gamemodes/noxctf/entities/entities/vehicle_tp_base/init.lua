AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.Attacker = NULL
ENT.Inflictor = NULL
ENT.LastDriver = NULL
ENT.LastEject = NULL

ENT.NextShoot = 0
ENT.NextShoot2 = 0

ENT.LastAttacked = 0
ENT.NextAllowPhysicsDamage = 0
ENT.NextCollisionSound = 0

ENT.DieTime = -1

ENT.CreationTollerance = true

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
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

	local driver = self:GetPilotSeat():GetDriver()
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
	elseif not self.Ignited and newhealth <= self.MaxHealth * 0.3 then
		self.Ignited = true

		local effectdata = EffectData()
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetRadius(1)

		for i=1, math.random(3) do
			local pos = self:LocalToWorld(self:OBBCenter()) + self:BoundingRadius() * math.Rand(0.1, 0.5) * VectorRand():GetNormalized()

			local ent = ents.Create("env_fire_trail")
			if ent:IsValid() then
				ent:SetPos(pos)
				ent:Spawn()
				ent:SetParent(self)

				effectdata:SetOrigin(pos)
				util.Effect("Explosion", effectdata)
			end
		end
	end
end

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		phys:SetMass(self.Mass)
		phys:EnableMotion(true)
		phys:EnableDrag(false)
		phys:Wake()
	end

	self:StartMotionController()

	self:SetVHealth(self.MaxHealth)

	self:CreateChildren()
end

function ENT:PilotEnter(pl)
	self:SetTeamID(pl:GetTeamID())
	self.LastDriver = pl
end

function ENT:PilotExit(pl)
	self.LastEject = pl
	self.LastDriver = NULL
end

function ENT:Enter(pl, veh, role)
	if veh == self:GetPilotSeat() then
		self:PilotEnter(pl)
	end
end

function ENT:Exit(pl, veh, role)
	if veh == self:GetPilotSeat() then
		self:PilotExit(pl)
	end

	pl:SetVelocity(self:GetVelocity() * 0.9)
end

function ENT:CreateChildren()
	if self.CreatedChildren then return end
	self.CreatedChildren = true

	for partname, parttab in pairs(self.VehicleParts) do
		local class = parttab.Class
		if class then
			local ent = ents.Create(class)
			self[partname] = ent
			if ent:IsValid() then
				if parttab.Model then
					ent:SetModel(parttab.Model)
				end
				if parttab.KeyValues then
					for i=1, #parttab.KeyValues, 2 do
						ent:SetKeyValue(parttab.KeyValues[i], parttab.KeyValues[i + 1])
					end
				end
				if parttab.Pos then
					ent:SetPos(self:LocalToWorld(parttab.Pos)) --ent:SetPos(self:GetPos() + parttab.Pos)
				end
				if parttab.Angles then
					ent:SetAngles(self:LocalToWorldAngles(parttab.Angles)) --ent:SetAngles(parttab.Angles)
				end

				ent:Spawn()
				self:DeleteOnRemove(ent)

				ent:SetVehicleParent(self)

				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					if parttab.Mass ~= nil then phys:SetMass(parttab.Mass) end
					if parttab.Gravity ~= nil then phys:EnableGravity(parttab.Gravity) end
					if parttab.Drag ~= nil then phys:EnableDrag(parttab.Drag) end
				end

				if parttab.PilotSeat then
					self:SetPilotSeat(ent)
				end
				if parttab.GunnerSeat then
					self:SetGunnerSeat(ent)
				end
			end			
		end
	end

	for _, constrainttab in ipairs(self.VehicleConstraints) do
		local tconstrainttab = table.Copy(constrainttab)
		local func = constraint[ tconstrainttab[1] ]
		if func then
			for k, v in ipairs(tconstrainttab) do
				if k == 1 then continue end
				if type(v) == "string" then
					if v == "*self*" then
						tconstrainttab[k] = self
					elseif self[v] then
						tconstrainttab[k] = self[v]
					end
				end
			end

			func(unpack(tconstrainttab, 2))
		end
	end
end

function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	return SIM_NOTHING
end

function ENT:SetPhysicsAttackers(driver)
	self:SetPhysicsAttacker(driver)
	for k in pairs(self.VehicleParts) do
		if IsValid(self[k]) then
			self[k]:SetPhysicsAttacker(driver)
		end
	end
end

function ENT:Think()
	if self.DoDestroy or 0 < self:GetPilotSeat():WaterLevel() then
		self:Destroyed(self.Attacker or NULL, self.Inflictor or NULL)
		self:Remove()
		return
	end

	local data = self.PhysicsData
	if data then
		self.PhysicsData = nil
		self:TakeSpecialDamage(math.ceil(data.Speed * self.CollisionDamageScale), DMGTYPE_IMPACT, NULL, NULL, data.HitPos)
	end

	local driver = self:GetPilotSeat():GetDriver()
	if driver:IsValid() then
		self:SetPhysicsAttackers(driver)
	end

	self:VehicleThink()

	self:CheckDieTime()

	self:NextThink(CurTime())
	return true
end

function ENT:CheckDieTime()
	if self.DieTime >= 0 and CurTime() >= self.DieTime then
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 512)) do
			if ent:IsPlayer() and ent:Alive() then
				self.DieTime = CurTime() + VEHICLE_ABANDONTIME
				return
			end
		end

		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys, frompart)
	local hitent = data.HitEntity

	if self.SkyBoxBounceBack and not hitent:IsValid() then
		local tr
		local tr2
		local mypos = self:NearestPoint(data.HitPos)
		local forward = self:GetForward()
		if frompart then
			local endingpos = mypos + forward * 512
			local endingpos2 = mypos + forward * -512
			tr = util.TraceLine({start = self:NearestPoint(endingpos), endpos = endingpos, mask = MASK_SOLID_BRUSHONLY})
			tr2 = util.TraceLine({start = self:NearestPoint(endingpos2), endpos = endingpos2, mask = MASK_SOLID_BRUSHONLY})
		else
			tr = util.TraceLine({start = self:NearestPoint(data.HitPos), endpos = data.HitPos + self:GetForward() * 64, mask = MASK_SOLID_BRUSHONLY})
			tr2 = util.TraceLine({start = self:NearestPoint(data.HitPos), endpos = data.HitPos + self:GetForward() * -64, mask = MASK_SOLID_BRUSHONLY})
		end

		if tr.HitSky and tr.HitWorld or tr2.HitSky and tr2.HitWorld then
			phys:SetVelocityInstantaneous(data.HitNormal * math.min(100, data.Speed * 1.5))
			return
		end
	end

	if self.CollisionDamageScale > 0 then
		if hitent:IsValid() then
			local hitentclass = hitent:GetClass()
			if hitentclass == "prop_physics_multiplayer" or hitentclass == "player" then
				return
			end
			
			local proj = hitent.m_IsProjectile and hitent
			if proj then return end

			local othervehicle = hitent.ScriptVehicle and hitent or hitent:GetVehicleParent():IsValid() and hitent:GetVehicleParent()
			if othervehicle and othervehicle:GetTeamID() == self:GetTeamID() then
				return
			end
		end

		if self.CreationTollerance then
			self.CreationTollerance = nil
			return
		end

		if self.CrashSpeed > 0 and data.Speed >= self.CrashSpeed then
			self.DoDestroy = true
			local driver = self:GetPilotSeat():GetDriver()
			if driver:IsValid() then
				self.Attacker = driver
				self.Inflictor = driver
			end
		elseif self.CollisionDamageSpeed > 0 and data.Speed >= self.CollisionDamageSpeed then
			if self.NextCollisionSound <= CurTime() then
				self:EmitSound("vehicles/v8/vehicle_impact_heavy"..math.random(4)..".wav")
				self.NextCollisionSound = CurTime() + 0.25
			end

			self.PhysicsData = data

			self:NextThink(CurTime())
		end
	end
end

function ENT:DestructionEffect()
	local pos = self:GetPos()
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetScale(1)
		effectdata:SetMagnitude(1)
		effectdata:SetRadius(1)
	util.Effect("ar2explosion", effectdata)
	util.Effect("tp_bigexplosion", effectdata)
end

function ENT:CreateDebris(attacker)
	attacker = attacker or self

	local basepos = self:LocalToWorld(self:OBBCenter())

	local tab = {}
	if not self.DontCreateSelfDebris then
		table.insert(tab, self)
	end
	for k, v in pairs(self.VehicleParts) do
		if not v.NoDebris and IsValid(self[k]) then
			table.insert(tab, self[k])
		end
	end

	for _, ent in pairs(tab) do
		local debris = ents.Create("prop_physics_multiplayer")
		if debris:IsValid() then
			debris:SetPos(ent:GetPos())
			debris:SetAngles(ent:GetAngles())
			debris:SetModel(ent:GetModel())
			debris:SetColor(ent:GetColor())
			debris:SetMaterial(ent:GetMaterial())
			debris:SetSkin(ent:GetSkin())
			debris:Spawn()

			local fire = ents.Create("env_fire_trail")
			if fire:IsValid() then
				fire:SetPos(debris:GetPos())
				fire:Spawn()
				fire:SetParent(debris)
			end

			local phys = debris:GetPhysicsObject()
			if phys:IsValid() then
				local entphys = ent:GetPhysicsObject()
				if entphys:IsValid() then
					phys:SetMass(entphys:GetMass())
					phys:EnableDrag(false)
				end

				local vel = ent:GetVelocity()
				phys:Wake()
				phys:SetVelocityInstantaneous(vel + math.max(vel:Length(), 256) * math.Rand(0.2, 0.5) * (ent:LocalToWorld(ent:OBBCenter()) - basepos):GetNormalized())
				phys:AddAngleVelocity(VectorRand() * 10)
			end

			if attacker:IsValid() then
				debris:SetPhysicsAttacker(attacker)
			end

			debris:Fire("kill", "", math.random(10, 15))
		end
	end
end

function ENT:Destroyed(attacker, inflictor)
	if self.AlreadyDestroyed then return end
	self.AlreadyDestroyed = true

	self:SetVHealth(0)

	attacker = attacker or NULL

	if not attacker:IsValid() and self.Attacker:IsValid() and CurTime() < self.LastAttacked + 10 then
		attacker = self.Attacker
	end

	if not attacker:IsValid() and self.LastDriver:IsValid() then
		attacker = self.LastDriver
	end

	self:KillPassengers(attacker, inflictor)
	self:DestructionEffect()
	self:CreateDebris(attacker)

	ExplosiveDamage(attacker, self, self.ExplosionRadius, self.ExplosionRadius, 1, self.ExplosionDamage, 1)
end

function ENT:KillPassengers(attacker, inflictor)
	attacker = attacker or self
	inflictor = inflictor or attacker

	for _, ent in pairs(ents.FindByClass("prop_vehicle*")) do
		if ent:GetVehicleParent() == self then
			local driver = ent:GetDriver()
			if driver and driver:IsValid() then
				driver:RemoveStatus("forcefield", false, true)
				driver:SetHealth(1)
				driver:TakeSpecialDamage(30, DMGTYPE_FIRE, attacker ~= driver and attacker:IsValid() and attacker:IsPlayer() and attacker:GetTeamID() == driver:GetTeamID() and driver or attacker, inflictor)
			end
		end
	end
end

function ENT:VehicleThink()
end

function ENT:TeamSet(newteamid)
end

--[[
concommand.Add("makevehicle", function(s, c, a)
	local class = a[1]
	if not class then return end
	class = "vehicle_tp"..class

	local stored = scripted_ents.GetStored(class)
	if not stored or not stored.t or not stored.t.ScriptVehicle or stored.t.Hidden then return end

	local current = s._SpawnedVehicle
	if IsValid(current) then current:Remove() end

	local pos = s:GetPos()
	if stored.t.CreationOffset then
		pos = pos + stored.t.CreationOffset
	end
	local ang = s:EyeAngles()
	ang.pitch = 0
	ang.roll = 0

	local ent = ents.Create(class)
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(ang)
		ent:Spawn()
		if ent.CreateChildren then ent:CreateChildren() end
		s:SetPos(pos + Vector(0, 0, 200))
		s._SpawnedVehicle = ent
	end
end)
]]