AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetPos(self:GetPos() + self.CreationOffset)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		phys:SetMass(1500)
		phys:EnableMotion(true)
		phys:EnableDrag(false)
		phys:Wake()
	end

	self:StartMotionController()

	self:SetVHealth(self.MaxHealth)

	self.NextShoot = 0
	self.NextShoot2 = 0
	self.Destroy = CurTime() + 45
	self.NextCollatSound = 0
	self.Thrust = 0
	--self.AfterBurner = 0
	self.NextThrustUpdate = 0
	self.CreationTollerance = true
	self.LastDriver = NULL
	self.LastEject = NULL
	self.NextAllowPhysicsDamage = 0
	self.IsHoveringOverGround = true

	self.LastAttacked = 0
	self.Attacker = NULL
	self.Inflictor = NULL
end

util.PrecacheSound("ambient/machines/thumper_startup1.wav")
function ENT:PilotEnter(pl)
	self:EmitSound("ambient/machines/thumper_startup1.wav")
	self:SetSkin(1)
	self:SetTeam(pl:Team())
	self.Destroy = 99999999
	self.LastDriver = pl
end

function ENT:PilotExit(pl)
	pl:SetVelocity(self:GetVelocity() * 0.9)
	self.LastEject = pl
	self.LastDriver = NULL
	self:SetSkin(0)
end

function ENT:Enter(pl, veh, role)
	self:PilotEnter(pl)
end

function ENT:Exit(pl, veh, role)
	self:PilotExit(pl)
end

function ENT:CreateChildren()
	local vPos = self:GetPos()

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(-16, 0, 24))
		ent:SetAngles(Angle(0, 270, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(100)
		ent.Enter = PilotEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.PilotSeat = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local wing = ents.Create("vehiclepart")
	if wing:IsValid() then
		wing:SetModel("models/gibs/helicopter_brokenpiece_05_tailfan.mdl")
		wing:SetPos(vPos + Vector(-32, -90, 0))
		wing:SetAngles(Angle(0, 60, -90))
		wing:Spawn()
		wing.VehicleParent = self
		local phys = wing:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(100)
		constraint.Weld(self, wing, 0, 0, 0, 1)
		constraint.NoCollide(ent, wing, 0, 0)
		self:DeleteOnRemove(wing)
		self.RightWing = wing

		local stub = ents.Create("vehiclepart")
		if stub:IsValid() then
			stub:SetModel("models/props_combine/headcrabcannister01a.mdl")
			stub:SetPos(vPos + Vector(-32, -90, 0))
			stub:SetAngles(Angle(0, 0, 0))
			stub:Spawn()
			stub.VehicleParent = self
			local phys = stub:GetPhysicsObject()
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:SetMass(100)
			constraint.Weld(wing, stub, 0, 0, 0, 1)
			self:DeleteOnRemove(stub)
			self.RightStub = stub
			--timer.Simple(0, util.SpriteTrail, stub, 0, color_white, false, 32, 8, 1, 0.05, "trails/smoke.vmt")
		end
	end

	local wing2 = ents.Create("vehiclepart")
	if wing2:IsValid() then
		wing2:SetModel("models/gibs/helicopter_brokenpiece_05_tailfan.mdl")
		wing2:SetPos(vPos + Vector(-32, 90, 0))
		wing2:SetAngles(Angle(0, -60, 90))
		wing2:Spawn()
		wing2.VehicleParent = self
		local phys = wing2:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(100)
		constraint.Weld(self, wing2, 0, 0, 0, 1)
		constraint.NoCollide(ent, wing2, 0, 0)
		self:DeleteOnRemove(wing2)
		self.LeftWing = wing2

		local stub = ents.Create("vehiclepart")
		if stub:IsValid() then
			stub:SetModel("models/props_combine/headcrabcannister01a.mdl")
			stub:SetPos(vPos + Vector(-32, 90, 0))
			stub:SetAngles(Angle(0, 0, 0))
			stub:Spawn()
			stub.VehicleParent = self
			local phys = stub:GetPhysicsObject()
			phys:EnableGravity(false)
			phys:EnableDrag(false)
			phys:SetMass(100)
			constraint.Weld(wing2, stub, 0, 0, 0, 1)
			self:DeleteOnRemove(stub)
			self.LeftStub = stub
			--timer.Simple(0, util.SpriteTrail, stub, 0, color_white, false, 32, 8, 1, 0.05, "trails/smoke.vmt")
		end
	end

	constraint.Weld(wing2, wing, 0, 0, 0, 1)
end

function ENT:SetThrust(fThrust)
	self.Thrust = fThrust
end

function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local driver = self.PilotSeat:GetDriver()

	local thrust = self.Thrust

	if not driver:IsValid() then
		self.IsHoveringOverGround = true
		if thrust ~= 0 then
			self:SetThrust(0)
		end
		phys:EnableGravity(true)
		phys:SetAngleDragCoefficient(1)

		return SIM_NOTHING
	end

	phys:SetAngleDragCoefficient(2000000)
	if driver:KeyDown(IN_FORWARD) then
		local oldthrust = thrust
		thrust = math.min(2500, thrust + frametime * 800)
		if thrust ~= oldthrust then
			self:SetThrust(thrust)
		end
		if self:GetSkin() ~= 1 then
			self:SetSkin(1)
		end
	elseif driver:KeyDown(IN_BACK) then
		local oldthrust = thrust
		thrust = math.min(2500, math.max(0, thrust + frametime * -800))
		if thrust ~= oldthrust then
			self:SetThrust(thrust)
		end
		if self:GetSkin() ~= 1 then
			self:SetSkin(1)
		end
	elseif self:GetSkin() ~= 1 then
		self:SetSkin(1)
		local thrust = math.min(2500, self.Thrust)
		phys:EnableGravity(thrust < 1250)
		if thrust ~= self.Thrust then
			self:SetThrust(thrust)
		end
	end

	phys:EnableGravity(thrust < 1250)

	local forward = self:GetForward()
	local vel = frametime * thrust * 0.6 * forward + self:GetVelocity() * (1 - frametime * 1.43)

	local vellength = vel:Length()
	if 1350 < vellength then
		vel = vel * (1350 / vellength)
	end

	local aimang = driver:EyeAngles()
	local getangles = self:GetAngles()

	local diffangles = self:WorldToLocalAngles(aimang)

	local newangles = getangles

	if thrust < 1250 then -- Hover
		local trace = {mask = MASK_HOVER, filter = self}
		trace.start = self:GetPos()
		trace.endpos = trace.start + Vector(0, 0, -128)
		local tr = util.TraceLine(trace)

		if tr.Hit then
			local diffangles2 = self:WorldToLocalAngles(Angle(0, newangles.yaw, 0))

			tr.HitPos.z = tr.HitPos.z + 102
			vel = vel + (tr.HitPos - trace.start) * 0.21
			newangles:RotateAroundAxis(newangles:Forward(), diffangles2.roll * frametime * 2)
			newangles:RotateAroundAxis(newangles:Right(), diffangles2.pitch * frametime * -1)
			newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime)
			self.IsHoveringOverGround = true
		else
			if driver:KeyDown(IN_MOVELEFT) then
				newangles:RotateAroundAxis(newangles:Forward(), frametime * -140)
			elseif driver:KeyDown(IN_MOVERIGHT) then
				newangles:RotateAroundAxis(newangles:Forward(), frametime * 140)
			end

			newangles:RotateAroundAxis(newangles:Right(), diffangles.pitch * frametime * -0.6)
			newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 0.5)
			self.IsHoveringOverGround = false
		end
	else
		self.IsHoveringOverGround = false
		if driver:KeyDown(IN_MOVELEFT) then
			newangles:RotateAroundAxis(newangles:Forward(), frametime * -140)
		elseif driver:KeyDown(IN_MOVERIGHT) then
			newangles:RotateAroundAxis(newangles:Forward(), frametime * 140)
		end

		newangles:RotateAroundAxis(newangles:Right(), diffangles.pitch * frametime * -0.73)
		newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 0.61)
	end

	self:SetAngles(newangles)
	phys:SetVelocityInstantaneous(vel)

	return SIM_NOTHING
end

--[[function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local driver = self.PilotSeat:GetDriver()

	if not driver:IsValid() then
		self.IsHoveringOverGround = true
		phys:SetAngleDragCoefficient(1)

		return SIM_NOTHING
	end

	phys:SetAngleDragCoefficient(1)
	if self:GetSkin() ~= 1 then
		self:SetSkin(1)
	end

	local forward = self:GetForward()

	local diffangles = self:WorldToLocalAngles(driver:EyeAngles())

	local addangles = Angle(0, 0, 0)

	self.IsHoveringOverGround = false
	if driver:KeyDown(IN_MOVELEFT) then
		addangles.roll = addangles.roll + -140
	elseif driver:KeyDown(IN_MOVERIGHT) then
		addangles.roll = addangles.roll + 140
	end

	addangles.pitch = addangles.pitch + diffangles.pitch * -0.73
	addangles.yaw = addangles.yaw + diffangles.yaw * 0.61

	if driver:KeyDown(IN_FORWARD) then
		phys:AddVelocity(1000 * frametime * forward)
	elseif driver:KeyDown(IN_BACK) then
		phys:AddVelocity(-400 * frametime * forward)
	end

	phys:AddAngleVelocity(addangles * frametime)

	local curvel = phys:GetVelocity()
	local curspeed = curvel:Length()
	if curspeed >= 2000 then
		phys:SetVelocityInstantaneous(curvel:GetNormal() * 2000)
	end

	phys:AddVelocity(Vector(0, 0, math.min(1, curspeed / 800) * frametime * 600))

	return SIM_NOTHING
end]]

local lastattacker = NULL
local lastinflictor = NULL

local function HoverCycleBCb(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent and ent.TakeSpecialDamage then
		ent:TakeSpecialDamage(dmginfo:GetDamage(), DMGTYPE_PIERCING, lastattacker, lastinflictor)

		return {damage = false}
	end
end

local lockedonentity = NULL

local function LockOnCB(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValid() and string.find(ent:GetClass(), "vehicle_nox") and ent:Team() ~= attacker:Team() then
		lockedonentity = ent
	elseif ent.VehicleParent and ent.VehicleParent:Team() ~= attacker:Team() then
		lockedonentity = ent.VehicleParent
	else
		lockedonentity = NULL
	end

	return {effects = false, damage = false}
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
		self:TakeSpecialDamage(math.ceil(data.Speed * 0.04), DMGTYPE_IMPACT, NULL, NULL, data.HitPos)
	end

	if self.NextThrustUpdate < CurTime() and self:GetNetworkedFloat("thrust", 0) ~= self.Thrust then
		self.NextThrustUpdate = CurTime() + 0.4		
		self:SetNetworkedFloat("thrust", self.Thrust)
	end

	local skipthink
	local driver = self.PilotSeat:GetDriver()
	if driver:IsValid() then
		self.Destroy = 99999999

		self.LeftWing:SetPhysicsAttacker(driver)
		self.RightWing:SetPhysicsAttacker(driver)
		self.LeftStub:SetPhysicsAttacker(driver)
		self.RightStub:SetPhysicsAttacker(driver)
		self.PilotSeat:SetPhysicsAttacker(driver)

		if driver:KeyDown(IN_ATTACK) and self.NextShoot <= CurTime() and not self.IsHoveringOverGround and not self:IsMDF() then
			self.NextShoot = CurTime() + 0.05
			skipthink = true
			lastattacker = driver
			lastinflictor = self

			local bullet = {}
			bullet.Num = 1
			bullet.Dir = self:GetForward()
			bullet.Src = self:GetPos() + bullet.Dir * 65
			bullet.Spread = Vector(0.006, 0.006, 0)
			bullet.Tracer = 1
			bullet.Force = 4
			bullet.Damage = 17
			bullet.TracerName = "manatrace"
			bullet.Callback = HoverCycleBCb

			self:FireBullets(bullet)

			self:EmitSound("npc/strider/strider_minigun2.wav")
			
		elseif driver:KeyDown(IN_ATTACK) and self.IsHoveringOverGround then
			self:CantFireWarning()
		end

		if driver:KeyDown(IN_ATTACK2) and self.NextShoot2 <= CurTime() and not self.IsHoveringOverGround then
			self.NextShoot2 = CurTime() + 2.5
			local dteam = driver:Team()
			local fwd = self:GetForward()

			self:FireBullets({Num = 1, Dir = fwd, Src = self:GetPos() + fwd * 104, Spread = Vector(0, 0, 0), Tracer = 0, Force = 0, Damage = 0, HullSize = 48, Callback = LockOnCB})

			local ent = lockedonentity or NULL

			local proj = ents.Create("projectile_ravenmissile")
			if proj:IsValid() then
				if self.Alt then
					proj:SetPos(self.LeftStub:GetPos() + self.LeftStub:GetForward() * 65)
					proj:SetAngles(self.LeftStub:GetAngles())
					self.LeftStub:EmitSound("weapons/rpg/rocketfire1.wav")
				else
					proj:SetPos(self.RightStub:GetPos() + self.RightStub:GetForward() * 65)
					proj:SetAngles(self.RightStub:GetAngles())
					self.RightStub:EmitSound("weapons/rpg/rocketfire1.wav")
				end
				self.Alt = not self.Alt
				local c = team.GetColor(self:Team())
				proj:SetColor(Color(c.r, c.g, c.b, 255))
				proj:Spawn()
				proj:SetTeamID(dteam)
				proj.Target = ent
				if ent:IsValid() then
					driver:SendLua("surface.PlaySound(\"buttons/button3.wav\")")
					for _, veh in pairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
						if veh:GetVehicleParent() == ent then
							local enemydriver = veh:GetDriver()
							if enemydriver:IsPlayer() then enemydriver:SendLua("RLO()") end
						end
					end
				end
				proj:SetOwner(driver)
				local phys = proj:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(fwd * 2800)
				end
			elseif driver:KeyDown(IN_ATTACK) and self.IsHoveringOverGround then
				self:CantFireWarning()
			end
		end
	end

	if self.Destroy < CurTime() then
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 512)) do
			if ent.SendLua and ent:Alive() then
				self.Destroy = CurTime() + 15
				return SIM_NOTHING
			end
		end
		self:Remove()
	elseif self.Destroy == 99999999 then
		self.Destroy = CurTime() + 45
	end

	if skipthink then
		self:NextThink(CurTime())
		return true
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

		if 900 < data.Speed then
			local driver = self.PilotSeat:GetDriver()
			self.Attacker = driver
			self.Inflictor = driver
			self.DoDestroy = true
		elseif 250 < data.Speed then
			if self.NextCollatSound < CurTime() then
				self:EmitSound("vehicles/v8/vehicle_impact_heavy"..math.random(1,4)..".wav")
				self.NextCollatSound = CurTime() + 0.5
			end
			self.PhysicsData = data
			self:NextThink(CurTime())
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

	local driver = self.PilotSeat:GetDriver()

	local driverisvalid = driver:IsValid()

	if driverisvalid then
		driver:RemoveStatus("forcefield", false, true)
		driver:TakeSpecialDamage(driver:Health() + 30, DMGTYPE_FIRE, attacker, inflictor)
	elseif self.LastEject:IsValid() then
		driver = self.LastEject
		driverisvalid = true
		inflictor = self
	end

	ExplosiveDamage(attacker, self, 400, 400, 1, 0.3, 8)

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
			phys:SetMass(250)
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
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent2:GetPos())
			fire:Spawn()
			fire:SetParent(ent2)
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
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent3:GetPos())
			fire:Spawn()
			fire:SetParent(ent3)
		end
	end

	local ent2 = ents.Create("prop_physics_multiplayer")
	if ent2:IsValid() then
		ent2:SetPos(self.LeftStub:GetPos())
		ent2:SetAngles(self.LeftStub:GetAngles())
		ent2:SetModel(self.LeftStub:GetModel())
		ent2:Spawn()
		local phys = ent2:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(250)
			phys:SetVelocityInstantaneous(self.LeftStub:GetVelocity() + VectorRand() * 550 + Vector(0, 0, 800))
			phys:AddAngleVelocity(VectorRand() * 50)
		end
		if driverisvalid then
			ent2:SetPhysicsAttacker(driver)
		end
		ent2:Fire("kill", "", math.Rand(12, 15))
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent2:GetPos())
			fire:Spawn()
			fire:SetParent(ent2)
		end
	end

	local ent3 = ents.Create("prop_physics_multiplayer")
	if ent3:IsValid() then
		ent3:SetPos(self.RightStub:GetPos())
		ent3:SetAngles(self.RightStub:GetAngles())
		ent3:SetModel(self.RightStub:GetModel())
		ent3:Spawn()
		local phys = ent3:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(250)
			phys:SetVelocityInstantaneous(self.RightStub:GetVelocity() + VectorRand() * 550 + Vector(0, 0, 700))
			phys:AddAngleVelocity(VectorRand() * 50)
		end
		if driverisvalid then
			ent3:SetPhysicsAttacker(driver)
		end
		ent3:Fire("kill", "", math.Rand(12, 15))
		local fire = ents.Create("env_fire_trail")
		if fire:IsValid() then
			fire:SetPos(ent3:GetPos())
			fire:Spawn()
			fire:SetParent(ent3)
		end
	end
end

ENT.ProcessDamage = VEHICLEGENERICPROCESSDAMAGE
