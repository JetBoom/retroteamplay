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
		phys:SetMass(800)
		phys:EnableMotion(true)
		phys:EnableDrag(false)
		phys:Wake()
	end

	self:StartMotionController()

	self:SetVHealth(self.MaxHealth)

	self.NextShoot = 0
	self.Destroy = CurTime() + 45
	self.NextCollatSound = 0
	self.Thrust = 0
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
		wing:SetModel("models/Gibs/helicopter_brokenpiece_03.mdl")
		wing:SetPos(vPos + Vector(-15, -42, 0))
		wing:SetAngles(Angle(0, 100, -140))
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
	end

	local wing2 = ents.Create("vehiclepart")
	if wing2:IsValid() then
		wing2:SetModel("models/Gibs/helicopter_brokenpiece_03.mdl")
		wing2:SetPos(vPos + Vector(-15, 42, 0))
		wing2:SetAngles(Angle(0, -100, 30))
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
		thrust = math.min(2500, thrust + frametime * 1150)
		if thrust ~= oldthrust then
			self:SetThrust(thrust)
		end
	elseif driver:KeyDown(IN_BACK) then
		local oldthrust = thrust
		thrust = math.max(0, thrust + frametime * -1150)
		if thrust ~= oldthrust then
			self:SetThrust(thrust)
		end
	end

	phys:EnableGravity(thrust < 1250)

	local forward = self:GetForward()
	local vel = frametime * thrust * 0.85 * forward + self:GetVelocity() * (1 - frametime * 1.48)
	if self:GetSkin() == 0 then
		self:SetSkin(1)
	end

	local vellength = vel:Length()
	if 1400 < vellength then
		vel = vel * (1400 / vellength)
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
			newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 1.3)
			self.IsHoveringOverGround = true
		else
			if driver:KeyDown(IN_MOVELEFT) then
				newangles:RotateAroundAxis(newangles:Forward(), frametime * -200)
			elseif driver:KeyDown(IN_MOVERIGHT) then
				newangles:RotateAroundAxis(newangles:Forward(), frametime * 200)
			end

			newangles:RotateAroundAxis(newangles:Right(), diffangles.pitch * frametime * -0.8)
			newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 0.75)
			self.IsHoveringOverGround = false
		end
	else
		self.IsHoveringOverGround = false
		if driver:KeyDown(IN_MOVELEFT) then
			newangles:RotateAroundAxis(newangles:Forward(), frametime * -200)
		elseif driver:KeyDown(IN_MOVERIGHT) then
			newangles:RotateAroundAxis(newangles:Forward(), frametime * 200)
		end

		newangles:RotateAroundAxis(newangles:Right(), diffangles.pitch * frametime * -1)
		newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 0.95)
	end

	self:SetAngles(newangles)
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
		self:TakeSpecialDamage(math.ceil(data.Speed * 0.04), DMGTYPE_IMPACT, NULL, NULL, data.HitPos)
	end

	if self.NextThrustUpdate < CurTime() and self:GetNetworkedFloat("thrust", 0) ~= self.Thrust then
		self:SetNetworkedFloat("thrust", self.Thrust)
		self.NextThrustUpdate = CurTime() + 0.5
	end

	local driver = self.PilotSeat:GetDriver()
	if driver:IsValid() then
		self.Destroy = 99999999

		self.LeftWing:SetPhysicsAttacker(driver)
		self.RightWing:SetPhysicsAttacker(driver)
		self.PilotSeat:SetPhysicsAttacker(driver)

		if driver:KeyDown(IN_ATTACK) and not self:IsMDF() and not self.IsHoveringOverGround then
			if self.NextShoot <= CurTime() then
				self.NextShoot = CurTime() + 0.05

				if self:GetSkin() ~= 2 then
					self:SetSkin(2)
				end

				lastattacker = driver
				lastinflictor = self

				local bullet = {Spread = Vector(0.015, 0.015, 0), Num = 1, Tracer = 1, Force = 4, Damage = 4, TracerName = "manatrace", Callback = HoverCycleBCb}

				bullet.Dir = self:GetForward()
				bullet.Src = self:GetPos() + bullet.Dir * 65

				self:FireBullets(bullet)

				--self:EmitSound("npc/strider/strider_minigun2.wav")
			end

			self:NextThink(CurTime())
			return true
		elseif self:GetSkin() == 2 or (driver:KeyDown(IN_ATTACK) and self.IsHoveringOverGround) then
			self:SetSkin(1)
			if driver:KeyDown(IN_ATTACK) and self.IsHoveringOverGround then
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

	ExplosiveDamage(attacker, self, 225, 225, 1, 0.34, 8)

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
end

ENT.ProcessDamage = VEHICLEGENERICPROCESSDAMAGE
