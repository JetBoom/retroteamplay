AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.NextFlipOver = 0
ENT.NextShoot = 0
ENT.NextFastIdle = 0
ENT.LastAttacked = 0
ENT.DesiredCannonAngle = 0
ENT.NextHonk = 0

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		phys:SetMass(400)
		phys:EnableMotion(true)
		phys:Wake()
	end

	self:StartMotionController()

	self:SetVHealth(self:GetMaxVHealth())

	self.Destroy = CurTime() + 30

	self.LastDriver = NULL
	self.Attacker = NULL
	self.Inflictor = NULL
end

function ENT:Enter(pl, veh, role)
	if veh == self:GetPilotSeat() then
		self:PilotEnter(pl)
	elseif veh == self:GetGunnerSeat() then
		self:GunnerEnter(pl)
	end
end

function ENT:Exit(pl, veh, role)
	if veh == self:GetPilotSeat() then
		self:PilotExit(pl)
	elseif veh == self:GetGunnerSeat() then
		self:GunnerExit(pl)
	end
end

function ENT:PilotEnter(pl)
	self.Destroy = -1
	self:SetTeamID(pl:GetTeamID())
	self.LastDriver = pl
	local gunner = self:GetGunnerSeat():GetDriver()
	if gunner:IsValid() and gunner:GetTeamID() ~= self:GetTeamID() then
		gunner:ExitVehicle()
		self:GetGunnerSeat():SetOwner(NULL)
	end

	self:GetPilotSeat():SetOwner(pl)
end

function ENT:PilotExit(pl)
	self:EmitSound("ATV_engine_stop")

	self.LastDriver = NULL

	self:GetPilotSeat():SetOwner(NULL)
end

function ENT:GunnerEnter(pl)
	self:GetGunnerSeat():SetOwner(pl)
	local driver = self:GetPilotSeat():GetDriver()
	if not driver:IsValid() then
		self:SetTeamID(pl:GetTeamID())
	end
end

local function SafeRemove(ent)
	if ent:IsValid() then
		ent:Remove()
	end
end
function ENT:OnRemove()
	local seat = self.PilotSeat
	if seat:IsValid() then --ValidEntity() : Find this so it can be reused here : if ValidEntity(seat) then
		constraint.RemoveAll(seat)

		timer.SimpleEx(1, SafeRemove, seat)

		seat:SetNotSolid(true)
		seat:SetMoveType(MOVETYPE_NONE)
		seat:SetNoDraw(true)
	end
end

function ENT:GunnerExit(pl)
	self:GetGunnerSeat():SetOwner(NULL)
end

function ENT:CreateChildren()
	local vPos = self:GetPos()

	local pilotseat = ents.Create("prop_vehicle_jeep_old")
	if pilotseat:IsValid() then
		pilotseat:SetKeyValue("model", "models/buggy.mdl")
		pilotseat:SetKeyValue("solid", "6")
		pilotseat:SetKeyValue("vehiclescript", "scripts/vehicles/jeep_test.txt")
		pilotseat:SetPos(vPos + Vector(40, 0, -36))
		pilotseat:SetAngles(Angle(0, 270, 0))
		pilotseat:Spawn()
		pilotseat:SetNoDraw(true)
		pilotseat:SetVehicleParent(self)
		self.PilotSeat = pilotseat
		constraint.Weld(self, pilotseat, 0, 0, 0, 1)
		self:SetPilotSeat(pilotseat)
		pilotseat:SetVehicleParent(self)
	end

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(-32, 0, 44))
		ent:SetAngles(Angle(0, 270, 0))
		ent:Spawn()
		ent:SetVehicleParent(self)
		ent:GetPhysicsObject():SetMass(20)
		constraint.Axis(ent, self, 0, 0, Vector(0, 0, -16), Vector(-32, 0, 21), 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		ent:SetVehicleParent(self)
		self:SetGunnerSeat(ent)
		ent:SetMaterial("models/debug/debugwhite")
		local cannon = ents.Create("prop_dynamic_override")
		if cannon:IsValid() then
			cannon:SetModel("models/props_borealis/bluebarrel001.mdl")
			cannon:SetPos(ent:GetPos() + Vector(16, -24, 16))
			cannon:SetAngles(Angle(90, 0, 0))
			cannon:Spawn()
			cannon:SetVehicleParent(self)
			self:DeleteOnRemove(cannon)
			self.Cannon = cannon
			cannon:SetParent(ent)
			self:SetCannon(cannon)
		end

		constraint.NoCollide(ent, pilotseat, 0, 0)
	end

	local engine = ents.Create("vehiclepart")
	if engine:IsValid() then
		engine:SetModel("models/props_c17/trappropeller_engine.mdl")
		engine:SetPos(vPos + Vector(54, 0, 12))
		engine:SetAngles(Angle(90, 180, 0))
		engine:Spawn()
		engine:SetVehicleParent(self)
		engine:GetPhysicsObject():SetMass(10)
		constraint.Weld(self, engine, 0, 0, 0, 1)
		self:DeleteOnRemove(engine)
		self.Engine = engine

		constraint.NoCollide(engine, pilotseat, 0, 0)
	end
end

function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local seat = self:GetGunnerSeat()
	local gunner = seat:GetDriver()
	if gunner:IsValid() then
		if not self:IsMDF() then
			if gunner:KeyDown(IN_MOVELEFT) then
				self.DesiredCannonAngle = math.NormalizeAngle(self.DesiredCannonAngle + frametime * 120)
			elseif gunner:KeyDown(IN_MOVERIGHT) then
				self.DesiredCannonAngle = math.NormalizeAngle(self.DesiredCannonAngle - frametime * 120)
			end
		end

		local newangles = seat:GetAngles()
		local diffangles = seat:WorldToLocalAngles(Angle(0, self.DesiredCannonAngle, 0))
		newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 120)
		seat:SetAngles(newangles)
	end

	local vel = self:GetVelocity()
	local gphys = seat:GetPhysicsObject()
	gphys:SetVelocityInstantaneous(vel)

	local driver = self.PilotSeat:GetDriver()
	if not driver:IsValid() then
		return SIM_NOTHING
	end

	if driver:KeyDown(IN_JUMP) and CurTime() >= self.NextFlipOver and self:GetUp().z <= 0.15 and self:GetVelocity():Length() <= 128 then
		self.NextFlipOver = CurTime() + 2.5
		self:EmitSound("ambient/machines/catapult_throw.wav")
		phys:SetVelocity(Vector(0, 0, 500))
		phys:AddAngleVelocity(Vector(math.random(1, 2) == 1 and 5000 or -5000, 0, 0))
	end

	return SIM_NOTHING
end

function ENT:Think()
	if self.DoDestroy or 0 < self:GetGunnerSeat():WaterLevel() then
		self:Destroyed(self.Attacker or NULL, self.Inflictor or NULL)
		self:Remove()
		return
	end

	local driver = self.PilotSeat:GetDriver()
	if driver:IsValid() and driver:KeyDown(IN_RELOAD) and CurTime() > self.NextHonk then
		self:EmitSound("speach/bikehorn.ogg", 75, math.Rand(88, 112))
		self.NextHonk = CurTime() + 1.5
	end
	
	local gunner = self:GetGunnerSeat():GetDriver()
	if gunner:IsValid() and gunner:KeyDown(IN_ATTACK) and self.NextShoot <= CurTime() and not self:IsMDF() then
		self.NextShoot = CurTime() + 1.25

		local dir = self.Cannon:GetUp()
		dir.z = math.Clamp(gunner:GetAimVector().z, dir.z - 0.6, dir.z + 0.6)
		dir:Normalize()

		local ent = ents.Create("projectile_assaultrovercannon")
		if ent:IsValid() then
			ent:SetPos(self.Cannon:GetPos() + dir * 40)
			ent:SetAngles(dir:Angle())
			ent:SetOwner(gunner)
			ent:SetSkin(self:GetTeamID())
			ent:Spawn()
			ent:SetTeamID(gunner:GetTeamID())
			self.Cannon:EmitSound("vehicles/Airboat/pontoon_impact_hard1.wav", 80, math.Rand(95, 105))
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(dir * 1400 + self:GetVelocity() * 0.5)
			end
		end
	end

	if 2 < self:WaterLevel() then
		local world = game.GetWorld()
		self.Attacker = world
		self.Inflictor = world
		self.DoDestroy = true
	elseif self.Destroy == -1 then
		self.Destroy = CurTime() + 45
	elseif CurTime() >= self.Destroy then
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 512)) do
			if ent.SendLua and ent:Alive() then
				self.Destroy = CurTime() + 15
				return
			end
		end
		self:Remove()
	end
end

local RandomProps = {"models/props_vehicles/carparts_axel01a.mdl",
"models/props_vehicles/carparts_door01a.mdl",
"models/props_vehicles/carparts_door01a.mdl",
"models/props_vehicles/carparts_muffler01a.mdl",
"models/props_c17/pulleywheels_large01.mdl"
}

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

	local driver = self:GetPilotSeat():GetDriver()
	local driverisvalid = driver:IsValid()

	if driverisvalid then
		driver:RemoveStatus("forcefield", false, true)
		driver:TakeSpecialDamage(500, DMGTYPE_FIRE, attacker, inflictor)
	end

	local gunner = self:GetGunnerSeat():GetDriver()
	if gunner:IsValid() then
		gunner:RemoveStatus("forcefield", false, true)
		gunner:TakeSpecialDamage(500, DMGTYPE_FIRE, attacker == driver and gunner or attacker, inflictor)
	end

	ExplosiveDamage(attacker, self, 425, 425, 1, 0.4, 8)

	local vel = self:GetVelocity()
	local vel65 = vel * 0.65

	local pos = self:GetPos()
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
	util.Effect("tp_bigexplosion", effectdata)

	for _, model in pairs(RandomProps) do
		local ent = ents.Create("prop_physics_multiplayer")
		if ent:IsValid() then
			ent:SetPos(pos + Vector(math.Rand(-64, 64), math.Rand(-64, 64), math.Rand(0, 48)))
			ent:SetAngles(VectorRand():Angle())
			ent:SetModel(model)
			ent:Spawn()
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:ApplyForceCenter(vel65 + Vector(0, 0, 1050) + VectorRand() * 900 * phys:GetMass())
				phys:AddAngleVelocity(VectorRand() * 300)
			end
			if driverisvalid then
				ent:SetPhysicsAttacker(driver)
			end
			ent:Fire("kill", "", 14)
			if math.random(1, 3) == 1 then
				local fire = ents.Create("env_fire_trail")
				if fire:IsValid() then
					fire:SetPos(ent:GetPos())
					fire:Spawn()
					fire:SetParent(ent)
				end
			end
		end
	end

	local ent2 = ents.Create("prop_physics_multiplayer")
	if ent2:IsValid() then
		ent2:SetPos(self.Engine:GetPos())
		ent2:SetAngles(self.Engine:GetAngles())
		ent2:SetModel(self.Engine:GetModel())
		ent2:Spawn()
		local phys = ent2:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.Engine:GetVelocity() + VectorRand() * 850 + Vector(0, 0, 2250))
			phys:ApplyForceCenter(vel65 + Vector(0, 0, 1050) + VectorRand() * 900 * phys:GetMass())
			phys:AddAngleVelocity(VectorRand() * 300)
		end
		if driverisvalid then
			ent2:SetPhysicsAttacker(driver)
		end
		ent2:Fire("kill", "", 14)
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent2:GetPos())
			fire:Spawn()
			fire:SetParent(ent2)
		end
	end
	
	self:GetPilotSeat():Remove()
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if attacker:IsValid() and attacker:GetTeamID() == self:GetTeamID() then return end

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
	elseif newhealth < self:GetMaxVHealth() * 0.3 and not self.Ignited then
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
