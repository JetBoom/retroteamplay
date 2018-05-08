AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.NextFlipOver = 0
ENT.NextShoot = 0
ENT.NextFastIdle = 0
ENT.LastAttacked = 0
ENT.DesiredCannonAngle = 0

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetPos(self:GetPos() + self.CreationOffset)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	--self:SetColor(Color(255, 255, 255, 0))

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
	self:SetState(STATE_ROVER_IDLE)
	self.Destroy = -1
	self:SetTeam(pl:Team())
	self.LastDriver = pl
	local gunner = self:GetGunnerSeat():GetDriver()
	if gunner:IsValid() and gunner:Team() ~= self:Team() then
		gunner:ExitVehicle()
		self:GetGunnerSeat():SetOwner(NULL)
	end

	self:GetPilotSeat():SetOwner(pl)
	--[[self.FrontRightWheel:SetOwner(pl)
	self.BackRightWheel:SetOwner(pl)
	self.FrontLeftWheel:SetOwner(pl)
	self.BackLeftWheel:SetOwner(pl)]]
end

function ENT:PilotExit(pl)
	self:EmitSound("ATV_engine_stop")
	self:SetState(STATE_ROVER_OFF)

	self.LastDriver = NULL

	self:GetPilotSeat():SetOwner(NULL)
	--[[self.FrontRightWheel:SetOwner(NULL)
	self.BackRightWheel:SetOwner(NULL)
	self.FrontLeftWheel:SetOwner(NULL)
	self.BackLeftWheel:SetOwner(NULL)]]
end

function ENT:GunnerEnter(pl)
	self:GetGunnerSeat():SetOwner(pl)
	local driver = self:GetPilotSeat():GetDriver()
	if not driver:IsValid() then
		self:SetTeam(pl:Team())
	end
end

local function SafeRemove(ent)
	if ent:IsValid() then
		ent:Remove()
	end
end
function ENT:OnRemove()
	local seat = self.PilotSeat
	if IsValid(seat) then
		constraint.RemoveAll(seat)

		timer.Simple(1, function() SafeRemove(seat) end)

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

	--[[local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(15, 13, -3))
		ent:SetAngles(Angle(0, 270, 0))
		ent:Spawn()
		ent.VehicleParent = self
		self.PilotSeat = ent
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self:SetPilotSeat(ent)
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end]]

	local pilotseat = ents.Create("prop_vehicle_jeep_old")
	if pilotseat:IsValid() then
		pilotseat:SetKeyValue("model", "models/buggy.mdl")
		pilotseat:SetKeyValue("solid", "6")
		pilotseat:SetKeyValue("vehiclescript", "scripts/vehicles/jeep_test.txt")
		pilotseat:SetPos(vPos + Vector(40, 0, -36))
		pilotseat:SetAngles(Angle(0, 270, 0))
		pilotseat:Spawn()
		
		pilotseat:SetRenderMode(RENDERMODE_TRANSALPHA)
		pilotseat:SetColor(Color(255, 255, 255, 0))
		--pilotseat:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		pilotseat.VehicleParent = self
		self.PilotSeat = pilotseat
		constraint.Weld(self, pilotseat, 0, 0, 0, 1)
		self:SetPilotSeat(pilotseat)
		pilotseat:SetVehicleParent(self)
		--pilotseat:SetMaterial("models/debug/debugwhite")
	end

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(-32, 0, 44))
		ent:SetAngles(Angle(0, 270, 0))
		ent:Spawn()
		ent.VehicleParent = self
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
			cannon.VehicleParent = self
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
		engine.VehicleParent = self
		engine:GetPhysicsObject():SetMass(10)
		constraint.Weld(self, engine, 0, 0, 0, 1)
		self:DeleteOnRemove(engine)
		self.Engine = engine

		constraint.NoCollide(engine, pilotseat, 0, 0)
	end

	--[[local wheel = ents.Create("roverwheel")
	if wheel:IsValid() then
		wheel:SetPos(vPos + Vector(50, 38, -16))
		wheel:SetAngles(Angle(0, 180, 90))
		wheel:Spawn()
		wheel:SetFriction(50)
		wheel.VehicleParent = self
		wheel:GetPhysicsObject():SetMass(170)
		constraint.Axis(wheel, self, 0, 0, Vector(0, 0, 12), Vector(50, 38, -16), 0, 0, 25, 1)
		self:DeleteOnRemove(wheel)
		self.FrontLeftWheel = wheel
	end

	local wheel = ents.Create("roverwheel")
	if wheel:IsValid() then
		wheel:SetPos(vPos + Vector(50, -38, -16))
		wheel:SetAngles(Angle(0, 0, 90))
		wheel:Spawn()
		wheel:SetFriction(50)
		wheel.VehicleParent = self
		wheel:GetPhysicsObject():SetMass(170)
		constraint.Axis(wheel, self, 0, 0, Vector(0, 0, -12), Vector(50, -38, -16), 0, 0, 25, 1)
		self:DeleteOnRemove(wheel)
		self.FrontRightWheel = wheel
	end

	local wheel = ents.Create("roverwheel")
	if wheel:IsValid() then
		wheel:SetPos(vPos + Vector(-50, 38, -16))
		wheel:SetAngles(Angle(0, 180, 90))
		wheel:Spawn()
		wheel:SetFriction(50)
		wheel.VehicleParent = self
		wheel:GetPhysicsObject():SetMass(240)
		constraint.Axis(wheel, self, 0, 0, Vector(0, 0, 12), Vector(-50, 38, -16), 0, 0, 25, 1)
		self:DeleteOnRemove(wheel)
		self.BackLeftWheel = wheel
	end

	local wheel = ents.Create("roverwheel")
	if wheel:IsValid() then
		wheel:SetPos(vPos + Vector(-50, -36, -16))
		wheel:SetAngles(Angle(0, 0, 90))
		wheel:Spawn()
		wheel:SetFriction(50)
		wheel.VehicleParent = self
		wheel:GetPhysicsObject():SetMass(240)
		constraint.Axis(wheel, self, 0, 0, Vector(0, 0, -12), Vector(-50, -38, -16), 0, 0, 25, 1)
		self:DeleteOnRemove(wheel)
		self.BackRightWheel = wheel
	end]]
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

	local driver = self:GetPilotSeat():GetDriver()
	if not driver:IsValid() then
		return SIM_NOTHING
	end

	--[[self.FrontLeftWheel:SetPhysicsAttacker(driver)
	self.FrontRightWheel:SetPhysicsAttacker(driver)
	self.BackLeftWheel:SetPhysicsAttacker(driver)
	self.BackRightWheel:SetPhysicsAttacker(driver)]]

	if driver:KeyDown(IN_JUMP) and CurTime() >= self.NextFlipOver and self:GetUp().z <= 0.15 and self:GetVelocity():Length() <= 128 then
		self.NextFlipOver = CurTime() + 2.5
		self:EmitSound("ambient/machines/catapult_throw.wav")
		phys:SetVelocity(Vector(0, 0, 500))
		phys:AddAngleVelocity(Vector(math.random(1, 2) == 1 and 5000 or -5000, 0, 0))
	end

	if driver:KeyDown(IN_FORWARD) then
		self:SetState(STATE_ROVER_ACCELERATING)

		--[[local torque = Vector(0, 0, 4200 * frametime)
		self.FrontLeftWheel:GetPhysicsObject():AddAngleVelocity(torque)
		self.BackLeftWheel:GetPhysicsObject():AddAngleVelocity(torque)
		self.FrontRightWheel:GetPhysicsObject():AddAngleVelocity(torque * -1)
		self.BackRightWheel:GetPhysicsObject():AddAngleVelocity(torque * -1)]]
	elseif driver:KeyDown(IN_BACK) then
		self:SetState(STATE_ROVER_ACCELERATING)

		--[[local torque = Vector(0, 0, 4200 * frametime)
		self.FrontLeftWheel:GetPhysicsObject():AddAngleVelocity(torque * -1)
		self.BackLeftWheel:GetPhysicsObject():AddAngleVelocity(torque * -1)
		self.FrontRightWheel:GetPhysicsObject():AddAngleVelocity(torque)
		self.BackRightWheel:GetPhysicsObject():AddAngleVelocity(torque)]]
	elseif self:GetState() ~= STATE_ROVER_IDLE then
		self:SetState(STATE_ROVER_IDLE)
	end

	--[[if driver:KeyDown(IN_MOVELEFT) then
		if phys:GetAngleVelocity().z < 100 and self:CanSteer() then
			phys:AddAngleVelocity(Vector(0, 0, 1600 * frametime))
		end
	elseif driver:KeyDown(IN_MOVERIGHT) then
		if phys:GetAngleVelocity().z > -100 and self:CanSteer() then
			phys:AddAngleVelocity(Vector(0, 0, -1600 * frametime))
		end
	else
		-- Dampen steering a bit.
		local ang = phys:GetAngleVelocity()
		ang.x = 0
		ang.y = 0
		phys:AddAngleVelocity(-5 * frametime * ang)
	end]]

	return SIM_NOTHING
end

function ENT:CanSteer()
	local downoffset = self:GetUp() * -30
	local backleftwheelpos = self.FrontLeftWheel:GetPos()
	local backrightwheelpos = self.FrontRightWheel:GetPos()
	return util.TraceHull({start=backleftwheelpos, endpos=backleftwheelpos + downoffset, filter = self.BackLeftWheel, mins = self.FrontLeftWheel:OBBMins(), maxs = self.FrontLeftWheel:OBBMaxs(), mask = MASK_SOLID}).Hit or util.TraceHull({start=backrightwheelpos, endpos=backrightwheelpos + downoffset, filter=self.FrontRightWheel, mins = self.FrontRightWheel:OBBMins(), maxs = self.FrontRightWheel:OBBMaxs(), mask = MASK_SOLID}).Hit
end

function ENT:Think()
	if self.DoDestroy or 0 < self:GetGunnerSeat():WaterLevel() then
		self:Destroyed(self.Attacker or NULL, self.Inflictor or NULL)
		self:Remove()
		return
	end

	local gunner = self:GetGunnerSeat():GetDriver()
	if gunner:IsValid() and gunner:KeyDown(IN_ATTACK) and self.NextShoot <= CurTime() and not self:IsMDF() then
		self.NextShoot = CurTime() + 1.25

		local dir = self.Cannon:GetUp()
		dir.z = math.Clamp(gunner:GetAimVector().z, dir.z - 0.6, dir.z + 0.6)
		dir = dir:GetNormal()

		local ent = ents.Create("projectile_assaultrovercannon")
		if ent:IsValid() then
			ent:SetPos(self.Cannon:GetPos() + dir * 40)
			ent:SetAngles(dir:Angle())
			ent:SetOwner(gunner)
			ent:SetSkin(self:Team())
			ent:Spawn()
			ent:SetTeamID(gunner:Team())
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

	ExplosiveDamage(attacker, self, 450, 450, 1, 0.4, 8)

	local vel = self:GetVelocity()
	local vel65 = vel * 0.65

	local pos = self:GetPos()
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
	util.Effect("FireBombExplosion", effectdata)

	for _, model in pairs(RandomProps) do
		local ent = ents.Create("prop_physics_multiplayer")
		if ent:IsValid() then
			ent:SetPos(pos + Vector(math.Rand(-64, 64), math.Rand(-64, 64), math.Rand(0, 48)))
			ent:SetAngles(Angle(math.random(1, 360), math.random(1, 360), math.random(1, 360)))
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

	--[[local ent2 = ents.Create("prop_physics_multiplayer")
	if ent2:IsValid() then
		ent2:SetPos(self.FrontLeftWheel:GetPos())
		ent2:SetAngles(self.FrontLeftWheel:GetAngles())
		ent2:SetModel(self.FrontLeftWheel:GetModel())
		ent2:Spawn()
		local phys = ent2:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.FrontLeftWheel:GetVelocity() + VectorRand() * 2250 + Vector(0, 0, 800))
			phys:ApplyForceCenter(vel65 + Vector(0, 0, 1050) + VectorRand() * 900 * phys:GetMass())
			phys:AddAngleVelocity(VectorRand() * 200)
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
	end]]

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

	--[[local ent2 = ents.Create("prop_physics_multiplayer")
	if ent2:IsValid() then
		ent2:SetPos(self.FrontRightWheel:GetPos())
		ent2:SetAngles(self.FrontRightWheel:GetAngles())
		ent2:SetModel(self.FrontRightWheel:GetModel())
		ent2:Spawn()
		local phys = ent2:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.FrontRightWheel:GetVelocity() + VectorRand() * 1250 + Vector(0, 0, 1800))
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
	end]]

	--[[local ent2 = ents.Create("prop_physics_multiplayer")
	if ent2:IsValid() then
		ent2:SetPos(self.BackLeftWheel:GetPos())
		ent2:SetAngles(self.BackLeftWheel:GetAngles())
		ent2:SetModel(self.BackLeftWheel:GetModel())
		ent2:Spawn()
		local phys = ent2:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.BackLeftWheel:GetVelocity() + VectorRand() * 1250 + Vector(0, 0, 1800))
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
	end]]

	--[[local ent2 = ents.Create("prop_physics_multiplayer")
	if ent2:IsValid() then
		ent2:SetPos(self.BackRightWheel:GetPos())
		ent2:SetAngles(self.BackRightWheel:GetAngles())
		ent2:SetModel(self.BackRightWheel:GetModel())
		ent2:Spawn()
		local phys = ent2:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.BackRightWheel:GetVelocity() + VectorRand() * 1250 + Vector(0, 0, 1800))
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
	end]]
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
