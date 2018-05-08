AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.PrecacheSound("npc/combine_gunship/ping_patrol.wav")
util.PrecacheSound("npc/combine_gunship/attack_stop2.wav")
util.PrecacheSound("npc/combine_gunship/attack_start2.wav")
util.PrecacheSound("npc/combine_gunship/gunship_explode2.wav")
util.PrecacheSound("npc/combine_gunship/gunship_weapon_fire_loop6.wav")
util.PrecacheSound("npc/combine_gunship/dropship_engine_near_loop1.wav")

function ENT:Initialize()
	self:SetModel("models/combine_dropship_container.mdl")
	self:SetPos(self:GetPos() + self.CreationOffset)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		phys:SetMass(7000)
		phys:EnableMotion(true)
		phys:EnableDrag(false)
		phys:Wake()
		self.Phys = phys
	end

	self:StartMotionController()

	self:SetVHealth(self.MaxHealth)

	self.NextShoot = 0
	self.NextLeftGunnerShoot = 0
	self.NextRightGunnerShoot = 0
	self.Destroy = CurTime() + 30
	self.NextCollatSound = 0
	self.CreationTollerance = true
	self.LastPilot = NULL
	self.LastLeftGunner = NULL
	self.LastRightGunner = NULL
	self.LastLeftPassenger1 = NULL
	self.LastLeftPassenger2 = NULL
	self.LastRightPassenger1 = NULL
	self.LastRightPassenger2 = NULL
	self.LastEject = NULL
	self.NextAllowPhysicsDamage = 0

	self.PilotShooting = false
	self.LeftGunnerShooting = false
	self.RightGunnerShooting = false

	self.Attacker = NULL
	self.Inflictor = NULL

	self.LastAttacked = 0
end

function ENT:PilotEnter(pl)
	local teamid = pl:Team()
	self:SetTeam(teamid)
	self:EmitSound("NPC_CombineGunship.PatrolPing")
	--self:EmitSound("npc/combine_gunship/ping_patrol.wav")
	self:SetTeam(pl:Team())
	self.Destroy = 99999999
	self.LastPilot = pl
	self.Phys:EnableGravity(false)

	local passenger = self.LeftGunnerSeat:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.RightGunnerSeat:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.LeftPassengerSeat1:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.LeftPassengerSeat2:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.RightPassengerSeat1:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.RightPassengerSeat2:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
end

function ENT:OnRemove()
	--self.PilotGunSound:Stop()
	--self.RightGunnerSound:Stop()
	--self.LeftGunnerSound:Stop()
end

function ENT:PilotExit(pl)
	if self.PilotShooting then
		self.PilotShooting = false
		self:EmitSound("NPC_CombineGunship.CannonStopSound")
		--self:EmitSound("npc/combine_gunship/attack_stop2.wav")
	end
	pl:SetVelocity(self:GetVelocity() * 0.9)
	self.Phys:EnableGravity(true)
	self.LastPilot = NULL
	self.LastEject = pl
	--self.PilotGunSound:Stop()
end

function ENT:UpdateCrew()
	if self:IsValid() then
		umsg.Start("RecDSD")
			umsg.Entity(self)
			umsg.Entity(self.LastPilot)
			umsg.Entity(self.LastLeftGunner)
			umsg.Entity(self.LastRightGunner)
			umsg.Entity(self.LastLeftPassenger1)
			umsg.Entity(self.LastLeftPassenger2)
			umsg.Entity(self.LastRightPassenger1)
			umsg.Entity(self.LastRightPassenger2)
		umsg.End()

		local lastpilotindex = 0
		if self.LastPilot:IsValid() then lastpilotindex = self.LastPilot:EntIndex() end
		local lastleftgunnerindex = 0
		if self.LastLeftGunner:IsValid() then lastleftgunnerindex = self.LastLeftGunner:EntIndex() end
		local lastrightgunnerindex = 0
		if self.LastRightGunner:IsValid() then lastrightgunnerindex = self.LastRightGunner:EntIndex() end
		local lastleftpassenger1index = 0
		if self.LastLeftPassenger1:IsValid() then lastleftpassenger1index = self.LastLeftPassenger1:EntIndex() end
		local lastleftpassenger2index = 0
		if self.LastLeftPassenger2:IsValid() then lastleftpassenger2index = self.LastLeftPassenger2:EntIndex() end
		local lastrightpassenger1index = 0
		if self.LastRightPassenger1:IsValid() then lastrightpassenger1index = self.LastRightPassenger1:EntIndex() end
		local lastrightpassenger2index = 0
		if self.LastRightPassenger2:IsValid() then lastrightpassenger2index = self.LastRightPassenger2:EntIndex() end
		BroadcastLua("RecDSD("..self:EntIndex()..","..lastpilotindex..","..lastleftgunnerindex..","..lastrightgunnerindex..","..lastleftpassenger1index..","..lastleftpassenger2index..","..lastrightpassenger1index..","..lastrightpassenger2index..")")
	end
end

function ENT:Enter(pl, veh, role)
	if veh == self.PilotSeat then
		self:PilotEnter(pl)
	elseif veh == self.LeftGunnerSeat then
		self.LastLeftGunner = pl
	elseif veh == self.RightGunnerSeat then
		self.LastRightGunner = pl
	elseif veh == self.RightPassengerSeat1 then
		self.LastRightPassenger1 = pl
	elseif veh == self.RightPassengerSeat2 then
		self.LastRightPassenger2 = pl
	elseif veh == self.LeftPassengerSeat1 then
		self.LastLeftPassenger1 = pl
	elseif veh == self.LeftPassengerSeat2 then
		self.LastLeftPassenger2 = pl
	end
	self:UpdateCrew()
end

function ENT:Exit(pl, veh, role)
	if veh == self.PilotSeat then
		self:PilotExit(pl)
	elseif veh == self.LeftGunnerSeat then
		self.LastLeftGunner = NULL
	elseif veh == self.RightGunnerSeat then
		self.LastRightGunner = NULL
	elseif veh == self.RightPassengerSeat1 then
		self.LastRightPassenger1 = NULL
	elseif veh == self.RightPassengerSeat2 then
		self.LastRightPassenger2 = NULL
	elseif veh == self.LeftPassengerSeat1 then
		self.LastLeftPassenger1 = NULL
	elseif veh == self.LeftPassengerSeat2 then
		self.LastLeftPassenger2 = NULL
	end
	timer.Simple(0.25, function() self.UpdateCrew(self) end)
end

function ENT:CreateChildren()
	local vPos = self:GetPos()

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(16, 0, 76))
		ent:SetAngles(Angle(0, 270, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = PilotEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.PilotSeat = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(32, 160, 0))
		ent:SetAngles(Angle(0, 270, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = GunnerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.LeftGunnerSeat = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(32, -160, 0))
		ent:SetAngles(Angle(0, 270, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = GunnerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.RightGunnerSeat = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(-64, -65, -4))
		ent:SetAngles(Angle(0, 180, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = PassengerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.RightPassengerSeat1 = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(-110, -65, -4))
		ent:SetAngles(Angle(0, 180, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = PassengerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.RightPassengerSeat2 = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(-64, 65, -4))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = PassengerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.LeftPassengerSeat1 = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(-110, 65, -4))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = PassengerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.LeftPassengerSeat2 = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local ent = ents.Create("vehiclepart")
	if ent:IsValid() then
		ent:SetModel("models/gibs/helicopter_brokenpiece_05_tailfan.mdl")
		ent:SetPos(vPos + Vector(-256, 50, 0))
		ent:SetAngles(Angle(330, 0, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(100)
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.LeftTail = ent
	end

	local ent = ents.Create("vehiclepart")
	if ent:IsValid() then
		ent:SetModel("models/gibs/helicopter_brokenpiece_05_tailfan.mdl")
		ent:SetPos(vPos + Vector(-256, -50, 0))
		ent:SetAngles(Angle(330, 0, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(100)
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.RightTail = ent
	end

	local ent = ents.Create("vehiclepart")
	if ent:IsValid() then
		ent:SetModel("models/props_combine/combine_barricade_med01b.mdl")
		ent:SetPos(vPos + Vector(0, -50, 22))
		ent:SetAngles(Angle(-90, -90, 180))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(100)
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.RightWing = ent
	end

	local ent = ents.Create("vehiclepart")
	if ent:IsValid() then
		ent:SetModel("models/props_combine/combine_barricade_med01b.mdl")
		ent:SetPos(vPos + Vector(0, 50, 22))
		ent:SetAngles(Angle(-90, 90, 180))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(100)
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.LeftWing = ent
	end
end

function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local driver = self.PilotSeat:GetDriver()

	if not driver:IsValid() then
		phys:EnableGravity(true)
		phys:SetAngleDragCoefficient(1)

		return SIM_NOTHING
	end

	phys:SetAngleDragCoefficient(2000000)

	local vel = self:GetVelocity() * (1 - frametime)

	local getangles = self:GetAngles()

	local desiredroll = getangles.roll * -1
	local desiredpitch = getangles.pitch * -1

	if driver:KeyDown(IN_FORWARD) then
		local forward = self:GetForward()
		forward.z = 0
		forward = forward:GetNormal()
		desiredpitch = 15
		vel = vel + frametime * 450 * forward
		local vellength = vel:Length()
		if 1150 < vellength then
			vel = vel * (1150 / vellength)
		end
	elseif driver:KeyDown(IN_BACK) then
		local forward = self:GetForward()
		forward.z = 0
		forward = forward:GetNormal()
		desiredpitch = -15
		vel = vel + frametime * -450 * forward
		local vellength = vel:Length()
		if 1150 < vellength then
			vel = vel * (1150 / vellength)
		end
	end

	if driver:KeyDown(IN_MOVELEFT) then
		local forward = self:GetRight()
		forward.z = 0
		forward = forward:GetNormal()
		desiredroll = -15
		vel = vel + frametime * -450 * forward
		local vellength = vel:Length()
		if 1150 < vellength then
			vel = vel * (1150 / vellength)
		end
	elseif driver:KeyDown(IN_MOVERIGHT) then
		local forward = self:GetRight()
		forward.z = 0
		forward = forward:GetNormal()
		desiredroll = 15
		vel = vel + frametime * 450 * forward
		local vellength = vel:Length()
		if 1150 < vellength then
			vel = vel * (1150 / vellength)
		end
	end

	if driver:KeyDown(IN_JUMP) then
		vel = vel + Vector(0, 0, frametime * 450)
		local vellength = vel:Length()
		if 1150 < vellength then
			vel = vel * (1150 / vellength)
		end
	elseif driver:KeyDown(IN_DUCK) then
		vel = vel + Vector(0, 0, frametime * -450)
		local vellength = vel:Length()
		if 1500 < vellength then
			vel = vel * (1500 / vellength)
		end
	end

	local aimang = driver:EyeAngles()

	local diffangles = self:WorldToLocalAngles(aimang)
	local diffangles2 = self:WorldToLocalAngles(Angle(desiredpitch, getangles.yaw, desiredroll))

	getangles:RotateAroundAxis(getangles:Up(), diffangles.yaw * frametime * 0.6)
	getangles:RotateAroundAxis(getangles:Forward(), diffangles2.roll * frametime)
	getangles:RotateAroundAxis(getangles:Right(), diffangles2.pitch * frametime * -1)

	self:SetAngles(getangles)
	phys:SetVelocityInstantaneous(vel)

	return SIM_NOTHING
end

local lastattacker = NULL
local lastinflictor = NULL

local function HoverCycleBCb(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent and ent.TakeSpecialDamage then
		ent:TakeSpecialDamage(dmginfo:GetDamage(), DMGTYPE_PIERCING, lastattacker, lastinflictor)

		return {damage = false}
	end
end

function ENT:Think()
	if self.DoDestroy or 0 < self.PilotSeat:WaterLevel() then
		self:Destroyed(self.Attacker or NULL, self.Inflictor or NULL)
		self:Remove()
		return
	end

	local data = self.PhysicsData
	if data then
		self.PhysicsData = nil
		self:TakeSpecialDamage(math.ceil(data.Speed * 0.02), DMGTYPE_IMPACT, NULL, NULL, data.HitPos)
	end

	local isMDF = self:IsMDF()

	local numshooting = 0

	local gunner = self.LeftGunnerSeat:GetDriver()
	if gunner:IsValid() then
		self.Destroy = 99999999

		if not isMDF and gunner:KeyDown(IN_ATTACK) and self.NextLeftGunnerShoot <= CurTime() then
			self.NextLeftGunnerShoot = CurTime() + 1.25
			local ent = ents.Create("projectile_dropshipcannon")
			if ent:IsValid() then
				local aimvec = gunner:GetAimVector()
				ent:SetPos(gunner:GetShootPos() + aimvec * 32)
				ent:SetOwner(gunner)
				ent:SetSkin(self:Team())
				ent:Spawn()
				ent:SetTeamID(gunner:Team())
				self.LeftGunnerSeat:EmitSound("vehicles/Airboat/pontoon_impact_hard1.wav", 80, math.Rand(95, 105))
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(aimvec * 1400)
				end
			end
		end
	end

	local gunner = self.RightGunnerSeat:GetDriver()
	if gunner:IsValid() then
		self.Destroy = 99999999

		if not isMDF and gunner:KeyDown(IN_ATTACK) and self.NextRightGunnerShoot <= CurTime() then
			self.NextRightGunnerShoot = CurTime() + 1.25
			local ent = ents.Create("projectile_dropshipcannon")
			if ent:IsValid() then
				local aimvec = gunner:GetAimVector()
				ent:SetPos(gunner:GetShootPos() + aimvec * 32)
				ent:SetOwner(gunner)
				ent:SetSkin(self:Team())
				ent:Spawn()
				ent:SetTeamID(gunner:Team())
				self.LeftGunnerSeat:EmitSound("vehicles/Airboat/pontoon_impact_hard1.wav", 80, math.Rand(95, 105))
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(aimvec * 1400)
				end
			end
		end
	end

	local driver = self.PilotSeat:GetDriver()
	if driver:IsValid() then
		self.Destroy = 99999999

		self.LeftWing:SetPhysicsAttacker(driver)
		self.RightWing:SetPhysicsAttacker(driver)
		self.LeftTail:SetPhysicsAttacker(driver)
		self.RightTail:SetPhysicsAttacker(driver)
		self.PilotSeat:SetPhysicsAttacker(driver)
		self.LeftGunnerSeat:SetPhysicsAttacker(driver)
		self.RightGunnerSeat:SetPhysicsAttacker(driver)
		self.LeftPassengerSeat1:SetPhysicsAttacker(driver)
		self.LeftPassengerSeat2:SetPhysicsAttacker(driver)
		self.RightPassengerSeat1:SetPhysicsAttacker(driver)
		self.RightPassengerSeat2:SetPhysicsAttacker(driver)

		if not isMDF and driver:KeyDown(IN_ATTACK) then
			numshooting = numshooting + 1
			if not self.PilotShooting then
				self.PilotShooting = true
				self:EmitSound("NPC_CombineGunship.CannonStartSound")
			elseif self.NextShoot <= CurTime() then
				self.NextShoot = CurTime() + 0.08

				lastattacker = driver
				lastinflictor = self

				local bullet = {}
				bullet.Num = 2
				bullet.Dir = driver:GetAimVector()
				bullet.Src = self:GetPos() + self:GetUp() * 59.5 + self:GetForward() * 170 + self:GetRight() * -62.5
				bullet.Spread = Vector(0.045, 0.045, 0)
				bullet.Tracer = 1
				bullet.Force = 4
				bullet.Damage = 9
				bullet.TracerName = "manatrace"
				bullet.Callback = HoverCycleBCb

				self:FireBullets(bullet)
			end
		elseif self.PilotShooting then
			self.PilotShooting = false
			self:EmitSound("NPC_CombineGunship.CannonStopSound")
		end
	end

	if numshooting ~= self:GetSkin() then
		self:SetSkin(numshooting)
	end

	if self.Destroy < CurTime() then
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 1500)) do
			if ent.SendLua and ent:Alive() then
				self.Destroy = CurTime() + 15
				return SIM_NOTHING
			end
		end
		self:Remove()
	elseif self.Destroy == 99999999 then
		self.Destroy = CurTime() + 45
	end
end

function ENT:PhysicsCollide(data, phys, frompart)
	local hitent = data.HitEntity

	if not hitent:IsValid() then
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

	local hitentclass = hitent:GetClass()

	if hitentclass ~= "prop_physics_multiplayer" and ((not hitent:IsValid() or string.find(hitentclass, "prop_") or string.find(hitentclass, "obelisk") or hitent.ScriptVehicle or hitent.VehicleParent) and not (hitent.ScriptVehicle and hitent:Team() == self:Team() or hitent.VehicleParent and hitent.VehicleParent:Team() == self:Team()) and 200 < data.Speed) then
		if self.CreationTollerance then
			self.CreationTollerance = nil
			return
		end

		if 400 <= data.Speed then
			if self.NextCollatSound < CurTime() then
				self:EmitSound("vehicles/v8/vehicle_impact_heavy"..math.random(1, 4)..".wav")
				self.NextCollatSound = CurTime() + 0.5
			end
			self.PhysicsData = data
			self:NextThink(CurTime())
		end
	end
end

function ENT:KillPerson(pl, attacker, inflictor, driver)
	if pl:IsValid() then
		pl:RemoveStatus("forcefield", false, true)
		pl:TakeSpecialDamage(pl:Health() + 29, DMGTYPE_FIRE, attacker == driver and pl or attacker, inflictor)
	end
end

util.PrecacheSound("NPC_CombineGunship.Explode")
function ENT:Destroyed(attacker, inflictor)
	if self.AlreadyDestroyed then return end
	self.AlreadyDestroyed = true

	self:SetVHealth(0)

	attacker = attacker or NULL

	if not attacker:IsValid() and self.Attacker:IsValid() and CurTime() < self.LastAttacked + 10 then
		attacker = self.Attacker
	end

	if not attacker:IsValid() and self.LastPilot:IsValid() then
		attacker = self.LastPilot
	end

	self:EmitSound("NPC_CombineGunship.Explode")
	--self:EmitSound("npc/combine_gunship/gunship_explode2.wav")

	local driver = self.PilotSeat:GetDriver()

	local driverisvalid = driver:IsValid()

	if driverisvalid then
		driver:RemoveStatus("forcefield", false, true)
		driver:TakeDamage(driver:Health() + 29, attacker, inflictor)
	elseif self.LastEject:IsValid() then
		driver = self.LastEject
		driverisvalid = true
		inflictor = self
	end

	--[[Killpl(self.LeftGunnerSeat:GetDriver(), attacker, inflictor, driver)
	Killpl(self.RightGunnerSeat:GetDriver(), attacker, inflictor, driver)
	Killpl(self.LeftPassengerSeat1:GetDriver(), attacker, inflictor, driver)
	Killpl(self.LeftPassengerSeat2:GetDriver(), attacker, inflictor, driver)
	Killpl(self.RightPassengerSeat1:GetDriver(), attacker, inflictor, driver)
	Killpl(self.RightPassengerSeat2:GetDriver(), attacker, inflictor, driver)]]

	ExplosiveDamage(attacker, self, 800, 800, 1, 0.25, 8)

	local pos = self:GetPos()
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetScale(1)
		effectdata:SetMagnitude(1)
		effectdata:SetRadius(1)
	util.Effect("ar2explosion", effectdata)
	util.Effect("FireBombExplosion", effectdata)

	local ent = ents.Create("prop_physics_multiplayer")
	if ent:IsValid() then
		ent:SetPos(pos)
		ent:SetAngles(self:GetAngles())
		ent:SetModel("models/combine_dropship_container.mdl")
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self:GetVelocity() + Vector(0, 0, 500))
			phys:AddAngleVelocity(VectorRand() * 60)
		end
		if driverisvalid then
			ent:SetPhysicsAttacker(driver)
		end
		ent:Fire("kill", "", math.Rand(12, 15))
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent:GetPos())
			fire:Spawn()
			fire:SetParent(ent)
		end
		ent:EmitSound("nox/explosion05.ogg")
	end

	local ent2 = ents.Create("prop_physics_multiplayer")
	if ent2:IsValid() then
		ent2:SetPos(self.LeftWing:GetPos())
		ent2:SetAngles(self.LeftWing:GetAngles())
		ent2:SetModel(self.LeftWing:GetModel())
		ent2:Spawn()
		local phys = ent2:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.LeftWing:GetVelocity() + VectorRand() * 350 + Vector(0, 0, 800))
			phys:AddAngleVelocity(VectorRand() * 25)
		end
		if driverisvalid then
			ent2:SetPhysicsAttacker(driver)
		end
		ent2:Fire("kill", "", math.Rand(12, 15))
		if math.random(1, 2) == 1 then
			local fire = ents.Create("env_fire_trail")
			if fire:IsValid() then
				fire:SetPos(ent2:GetPos())
				fire:Spawn()
				fire:SetParent(ent2)
			end
		end
	end

	local ent3 = ents.Create("prop_physics_multiplayer")
	if ent3:IsValid() then
		ent3:SetPos(self.RightWing:GetPos())
		ent3:SetAngles(self.RightWing:GetAngles())
		ent3:SetModel(self.RightWing:GetModel())
		ent3:Spawn()
		local phys = ent3:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.RightWing:GetVelocity() + VectorRand() * 350 + Vector(0, 0, 700))
			phys:AddAngleVelocity(VectorRand() * 25)
		end
		if driverisvalid then
			ent3:SetPhysicsAttacker(driver)
		end
		ent3:Fire("kill", "", math.Rand(12, 15))
		if math.random(1, 2) == 1 then
			local fire = ents.Create("env_fire_trail")
			if fire:IsValid() then
				fire:SetPos(ent3:GetPos())
				fire:Spawn()
				fire:SetParent(ent3)
			end
		end
	end

	local ent2 = ents.Create("prop_physics_multiplayer")
	if ent2:IsValid() then
		ent2:SetPos(self.LeftTail:GetPos())
		ent2:SetAngles(self.LeftTail:GetAngles())
		ent2:SetModel(self.LeftTail:GetModel())
		ent2:Spawn()
		local phys = ent2:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.LeftTail:GetVelocity() + VectorRand() * 550 + Vector(0, 0, 800))
			phys:AddAngleVelocity(VectorRand() * 50)
		end
		if driverisvalid then
			ent2:SetPhysicsAttacker(driver)
		end
		ent2:Fire("kill", "", math.Rand(12, 15))
		if math.random(1, 2) == 1 then
			local fire = ents.Create("env_fire_trail")
			if fire:IsValid() then
				fire:SetPos(ent2:GetPos())
				fire:Spawn()
				fire:SetParent(ent2)
			end
		end
	end

	local ent3 = ents.Create("prop_physics_multiplayer")
	if ent3:IsValid() then
		ent3:SetPos(self.RightTail:GetPos())
		ent3:SetAngles(self.RightTail:GetAngles())
		ent3:SetModel(self.RightTail:GetModel())
		ent3:Spawn()
		local phys = ent3:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.RightTail:GetVelocity() + VectorRand() * 550 + Vector(0, 0, 700))
			phys:AddAngleVelocity(VectorRand() * 50)
		end
		if driverisvalid then
			ent3:SetPhysicsAttacker(driver)
		end
		ent3:Fire("kill", "", math.Rand(12, 15))
		if math.random(1, 2) == 1 then
			local fire = ents.Create("env_fire_trail")
			if fire:IsValid() then
				fire:SetPos(ent3:GetPos())
				fire:Spawn()
				fire:SetParent(ent3)
			end
		end
	end
end

ENT.ProcessDamage = VEHICLEGENERICPROCESSDAMAGE
