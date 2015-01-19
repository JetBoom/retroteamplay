AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)

	self.DesiredCannonYaw = 0
	self.DesiredCannonPitch = 0

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableMotion(false)
		phys:Wake()
	end

	self.NextShoot = 0

	self.AmmoType = self.AmmoType or "NONE"

	self.LastAttacked = 0
	self.LastDriver = NULL

	self.Attacker = NULL
	self.Inflictor = NULL
end

function ENT:Attach(turretconnecting, activator)
	if self.AmmoType == turretconnecting.AmmoType then
		if activator then
			activator:PrintMessage(HUD_PRINTCENTER, "Turret already loaded with that type of barrel.")
			activator:SendLua([[surface.PlaySound("buttons/button16.wav")]])
		end

		return
	end

	if 200 < turretconnecting:GetPos():Distance(self:GetPos()) then
		if activator then
			activator:PrintMessage(HUD_PRINTCENTER, "Barrel is too far from the turret to load.")
			activator:SendLua([[surface.PlaySound("buttons/button16.wav")]])
		end

		return
	end

	if self.Barrel and self.Barrel:IsValid() then
		self.Barrel:Remove()
		self.Barrel = nil
	end

	local ent = ents.Create("turretbarrel")
	if ent:IsValid() then
		self.AmmoType = turretconnecting.AmmoType
		ent:SetModel("models/props_c17/oildrum001.mdl")
		ent:SetPos(turretconnecting:GetTurretPos(self, self.PilotSeat))
		ent:SetAngles(turretconnecting:GetTurretAngles(self, self.PilotSeat))
		ent:SetOwner(self)
		ent:SetParent(self.PilotSeat)
		local col = team.GetColor(self:GetTeamID())
		ent:SetColor(Color(col.r, col.g, col.b, 255))
		ent:SetSkin(turretconnecting.SkinType)
		ent:Spawn()
		self.Barrel = ent
		turretconnecting:BarrelChanged(self, ent)
		if activator then
			activator:PrintMessage(HUD_PRINTCENTER, "Turret barrel changed!")
			activator.mTurretConnecting = nil
		end

		GAMEMODE:RemoveProp(NULL, turretconnecting)
	end

	self.Cannon:SetModel(turretconnecting:GetTurretModel(self))
end

function ENT:AcceptInput(name, activator, caller, args)
	if name == "created" then
		self:CreateChildren()
	end
end

function ENT:OnRemove()
end

function ENT:Exit(pl, veh, role)
	self.LastDriver = NULL
end

function ENT:Enter(pl, veh, role)
	self.LastDriver = pl
end

function ENT:CreateChildren()
	if self.CreatedChildren then return end
	self.CreatedChildren = true

	local vPos = self:GetPos()
	local vForward = self:GetForward()
	local vRight = self:GetRight()
	local vUp = self:GetUp()

	local aAngles = self:GetAngles()

	local ent = ents.Create("prop_vehicle_prisoner_pod")
	if ent:IsValid() then
		ent:SetKeyValue("model", "models/props_phx/carseat2.mdl")
		ent:SetKeyValue("solid", "6")
		ent:SetKeyValue("vehiclescript", "scripts/vehicles/prisoner_pod.txt")
		ent:SetPos(vPos + vUp * 62)
		ent:SetAngles(aAngles)
		ent:SetMaterial("models/debug/debugwhite")
		local col = team.GetColor(self:GetTeamID())
		ent:SetColor(Color(col.r, col.g, col.b, 255))
		ent:Spawn()
		ent:SetVehicleParent(self)
		constraint.Axis(ent, self, 0, 0, Vector(0, 0, -16), Vector(0, 0, 21), 0, 0, 0, 1)
		self:DeleteOnRemove(ent)
		self.PilotSeat = ent
		ent:SetDTEntity(0, self)
		self:SetVehicleParent(ent)
		ent:SetTeamID(self:GetTeamID())
		ent.IsTurret = true
	end

	local Seat = ent

	local ent = ents.Create("mturretcannon")
	if ent:IsValid() then
		ent:SetPos(vPos + vUp * 120)
		local tang = aAngles
		tang:RotateAroundAxis(tang:Forward(), -90)
		ent:SetAngles(tang)
		local col = team.GetColor(self:GetTeamID())
		ent:SetColor(Color(col.r, col.g, col.b, 255))
		ent:SetOwner(Seat)
		ent:SetParent(Seat)
		ent:Spawn()
		ent:SetVehicleParent(self)
		self.Cannon = ent
		self:DeleteOnRemove(ent)
		ent:SetDTEntity(0, self)
		self:SetDTEntity(1, ent)
	end
end

function ENT:Use(activator, caller)
	if self.Destroyed then return end
	if not activator:IsPlayer() then return end

	if activator:GetTeamID() == self:GetTeamID() then
		local turretconnecting = activator.mTurretConnecting
		if turretconnecting and turretconnecting:IsValid() then
			self:Attach(turretconnecting, activator)
		end
	end
end

function ENT:Think()
	if not self.CreatedChildren then
		if not self.Destroyed then
			self:CreateChildren()
		end

		return
	end

	local driver = self.PilotSeat:GetDriver()

	if driver:IsValid() then
		if driver:KeyDown(IN_ATTACK) and self.NextShoot < CurTime() then
			if self["Attack_"..self.AmmoType] then
				self["Attack_"..self.AmmoType](self, driver, self.Cannon)
			else
				self.NextShoot = CurTime() + 0.5
				driver:PrintMessage(HUD_PRINTCENTER, "No mountable-turret barrel has been loaded!")
			end
		end

		if driver:KeyDown(IN_MOVELEFT) then
			local ang = self.PilotSeat:GetAngles()
			ang:RotateAroundAxis(ang:Up(), FrameTime() * 120)
			self.PilotSeat:SetAngles(ang)
		elseif driver:KeyDown(IN_MOVERIGHT) then
			local ang = self.PilotSeat:GetAngles()
			ang:RotateAroundAxis(ang:Up(), FrameTime() * -120)
			self.PilotSeat:SetAngles(ang)
		end

		self.PilotSeat:GetPhysicsObject():SetAngleDragCoefficient(1000000)

		self:NextThink(CurTime())
		return true
	else
		self.PilotSeat:GetPhysicsObject():SetAngleDragCoefficient(1)
	end
end

function ENT:Attack_Mortar(driver, cannon)
	self.NextShoot = CurTime() + 1.25

	if GAMEMODE:DrainPower(self, 5) then
		local ent = ents.Create("projectile_dropshipcannon")
		if ent:IsValid() then
			local aimvec = driver:GetAimVector()
			ent:SetPos(driver:GetShootPos() + aimvec * 32)
			ent:SetOwner(driver)
			ent:SetSkin(self:GetTeamID())
			ent:Spawn()
			ent.DisplayClass = "prop_mturretbarrel_mortar"
			ent:SetTeamID(driver:GetTeamID())
			cannon:EmitSound("vehicles/Airboat/pontoon_impact_hard1.wav", 80, math.Rand(95, 105))
			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(aimvec * 1400)
			end
		end
	else
		driver:PrintMessage(HUD_PRINTCENTER, "Insufficient Mana. Needs 5 Mana from a nearby capacitor to fire.")
	end
end

function ENT:Attack_Plasma(driver, cannon)
	self.NextShoot = CurTime() + 1.25

	if GAMEMODE:DrainPower(self, 5) then
		local proj = ents.Create("projectile_plasmabolt")
		if proj:IsValid() then
			proj:SetRenderMode(RENDERMODE_TRANSALPHA)
			proj:SetPos(cannon:GetPos() + driver:GetAimVector() * 48)
			local col = team.GetColor(self:GetTeamID())
			proj:SetColor(Color(col.r, col.g, col.b, 127))
			proj:Spawn()
			proj.DisplayClass = "projectile_plasma_mountablecannon"
			proj:SetTeamID(driver:GetTeamID())
			proj:SetOwner(driver)
			proj:GetPhysicsObject():ApplyForceCenter(driver:GetAimVector() * 4000)
		end
	else
		driver:PrintMessage(HUD_PRINTCENTER, "Insufficient Mana. Needs 5 Mana from a nearby capacitor to fire.")
	end
end

function ENT:Info(pl)
	if pl:GetTeamID() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth..","..self.AmmoType
	end

	return "deny"
end

function ENT:DestructionEffect(damage, attacker, inflictor)
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("firebombexplosion", effectdata, true, true)
end

ENT.MoneyBonus = 30
ENT.OffenseBonus = 3
ENT.FragsBonus = 3
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE

local lockedonentity = NULL
local function LockOnCB(attacker, tr, dmginfo)
	local ent = tr.Entity
	if ent:IsValid() and string.find(ent:GetClass(), "vehicle_nox") and ent:GetTeamID() ~= attacker:GetTeamID() then
		lockedonentity = ent
	elseif ent:GetVehicleParent():IsValid() and ent:GetVehicleParent():GetTeamID() ~= attacker:GetTeamID() then
		lockedonentity = ent:GetVehicleParent()
	else
		lockedonentity = NULL
	end

	return {effects = false, damage = false}
end

function ENT:Attack_Lockon(driver, cannon)
	local fwd = driver:GetAimVector()
	local startpos = cannon:GetPos() + fwd * 48
	self:FireBullets({Num = 1, Dir = fwd, Src = startpos + fwd * 16, Spread = Vector(0, 0, 0), Tracer = 0, Force = 0, Damage = 0, HullSize = 48, Callback = LockOnCB})

	local ent = lockedonentity or NULL

	if not ent:IsValid() then
		driver:PrintMessage(HUD_PRINTCENTER, "No vehicular target in reticle!")
		self.NextShoot = CurTime() + 0.25
		return
	end

	self.NextShoot = CurTime() + 4

	if GAMEMODE:DrainPower(self, 15) then
		local proj = ents.Create("projectile_ravenmissile")
		if proj:IsValid() then
			cannon:EmitSound("weapons/rpg/rocketfire1.wav")
			local col = team.GetColor(driver:GetTeamID())
			proj:SetColor(Color(col.r, col.g, col.b, 255))
			proj:SetPos(startpos)
			proj:SetAngles(fwd:Angle())
			proj:Spawn()
			proj.DisplayClass = "prop_mturretbarrel_lockons"
			proj:SetTeamID(driver:GetTeamID())
			proj.Target = ent

			driver:SendLua("surface.PlaySound(\"buttons/button3.wav\")")

			for _, veh in pairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
				if veh:GetDTEntity(0) == ent then
					local enemydriver = veh:GetDriver()
					if enemydriver:IsPlayer() then enemydriver:SendLua("RLO()") end
				end
			end

			proj:SetOwner(driver)
			local phys = proj:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(fwd * 2800)
			end
		end
	else
		driver:PrintMessage(HUD_PRINTCENTER, "Insufficient Mana. Needs 15 Mana from a nearby capacitor to fire.")
	end
end
