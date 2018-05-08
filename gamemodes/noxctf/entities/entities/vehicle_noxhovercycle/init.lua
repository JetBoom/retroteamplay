AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel(self.Model)
	self:SetPos(self:GetPos() + self.CreationOffset)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)

	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("metal")
		phys:SetMass(100)
		phys:EnableMotion(true)
		phys:Wake()
	end

	self:StartMotionController()

	self:SetVHealth(self.MaxHealth)

	self.NextShoot = 0
	self.Destroy = CurTime() + 30
	self.LastDriver = NULL

	self.LastAttacked = 0
	self.Attacker = NULL
	self.Inflictor = NULL
end

function ENT:Exit(pl, veh)
	self.LastDriver = NULL
	pl:SetVelocity(self:GetVelocity() * 0.9)
	self:SetSkin(0)
end

function ENT:Enter(pl, veh, role)
	self:SetTeam(pl:Team())
	self.Destroy = 99999999
	self:GetPhysicsObject():EnableGravity(false)
	self.LastDriver = pl
	self:SetSkin(1)
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
		phys:SetMass(5)
		ent.Enter = PilotEnter
		constraint.Weld(self, ent, 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.PilotSeat = ent
		ent:SetVehicleParent(self)
		ent:SetMaterial("models/debug/debugwhite")
	end

	local wing = ents.Create("vehiclepart")
	if wing:IsValid() then
		wing:SetModel("models/props_combine/combine_fence01b.mdl")
		wing:SetPos(vPos + Vector(16, -16, 0))
		wing:SetAngles(Angle(90, 0, 180))
		wing:Spawn()
		wing.VehicleParent = self
		local phys = wing:GetPhysicsObject()
		phys:EnableGravity(false)
		constraint.Weld(self, wing, 0, 0, 0, 1)
		self:DeleteOnRemove(wing)
		self.RightWing = wing
		timer.Simple(0, function() util.SpriteTrail(wing, 0, color_white, false, 32, 8, 0.65, 0.05, "trails/plasma.vmt") end)
	end

	local wing2 = ents.Create("vehiclepart")
	if wing2:IsValid() then
		wing2:SetModel("models/props_combine/combine_fence01a.mdl")
		wing2:SetPos(vPos + Vector(16, 16, 0))
		wing2:SetAngles(Angle(90, 0, 180))
		wing2:Spawn()
		wing2.VehicleParent = self
		local phys = wing2:GetPhysicsObject()
		phys:EnableGravity(false)
		constraint.Weld(self, wing2, 0, 0, 0, 1)
		self:DeleteOnRemove(wing2)
		self.LeftWing = wing2
		timer.Simple(0, function() util.SpriteTrail(wing2, 0, color_white, false, 32, 8, 0.65, 0.05, "trails/plasma.vmt") end)
	end

	constraint.Weld(wing2, wing, 0, 0, 0, 1)

	local gun = ents.Create("prop_dynamic_override")
	if gun:IsValid() then
		gun:SetModel("models/items/ar2_grenade.mdl")
		gun:SetPos(vPos + Vector(70, 0, 0))
		gun:SetAngles(Angle(0, 0, 360))
		gun:Spawn()
		gun.VehicleParent = self
		gun:SetParent(self)
		self.Gun = gun
		self:SetNetworkedEntity("gun", gun)
	end
end

MASK_HOVER = bit.bor(CONTENTS_OPAQUE, CONTENTS_GRATE, CONTENTS_HITBOX, CONTENTS_DEBRIS, CONTENTS_SOLID, CONTENTS_WATER, CONTENTS_SLIME, CONTENTS_WINDOW, CONTENTS_LADDER, CONTENTS_PLAYERCLIP, CONTENTS_MOVEABLE, CONTENTS_DETAIL, CONTENTS_TRANSLUCENT)

function ENT:PhysicsSimulate(phys, frametime)
	phys:Wake()

	local driver = self.PilotSeat:GetDriver()

	if not driver:IsValid() then
		phys:EnableGravity(true)
		phys:SetAngleDragCoefficient(1)
		return SIM_NOTHING
	end

	phys:SetAngleDragCoefficient(1000000)

	local vel = self:GetVelocity() * (1 - frametime)

	if driver:KeyDown(IN_FORWARD) then
		local forward = self:GetForward()
		forward.z = 0
		forward = forward:GetNormal()
		vel = vel + frametime * 1500 * forward
		local vellength = vel:Length()
		if vellength > 1000 then
			vel = vel * (1000 / vellength)
		end
	elseif driver:KeyDown(IN_BACK) then
		local forward = self:GetForward()
		forward.z = 0
		forward = forward:GetNormal()
		vel = vel + frametime * -1500 * forward
		local vellength = vel:Length()
		if vellength > 1000 then
			vel = vel * (1000 / vellength)
		end
	end

	local desiredroll = 0
	if driver:KeyDown(IN_MOVELEFT) then
		desiredroll = 20
		local forward = self:GetRight()
		forward.z = 0
		forward = forward:GetNormal()
		vel = vel + frametime * -1500 * forward
		local vellength = vel:Length()
		if vellength > 1000 then
			vel = vel * (1000 / vellength)
		end
	elseif driver:KeyDown(IN_MOVERIGHT) then
		desiredroll = -20
		local forward = self:GetRight()
		forward.z = 0
		forward = forward:GetNormal()
		vel = vel + frametime * 1500 * forward
		local vellength = vel:Length()
		if vellength > 1000 then
			vel = vel * (1000 / vellength)
		end
	end

	local trace = {}
	trace.start = self:GetPos()
	trace.endpos = trace.start + Vector(0, 0, -128)
	trace.mask = MASK_HOVER
	trace.filter = self
	local tr = util.TraceLine(trace)

	if tr.Hit then
		tr.HitPos.z = tr.HitPos.z + 102
	end

	vel = vel + (tr.HitPos - trace.start) * 0.35
	vel.z = math.max(vel.z, -400)

	local aimang = driver:EyeAngles()
	local getangles = self:GetAngles()

	local diffangles = self:WorldToLocalAngles(aimang)
	local diffangles2 = self:WorldToLocalAngles(Angle(0, getangles.yaw, 0))

	getangles:RotateAroundAxis(getangles:Up(), diffangles.yaw * frametime * 1.75)
	getangles:RotateAroundAxis(getangles:Forward(), diffangles2.roll * frametime * 3)
	getangles:RotateAroundAxis(getangles:Right(), diffangles2.pitch * frametime * -3)

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

	local driver = self.PilotSeat:GetDriver()

	if driver:IsValid() and not self:IsMDF() then
		self.Destroy = 99999999

		self.LeftWing:SetPhysicsAttacker(driver)
		self.RightWing:SetPhysicsAttacker(driver)
		self.PilotSeat:SetPhysicsAttacker(driver)

		if driver:KeyDown(IN_ATTACK) and self.NextShoot <= CurTime() then
			self.NextShoot = CurTime() + 1.25
			self:NextThink(self.NextShoot)

			local proj = ents.Create("projectile_plasmabolt")
			if proj:IsValid() then
				proj:SetPos(self.Gun:GetPos() + self:GetForward() * 64)
				proj:SetTeamID(driver:Team())
				local c = team.GetColor(proj:GetTeamID())
				proj:SetColor(Color(c.r, c.g, c.b, 127))
				proj:Spawn()
				proj:SetOwner(driver)
				local phys = proj:GetPhysicsObject()
				if phys:IsValid() then
					local dir = self.Gun:GetForward()
					dir.z = math.Clamp(driver:GetAimVector().z, dir.z - 0.25, dir.z + 0.25)
					phys:SetVelocityInstantaneous(dir:GetNormal() * math.max(self:GetVelocity():Length() * 1.2, 775))
				end
			end
		end
	end

	if CurTime() > self.Destroy then
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
	end

	ExplosiveDamage(attacker, self, 300, 300, 1, 0.5, 5)

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
			phys:SetVelocityInstantaneous(self.LeftWing:GetVelocity() + VectorRand() * 850 + Vector(0, 0, 800))
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
		ent3:SetPos(self.RightWing:GetPos())
		ent3:SetAngles(self.RightWing:GetAngles())
		ent3:SetModel(self.RightWing:GetModel())
		ent3:Spawn()
		ent3:SetLocalVelocity(self.RightWing:GetVelocity() + VectorRand() * 850 + Vector(0, 0, 700))
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
end

ENT.ProcessDamage = VEHICLEGENERICPROCESSDAMAGE
