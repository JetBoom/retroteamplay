AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.DesiredCannonAngle = 0

function ENT:Initialize()
	self:SetModel(self.Model)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		phys:SetMass(7000)
		phys:EnableMotion(true)
		phys:Wake()
		self.Phys = phys
	end

	self:StartMotionController()

	self:SetVHealth(self.MaxHealth)

	self.NextShoot = 0
	self.Destroy = CurTime() + 30
	self.CreationTollerance = true
	self.LastPilot = NULL
	self.LastCannoneer = NULL
	self.LastTailGunner = NULL
	self.LastLeftPassenger = NULL
	self.LastRightPassenger = NULL
	self.LastRearPassenger1 = NULL
	self.LastRearPassenger2 = NULL
	
	self.LastCannon = 0
	self.LastMortar = 0
	self.LastBullet = 0
	self.LastAnchor = 0

	self.LastAttacked = 0
	self.Attacker = NULL
	self.Inflictor = NULL
end

function ENT:PilotExit(pl)
	pl:SetVelocity(self:GetVelocity() * 0.9)
	self.Phys:EnableGravity(true)
	self.LastPilot = NULL
	self.LastEject = pl
end

function ENT:Exit(pl, veh, role)
	if veh == self.PilotSeat then
		self:PilotExit(pl)
	elseif veh == self.CannonGunnerSeat then
		self.LastCannoneer = NULL
	elseif veh == self.TailGunnerSeat then
		self.LastTailGunner = NULL
	elseif veh == self.LeftPassengerSeat then
		self.LastLeftPassenger = NULL
	elseif veh == self.RightPassengerSeat then
		self.LastRightPassenger = NULL
	elseif veh == self.RearPassengerSeat1 then
		self.LastRearPassenger1 = NULL
	elseif veh == self.RearPassengerSeat2 then
		self.LastRearPassenger2 = NULL
	end
	timer.SimpleEx(0.25, self.UpdateCrew, self)
end

function ENT:PilotEnter(pl)
	local teamid = pl:Team()
	self:SetTeam(teamid)
	self:EmitSound("NPC_CombineGunship.PatrolPing")
	self:SetTeam(pl:Team())
	self.Destroy = 99999999
	self.LastPilot = pl
	self.Phys:EnableGravity(false)

	local passenger = self.CannonGunnerSeat:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.TailGunnerSeat:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.LeftPassengerSeat:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.RightPassengerSeat:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.RearPassengerSeat1:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
	passenger = self.RearPassengerSeat2:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= teamid then
		passenger:ExitVehicle()
	end
end

function ENT:Enter(pl, veh, role)
	if veh == self.PilotSeat then
		self:PilotEnter(pl)
	elseif veh == self.CannonGunnerSeat then
		self.LastCannoneer = pl
	elseif veh == self.TailGunnerSeat then
		self.LastTailGunner = pl
	elseif veh == self.LeftPassengerSeat then
		self.LastLeftPassenger = pl
	elseif veh == self.RightPassengerSeat then
		self.LastRightPassenger = pl
	elseif veh == self.RearPassengerSeat1 then
		self.LastRearPassenger1 = pl
	elseif veh == self.RearPassengerSeat2 then
		self.LastRearPassenger2 = pl
	end
	self:UpdateCrew()
end

function ENT:CreateChildren()
	local vPos = self:GetPos()

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(0, 130, 30))
		ent:SetAngles(Angle(0, 0, 0))
		ent:Spawn()
		ent:SetVehicleParent(self)
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:SetMass(5)
		ent.Enter = PilotEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.PilotSeat = ent
		self:SetPilotSeat(ent)
		ent:SetMaterial("models/debug/debugwhite")
	end
	
	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(0, 20, 110))
		ent:SetAngles(Angle(0, 0, 0))
		ent:Spawn()
		ent:SetVehicleParent(self)
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(20)
		ent.Enter = GunnerEnter
		constraint.Axis(ent, self, 0, 0, Vector(0, 0, -16), Vector(0, 36, 21), 0, 0, 0, 1, Vector(0, 0, 1))
		self:DeleteOnRemove(ent)
		self.CannonGunnerSeat = ent
		self:SetCannonGunnerSeat(ent)
		ent:SetMaterial("models/debug/debugwhite")
		local cannon = ents.Create("prop_dynamic_override")
		if cannon:IsValid() then
			cannon:SetModel("models/props_combine/combinethumper002.mdl")
			cannon:SetPos(vPos + Vector(36, -10, 90))
			cannon:SetAngles(Angle(0, 0, -90))
			cannon:Spawn()
			cannon:SetVehicleParent(self)
			cannon:SetParent(ent)
			self:DeleteOnRemove(cannon)
			self.Cannon = cannon
			self:SetCannon(cannon)
		end
	end
	
	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(0, -60, 60))
		ent:SetAngles(Angle(0, 180, 0))
		ent:Spawn()
		ent:SetVehicleParent(self)
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = GunnerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.TailGunnerSeat = ent
		self:SetGunnerSeat(ent)
		ent:SetMaterial("models/debug/debugwhite")
	end
	
	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(-80, -110, 0))
		ent:SetAngles(Angle(0, 90, 0))
		ent:Spawn()
		ent:SetVehicleParent(self)
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = PassengerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.LeftPassengerSeat = ent
		ent:SetMaterial("models/debug/debugwhite")
	end
	
	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(80, -110, 0))
		ent:SetAngles(Angle(0, -90, 0))
		ent:Spawn()
		ent:SetVehicleParent(self)
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = PassengerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.RightPassengerSeat = ent
		ent:SetMaterial("models/debug/debugwhite")
	end
	
	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(30, -170, 0))
		ent:SetAngles(Angle(0, 180, 0))
		ent:Spawn()
		ent:SetVehicleParent(self)
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = PassengerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.RearPassengerSeat1 = ent
		ent:SetMaterial("models/debug/debugwhite")
	end
	
	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(-30, -170, 0))
		ent:SetAngles(Angle(0, 180, 0))
		ent:Spawn()
		ent:SetVehicleParent(self)
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		ent.Enter = PassengerEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.RearPassengerSeat2 = ent
		ent:SetMaterial("models/debug/debugwhite")
	end

	local platel = ents.Create("vehiclepart")
	if platel:IsValid() then
		platel:SetModel("models/props_combine/combine_barricade_tall01b.mdl")
		platel:SetPos(vPos + Vector(48, -60, 0))
		platel:SetAngles(Angle(0, 0, -90))
		platel:Spawn()
		platel:SetVehicleParent(self)
		local phys = platel:GetPhysicsObject()
		phys:EnableGravity(false)
		constraint.Weld(self, platel, 0, 0, 0, 1)
		self:DeleteOnRemove(platel)
		self.ArmorPlateLeft = platel
	end

	local plater = ents.Create("vehiclepart")
	if plater:IsValid() then
		plater:SetModel("models/props_combine/combine_barricade_tall01b.mdl")
		plater:SetPos(vPos + Vector(-48, -60, 0))
		plater:SetAngles(Angle(180, 0, -90))
		plater:Spawn()
		plater:SetVehicleParent(self)
		local phys = plater:GetPhysicsObject()
		phys:EnableGravity(false)
		constraint.Weld(self, plater, 0, 0, 0, 1)
		self:DeleteOnRemove(plater)
		self.ArmorPlateRight = plater
	end
	
	local platef = ents.Create("vehiclepart")
	if platef:IsValid() then
		platef:SetModel("models/props_combine/combine_barricade_med02b.mdl")
		platef:SetPos(vPos + Vector(0, -10, 40))
		platef:SetAngles(Angle(-90, -90, 0))
		platef:Spawn()
		platef:SetVehicleParent(self)
		local phys = platef:GetPhysicsObject()
		phys:EnableGravity(false)
		constraint.Weld(self, platef, 0, 0, 0, 1)
		self:DeleteOnRemove(platef)
		self.ArmorPlateFront = platef
	end
	
	constraint.NoCollide(platef, plater, 0, 0)
	constraint.NoCollide(platef, platel, 0, 0)
	constraint.NoCollide(platel, plater, 0, 0)
	
	constraint.NoCollide(self.PilotSeat, platef, 0, 0)
end

function ENT:UpdateCrew()
	if self:IsValid() then
		local lastpilotindex = 0
		if self.LastPilot:IsValid() then lastpilotindex = self.LastPilot:EntIndex() end
		local lastcannoneerindex = 0
		if self.LastCannoneer:IsValid() then lastcannoneerindex = self.LastCannoneer:EntIndex() end
		local lasttailgunnerindex = 0
		if self.LastTailGunner:IsValid() then lasttailgunnerindex = self.LastTailGunner:EntIndex() end
		local lastleftpassengerindex = 0
		if self.LastLeftPassenger:IsValid() then lastleftpassengerindex = self.LastLeftPassenger:EntIndex() end
		local lastrightpassengerindex = 0
		if self.LastRightPassenger:IsValid() then lastrightpassengerindex = self.LastRightPassenger:EntIndex() end
		local lastrearpassenger1index = 0
		if self.LastRearPassenger1:IsValid() then lastrearpassenger1index = self.LastRearPassenger1:EntIndex() end
		local lastrearpassenger2index = 0
		if self.LastRearPassenger2:IsValid() then lastrearpassenger2index = self.LastRearPassenger2:EntIndex() end
		BroadcastLua("RecDND("..self:EntIndex()..","..lastpilotindex..","..lastcannoneerindex..","..lasttailgunnerindex..","..lastleftpassengerindex..","..lastrightpassengerindex..","..lastrearpassenger1index..","..lastrearpassenger2index..")")
	end
end

function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()
	
	local isMDF = self:IsMDF()
	local seat = self.CannonGunnerSeat
	local gunner = seat:GetDriver()
	if gunner:IsValid() then
		if not isMDF then
			if gunner:KeyDown(IN_MOVELEFT) then
				self.DesiredCannonAngle = math.NormalizeAngle(self.DesiredCannonAngle + frametime * 120)
			elseif gunner:KeyDown(IN_MOVERIGHT) then
				self.DesiredCannonAngle = math.NormalizeAngle(self.DesiredCannonAngle - frametime * 120)
			end
			if gunner:KeyPressed(IN_MOVELEFT) then
				seat:EmitSound("vehicles/tank_turret_start1.wav")
			elseif gunner:KeyPressed(IN_MOVERIGHT) then
				seat:EmitSound("vehicles/tank_turret_start1.wav")
			end
			if gunner:KeyReleased(IN_MOVELEFT) then
				seat:EmitSound("vehicles/tank_turret_stop1.wav")
			elseif gunner:KeyReleased(IN_MOVERIGHT) then
				seat:EmitSound("vehicles/tank_turret_stop1.wav")
			end
		end

		local newangles = seat:GetAngles()
		local diffangles = seat:WorldToLocalAngles(Angle(0, self.DesiredCannonAngle, 0))
		newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 120)
		seat:SetAngles(newangles)
		seat:GetPhysicsObject():SetAngleDragCoefficient(0)
	else
		seat:GetPhysicsObject():SetAngleDragCoefficient(100000)
	end

	local driver = self.PilotSeat:GetDriver()
	
	if self:GetSkin() == 1 and not phys:IsGravityEnabled() then
		phys:EnableGravity(true)
	elseif self:GetSkin() == 0 and phys:IsGravityEnabled() then
		phys:EnableGravity(false)
		phys:SetAngleDragCoefficient(0)
	end

	if not driver:IsValid() or self:GetSkin() == 1 then
		phys:EnableGravity(true)
		phys:SetAngleDragCoefficient(1)
		return SIM_NOTHING
	end
	phys:SetAngleDragCoefficient(1000000)

	local vel = self:GetVelocity() * (1 - frametime)

	if driver:KeyDown(IN_FORWARD) then
		local forward = self:GetRight()
		forward.z = 0
		forward:Normalize()
		vel = vel + frametime * -200 * forward
		local vellength = vel:Length()
		if vellength > 1000 then
			vel = vel * (1000 / vellength)
		end
	elseif driver:KeyDown(IN_BACK) then
		local forward = self:GetRight()
		forward.z = 0
		forward:Normalize()
		vel = vel + frametime * 100 * forward
		local vellength = vel:Length()
		if vellength > 600 then
			vel = vel * (600 / vellength)
		end
	end

	if driver:KeyDown(IN_MOVELEFT) then
		local forward = self:GetForward()
		forward.z = 0
		forward:Normalize()
		vel = vel + frametime * -100 * forward
		local vellength = vel:Length()
		if vellength > 1000 then
			vel = vel * (1000 / vellength)
		end
	elseif driver:KeyDown(IN_MOVERIGHT) then
		local forward = self:GetForward()
		forward.z = 0
		forward:Normalize()
		vel = vel + frametime * 100 * forward
		local vellength = vel:Length()
		if vellength > 1000 then
			vel = vel * (1000 / vellength)
		end
	end

	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = trace.start + Vector(0, 0, -80)
	trace.mask = MASK_HOVER
	trace.filter = self
	trace.mins = Vector(-60,-140,-10)
	trace.maxs = Vector(60,140,10)
	local tr = util.TraceHull(trace)

	if tr.Hit then
		tr.HitPos.z = tr.HitPos.z + 52
	end

	vel = vel + (tr.HitPos - trace.start) * 0.35
	vel.z = math.max(vel.z, -400)

	local aimang = driver:EyeAngles()
	local getangles = self:GetAngles()

	local diffangles = self:WorldToLocalAngles(aimang) + Angle(0,-90,0)
	local diffangles2 = self:WorldToLocalAngles(Angle(0, getangles.yaw, 0))

	getangles:RotateAroundAxis(getangles:Up(), diffangles.yaw * frametime * 0.6)
	getangles:RotateAroundAxis(getangles:Forward(), diffangles2.roll * frametime * 1)
	getangles:RotateAroundAxis(getangles:Right(), diffangles2.pitch * frametime * -1)

	self:SetAngles(getangles)
	phys:SetVelocityInstantaneous(vel)

	return SIM_NOTHING
end

function ENT:Think()
	if self.DoDestroy then
		self:Destroyed(self.Attacker or NULL, self.Inflictor or NULL)
		self:Remove()
		return
	end

	local isMDF = self:IsMDF()
	
	local driver = self.PilotSeat:GetDriver()

	if driver:IsValid() and not isMDF then
		self.Destroy = 99999999

		self.PilotSeat:SetPhysicsAttacker(driver)
		if driver:KeyDown(IN_ATTACK) and self.LastAnchor <= CurTime() then
			self.LastAnchor = CurTime() + 3
			if self:GetSkin() == 0 then
				local trace = {}
				trace.start = self:GetPos()
				trace.endpos = trace.start + Vector(0, 0, -80)
				trace.mask = MASK_HOVER
				trace.filter = self
				local tr = util.TraceLine(trace)

				if tr.HitWorld then
					self:SetSkin(1)
				end
			else
				self:SetSkin(0)
				
			end
		end
	end
	
	local gunner = self.CannonGunnerSeat:GetDriver()
	if gunner:IsValid() then
		if gunner:KeyDown(IN_ATTACK) and not isMDF and self.LastCannon <= CurTime() then
			self.LastCannon = CurTime() + (self:GetSkin() == 1 and 4 or 7)

			local dir = gunner:GetAimVector()
			local c = team.GetColor(gunner:Team())
			local ang = gunner:EyeAngles()
				ang.pitch = math.min(ang.pitch, 0)
				ang.yaw = self.CannonGunnerSeat:GetAngles().yaw + 90
				
			local vel = (self:GetSkin() == 1 and 1600) or 900
			local ent = ents.Create("projectile_dreadnautbomb")
			if ent:IsValid() then
				ent:SetPos(gunner:GetShootPos() + ang:Forward() * 60)
				ent:SetOwner(gunner)
				ent:SetTeamID(gunner:Team())
				ent:SetColor(Color(c.r, c.g, c.b, 255))
				ent:Spawn()
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(ang:Forward() * vel)
				end
			end
			self.CannonGunnerSeat:EmitSound("weapons/shotgun/shotgun_dbl_fire.wav", 150, math.Rand(50,70))
			util.ScreenShake(self.CannonGunnerSeat:GetPos(), 7, 8, 2, 1024)
		end
	end
	
	local cannon = self.Cannon
	if cannon:IsValid() then
		if gunner:IsValid() then
			local ang = gunner:EyeAngles()
			ang.pitch = math.min(ang.pitch, 0)
			ang.yaw = self.CannonGunnerSeat:GetAngles().yaw + 90
			ang:RotateAroundAxis(ang:Up(), -90)
			ang:RotateAroundAxis(ang:Forward(), -90)
			cannon:SetAngles(ang)
		else
			local ang = self.CannonGunnerSeat:GetAngles()
			ang:RotateAroundAxis(ang:Forward(), -90)
			cannon:SetAngles(ang)
		end
	end
	
	local tailgunner = self.TailGunnerSeat:GetDriver()
	if tailgunner:IsValid() then
		local ang = tailgunner:EyeAngles()
		local dir = tailgunner:GetAimVector()
		
		if tailgunner:KeyDown(IN_ATTACK) and self.LastMortar <= CurTime() then
			self.LastMortar = CurTime() + 2

			local dir = tailgunner:GetAimVector()
			local proj = ents.Create("projectile_assaultrovercannon")
			if proj:IsValid() then
				proj:SetPos(tailgunner:GetShootPos() + ang:Forward() * 60)
				proj:SetAngles(dir:Angle())
				proj:SetOwner(tailgunner)
				proj:SetSkin(self:Team())
				proj:Spawn()
				proj:SetTeamID(tailgunner:Team())
				
				proj:EmitSound("vehicles/Airboat/pontoon_impact_hard1.wav", 80, math.Rand(95, 105))
				local phys = proj:GetPhysicsObject()
				if phys:IsValid() then
					dir.z = math.Clamp(tailgunner:GetAimVector().z, dir.z - 0.25, dir.z + 0.25)
					phys:SetVelocityInstantaneous(dir:GetNormal() * math.max(self:GetVelocity():Length() * 1.2, 775))
				end
			end
		elseif tailgunner:KeyDown(IN_ATTACK2) and self.LastBullet <= CurTime() then
			self.LastBullet = CurTime() + 0.2
			
			local ent = ents.Create("projectile_photoncannon")
			if ent:IsValid() then
				ent:SetPos(tailgunner:GetShootPos() + ang:Forward())
				ent:SetOwner(tailgunner)
				ent:Spawn()
				ent:SetTeamID(tailgunner:GetTeamID())

				ent.Damage = 6
				ent.Inflictor = self

				ent:Launch(dir)
			end

			self:EmitSound("npc/strider/strider_minigun2.wav")
		end
	end

	if CurTime() >= self.Destroy then
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
	
	self:NextThink(CurTime())
	return true
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

	local driver = self.PilotSeat:GetDriver()

	local driverisvalid = driver:IsValid()

	if driverisvalid then
		driver:RemoveStatus("forcefield", false, true)
		driver:TakeSpecialDamage(driver:Health() + 45, DMGTYPE_FIRE, attacker, inflictor)
	end

	ExplosiveDamage(attacker, self, 600, 600, 1, 0.5, 5)

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
		ent:SetModel(self.Model)
		ent:Spawn()
		local phys = ent:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self:GetVelocity() + Vector(0, 0, 600))
			phys:AddAngleVelocity(VectorRand() * 50)
		end
		if driverisvalid then
			ent:SetPhysicsAttacker(driver)
		end
		ent:Fire("kill", "", 14)
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent:GetPos())
			fire:Spawn()
			fire:SetParent(ent)
		end
		ent:EmitSound("nox/explosion05.wav")
	end

	local ent2 = ents.Create("prop_physics_multiplayer")
	if ent2:IsValid() then
		ent2:SetPos(self.ArmorPlateLeft:GetPos())
		ent2:SetAngles(self.ArmorPlateLeft:GetAngles())
		ent2:SetModel(self.ArmorPlateLeft:GetModel())
		ent2:Spawn()
		local phys = ent2:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetVelocityInstantaneous(self.ArmorPlateLeft:GetVelocity() + VectorRand() * 850 + Vector(0, 0, 800))
			phys:AddAngleVelocity(VectorRand() * 50)
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

	local ent3 = ents.Create("prop_physics_multiplayer")
	if ent3:IsValid() then
		ent3:SetPos(self.ArmorPlateRight:GetPos())
		ent3:SetAngles(self.ArmorPlateRight:GetAngles())
		ent3:SetModel(self.ArmorPlateRight:GetModel())
		ent3:Spawn()
		ent3:SetLocalVelocity(self.ArmorPlateRight:GetVelocity() + VectorRand() * 850 + Vector(0, 0, 700))
		ent3:GetPhysicsObject():AddAngleVelocity(VectorRand() * 1000)
		if driverisvalid then
			ent3:SetPhysicsAttacker(driver)
		end
		ent3:Fire("kill", "", 14)
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent3:GetPos())
			fire:Spawn()
			fire:SetParent(ent3)
		end
	end
	
	local ent4 = ents.Create("prop_physics_multiplayer")
	if ent4:IsValid() then
		ent4:SetPos(self.ArmorPlateFront:GetPos())
		ent4:SetAngles(self.ArmorPlateFront:GetAngles())
		ent4:SetModel(self.ArmorPlateFront:GetModel())
		ent4:Spawn()
		ent4:SetLocalVelocity(self.ArmorPlateFront:GetVelocity() + VectorRand() * 850 + Vector(0, 0, 700))
		ent4:GetPhysicsObject():AddAngleVelocity(VectorRand() * 1000)
		if driverisvalid then
			ent4:SetPhysicsAttacker(driver)
		end
		ent4:Fire("kill", "", 14)
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent4:GetPos())
			fire:Spawn()
			fire:SetParent(ent4)
		end
	end
	
	local ent5 = ents.Create("prop_physics_multiplayer")
	if ent5:IsValid() then
		ent5:SetPos(self.Cannon:GetPos())
		ent5:SetAngles(self.Cannon:GetAngles())
		ent5:SetModel(self.Cannon:GetModel())
		ent5:Spawn()
		ent5:SetLocalVelocity(self.Cannon:GetVelocity() + VectorRand() * 850 + Vector(0, 0, 700))
		local phys = ent5:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(150)
			phys:AddAngleVelocity(VectorRand() * 1000)
		end
		if driverisvalid then
			ent5:SetPhysicsAttacker(driver)
		end
		ent5:Fire("kill", "", 14)
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent5:GetPos())
			fire:Spawn()
			fire:SetParent(ent5)
		end
	end
end

ENT.ProcessDamage = VEHICLEGENERICPROCESSDAMAGE
