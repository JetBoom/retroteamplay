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
		phys:SetMass(2000)
		phys:EnableMotion(true)
		phys:EnableDrag(false)
		phys:Wake()
	end

	self:StartMotionController()

	self:SetVHealth(self.MaxHealth)

	self.NextShoot = 0
	self.NextBomb = 0
	self.Destroy = CurTime() + 30
	self.NextCollatSound = 0
	self.Thrust = 0
	self.NextThrustUpdate = 0
	self.CreationTollerance = true
	self.LastDriver = NULL
	self.LastTailGunner = NULL
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

	local passenger = self.TailGunnerSeat:GetDriver()
	if passenger:IsValid() and passenger:Team() ~= pl:Team() then
		passenger:ExitVehicle()
	end
end

function ENT:Enter(pl, veh, role)
	if veh == self.PilotSeat then
		self:PilotEnter(pl)
	else
		self.LastTailGunner = pl
	end

	self:UpdateCrew()
end

function ENT:Exit(pl, veh)
	if veh == self.PilotSeat then
		self.LastDriver = NULL
		self.LastEject = pl
		self:SetSkin(0)
	else
		self.LastTailGunner = NULL
	end

	pl:SetVelocity(self:GetVelocity() * 0.9)

	timer.Simple(0.2, function() self.UpdateCrew(self) end)
end

function ENT:OnRemove()
end

function ENT:CreateChildren()
	local vPos = self:GetPos()

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + Vector(75, 0, 18))
		ent:SetAngles(Angle(0, 270, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(40)
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
		ent:SetPos(vPos + Vector(-85, 0, -75))
		ent:SetAngles(Angle(0, 90, 0))
		ent:Spawn()
		ent.VehicleParent = self
		local phys = ent:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(40)
		ent.Enter = PilotEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.TailGunnerSeat = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local wing = ents.Create("vehiclepart")
	if wing:IsValid() then
		wing:SetModel("models/props_combine/combine_barricade_med02a.mdl")
		wing:SetPos(vPos + Vector(-50, -50, 0))
		wing:SetAngles(Angle(-90, -90, 180))
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
		wing2:SetModel("models/props_combine/combine_barricade_med02a.mdl")
		wing2:SetPos(vPos + Vector(-50, 50, 0))
		wing2:SetAngles(Angle(270, 180, 90))
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

	local tail = ents.Create("vehiclepart")
	if tail:IsValid() then
		tail:SetModel("models/Gibs/helicopter_brokenpiece_05_tailfan.mdl")
		tail:SetPos(vPos + Vector(-190, 0, 25))
		tail:SetAngles(Angle(20, 0, 0))
		tail:Spawn()
		tail.VehicleParent = self
		local phys = tail:GetPhysicsObject()
		phys:EnableGravity(false)
		phys:EnableDrag(false)
		phys:SetMass(50)
		constraint.Weld(self, tail, 0, 0, 0, 1)
		constraint.NoCollide(ent, tail, 0, 0)
		self:DeleteOnRemove(tail)
		self.Tail = tail
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

	local vel
	if driver:KeyDown(IN_FORWARD) then
		local oldthrust = thrust
		thrust = math.min(2500, thrust + frametime * 500)
		if thrust ~= oldthrust then
			self:SetThrust(thrust)
		end
	elseif driver:KeyDown(IN_BACK) then
		local oldthrust = thrust
		thrust = math.max(0, thrust + frametime * -700)
		if thrust ~= oldthrust then
			self:SetThrust(thrust)
		end
	end

	phys:EnableGravity(thrust < 900)


	local forward = self:GetForward()
	vel = frametime * thrust * 0.55 * forward + self:GetVelocity() * (1 - frametime * 1.2)

	local vellength = vel:Length()
	if 1150 < vellength then
		vel = vel * (1150 / vellength)
	end

	local aimang = driver:EyeAngles()
	local getangles = self:GetAngles()

	local diffangles = self:WorldToLocalAngles(aimang)

	local newangles = getangles

	if thrust < 900 then -- Hover
		local trace = {mask = MASK_HOVER, filter = self}
		trace.start = self:GetPos()
		trace.endpos = trace.start + Vector(0, 0, -230)
		local tr = util.TraceLine(trace)

		if tr.Hit then
			local diffangles2 = self:WorldToLocalAngles(Angle(0, newangles.yaw, 0))

			tr.HitPos.z = tr.HitPos.z + 150
			vel = vel + (tr.HitPos - trace.start) * 0.21
			newangles:RotateAroundAxis(newangles:Forward(), diffangles2.roll * frametime * 2)
			newangles:RotateAroundAxis(newangles:Right(), diffangles2.pitch * frametime * -1)
			newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 0.9)
			self.IsHoveringOverGround = true
		else
			if driver:KeyDown(IN_MOVELEFT) then
				newangles:RotateAroundAxis(newangles:Forward(), frametime * -70)
			elseif driver:KeyDown(IN_MOVERIGHT) then
				newangles:RotateAroundAxis(newangles:Forward(), frametime * 70)
			end

			newangles:RotateAroundAxis(newangles:Right(), diffangles.pitch * frametime * -0.37)
			newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 0.37)
			self.IsHoveringOverGround = false
		end
	else
		self.IsHoveringOverGround = false
		if driver:KeyDown(IN_MOVELEFT) then
			newangles:RotateAroundAxis(newangles:Forward(), frametime * -70)
		elseif driver:KeyDown(IN_MOVERIGHT) then
			newangles:RotateAroundAxis(newangles:Forward(), frametime * 70)
		end

		newangles:RotateAroundAxis(newangles:Right(), diffangles.pitch * frametime * -0.45)
		newangles:RotateAroundAxis(newangles:Up(), diffangles.yaw * frametime * 0.45)
	end

	self:SetAngles(newangles)
	phys:SetVelocityInstantaneous(vel)

	return SIM_NOTHING
end

function ENT:UpdateCrew()
	if self:IsValid() then
		umsg.Start("RecVD")
			umsg.Entity(self)
			umsg.Entity(self.LastDriver)
			umsg.Entity(self.LastTailGunner)
		umsg.End()
	end
end

local lastattacker = NULL
local lastinflictor = NULL

local function BCb(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent and ent.TakeSpecialDamage then
		local damage = dmginfo:GetDamage()
		if ent.PHealth then
			damage = damage * 0.1
		end
		ent:TakeSpecialDamage(damage, DMGTYPE_PIERCING, lastattacker, lastinflictor)

		return {damage = false}
	end
end

util.PrecacheSound("npc/attack_helicopter/aheli_mine_drop1.wav")
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

	local isMDF = self.MDF and CurTime() <= self.MDF

	local driver = self.PilotSeat:GetDriver()
	if driver:IsValid() then
		self.Destroy = 99999999

		self.LeftWing:SetPhysicsAttacker(driver)
		self.RightWing:SetPhysicsAttacker(driver)
		self.PilotSeat:SetPhysicsAttacker(driver)
		self.TailGunnerSeat:SetPhysicsAttacker(driver)
		self.Tail:SetPhysicsAttacker(driver)
		
		if driver:KeyDown(IN_ATTACK) and self:GetVelocity():Length() >= 500 then
			if not isMDF and self.NextBomb <= CurTime() and 0.49 < self:GetUp().z then
				self.NextBomb = CurTime() + 1.75

				local proj = ents.Create("projectile_vulturebomb")
				if proj:IsValid() then
					if self.Alt then
						proj:SetPos(self.LeftWing:GetPos() + self:GetUp() * -64)
						self.LeftWing:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav")
					else
						proj:SetPos(self.RightWing:GetPos() + self:GetUp() * -64)
						self.RightWing:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav")
					end
					self.Alt = not self.Alt
					proj:SetSkin(self:Team())
					proj:Spawn()
					proj:SetTeamID(driver:Team())
					proj:SetOwner(driver)
					local phys = proj:GetPhysicsObject()
					if phys:IsValid() then
						phys:AddAngleVelocity(VectorRand() * math.Rand(100, 200))
						phys:SetVelocityInstantaneous(self:GetVelocity())
					end
				end
			end
		elseif driver:KeyDown(IN_ATTACK) then
			self:CantFireWarning()
		end
	end

	local gunner = self.TailGunnerSeat:GetDriver()
	if gunner:IsValid() then
		self.Destroy = 99999999

		if gunner:KeyDown(IN_ATTACK) and not isMDF and self.NextShoot <= CurTime() and not self.IsHoveringOverGround then
			self.NextGunnerShoot = CurTime() + 0.09

			lastattacker = gunner
			lastinflictor = self

			local dir = gunner:GetAimVector()
			gunner:FireBullets({Num = 1, Dir = dir, Src = gunner:GetShootPos() + dir * 32, Spread = Vector(0.01, 0.01, 0), Tracer = 1, Force = 4, Damage = 28, Callback = BCb, TracerName = "manatrace"})
			self.TailGunnerSeat:EmitSound("Weapon_SMG1.NPC_Single")
		elseif gunner:KeyDown(IN_ATTACK) and self.IsHoveringOverGround then
			self:CantFireWarning()
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

	self:NextThink(CurTime() + 0.09)
	return true
end

function ENT:PhysicsCollide(data, phys)
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

	if self.NextAllowPhysicsDamage < CurTime() and (not hitent:IsValid() or string.find(hitentclass, "prop_") or string.find(hitentclass, "obelisk") or hitent.ScriptVehicle or hitent.VehicleParent) and not (hitent.ScriptVehicle and hitent:Team() == self:Team() or hitent.VehicleParent and hitent.VehicleParent:Team() == self:Team()) and 200 < data.Speed then
		if self.CreationTollerance then
			self.CreationTollerance = nil
			return
		end

		if 800 < data.Speed then
			local driver = self.PilotSeat:GetDriver()
			self.Attacker = driver
			self.Inflictor = driver
			self.DoDestroy = true
		elseif 300 < data.Speed and self.NextAllowPhysicsDamage <= CurTime() then
			self.NextAllowPhysicsDamage = CurTime() + 0.5
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
		attacker = self.LastPilot
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

	local gunner = self.TailGunnerSeat:GetDriver()
	if gunner:IsValid() then
		gunner:RemoveStatus("forcefield", false, true)
		gunner:TakeSpecialDamage(gunner:Health() + 29, DMGTYPE_FIRE, attacker == driver and gunner or attacker, inflictor)
	end

	ExplosiveDamage(attacker, self, 450, 450, 1, 0.35, 8)

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
			phys:SetMass(200)
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
			phys:SetMass(200)
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

	local ent3 = ents.Create("prop_physics_multiplayer")
	if ent3:IsValid() then
		ent3:SetPos(self.Tail:GetPos())
		ent3:SetAngles(self.Tail:GetAngles())
		ent3:SetModel(self.Tail:GetModel())
		ent3:Spawn()
		local phys = ent3:GetPhysicsObject()
		if phys:IsValid() then
			phys:SetMass(100)
			phys:SetVelocityInstantaneous(self.Tail:GetVelocity() + VectorRand() * 550 + Vector(0, 0, 700))
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
