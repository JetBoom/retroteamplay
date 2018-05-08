AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	self.AmmoType = self.AmmoType or "NONE"
	self:Fire("attack", "", 0.015)
	self.AntiPulseSpam = 0
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
		ent:SetModel(turretconnecting:GetTurretModel(self))
		ent:SetPos(self:GetPos() + self:GetUp() * 55)
		ent:SetOwner(self)
		ent:SetParent(self)
		local c = team.GetColor(self:GetTeamID())
		ent:SetColor(Color(c.r, c.g, c.b, 255))
		ent:SetSkin(turretconnecting.SkinType)
		ent:Spawn()
		self.Barrel = ent
		turretconnecting:BarrelChanged(self, ent)
		if activator then
			activator:PrintMessage(HUD_PRINTCENTER, "Turret barrel changed!")
			activator.TurretConnecting = nil
		end

		GAMEMODE:RemoveProp(NULL, turretconnecting)
	elseif activator then
		activator:PrintMessage(HUD_PRINTCENTER, "Failed to attach barrel (engine error).")
	end
end

function ENT:Use(activator, caller)
	if self.Destroyed then return end
	if not activator:IsPlayer() then return end

	if activator:Team() == self:GetTeamID() then
		local turretconnecting = activator.TurretConnecting
		if turretconnecting and turretconnecting:IsValid() then
			self:Attach(turretconnecting, activator)
		end
	end
end

function ENT:Attack_Slow()
	self:Fire("attack", "", 2.5)

	if not self.Destroyed then
		local mypos = self:GetPos() + self:GetUp() * 64

		local attacked
		local myteam = self:GetTeamID()
		for _, ent in pairs(ents.FindInSphere(mypos + self:GetForward() * 250, 250)) do
			if ent:IsPlayer() and ent:Alive() and ent:Team() ~= myteam and TrueVisible(ent:NearestPoint(mypos), mypos) and ent:IsVisibleTarget(self) then
				if GAMEMODE:DrainPower(self, 20) then
					local proj = ents.Create("projectile_slow")
					if proj:IsValid() then
						proj:SetPos(mypos)
						proj.DontCount = true
						proj:Spawn()
						proj:SetTeamID(myteam)
						for _, pl in pairs(player.GetAll()) do
							if pl:SteamID() == self.Owner and pl:Team() == myteam then
								proj:SetOwner(pl)
								break
							end
						end
						local phys = proj:GetPhysicsObject()
						if phys:IsValid() then
							local dir
							if ent:InVehicle() then
								dir = (ent:LocalToWorld(ent:OBBCenter()) + ent:GetVehicle():GetVelocity() * 0.428 - mypos):GetNormal()
							else
								dir = (ent:LocalToWorld(ent:OBBCenter()) + ent:GetVelocity() * 0.428 - mypos):GetNormal()
							end
							phys:SetVelocityInstantaneous(dir * 900)
						end
					end
				else
					self:EmitSound("npc/turret_floor/die.wav")
				end

				umsg.Start("recturrettarget")
					umsg.Entity(ent)
					umsg.Short(self:EntIndex())
				umsg.End()

				break
			end
		end
	end
end

function ENT:Attack_Plasma()
	self:Fire("attack", "", 2.5)

	if not self.Destroyed then
		local mypos = self:GetPos() + self:GetUp() * 64

		local attacked
		local myteam = self:GetTeamID()
		for _, ent in pairs(ents.FindInSphere(mypos + self:GetForward() * 400, 400)) do
			if ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= myteam and TrueVisible(ent:NearestPoint(mypos), mypos) and ent:IsVisibleTarget(self) then
				if GAMEMODE:DrainPower(self, 20) then
					local proj = ents.Create("projectile_plasmabolt")
					if proj:IsValid() then
						proj:SetPos(mypos)
						local c = team.GetColor(self:GetTeamID())
						proj:SetColor(Color(c.r, c.g, c.b, 127))
						proj:Spawn()
						proj:SetTeamID(myteam)
						for _, pl in pairs(player.GetAll()) do
							if pl:SteamID() == self.Owner and pl:Team() == myteam then
								proj:SetOwner(pl)
								break
							end
						end
						local phys = proj:GetPhysicsObject()
						if phys:IsValid() then
							if ent:InVehicle() then
								phys:ApplyForceCenter(ent:GetVehicle():GetVelocity() * 4.15 + (ent:GetPos() + Vector(0,0,-16) - mypos):GetNormal() * 4000)
							else
								phys:ApplyForceCenter(ent:GetVelocity() * 4.15 + (ent:GetPos() + Vector(0,0,-16) - mypos):GetNormal() * 4000)
							end
						end
					end
				else
					self:EmitSound("npc/turret_floor/die.wav")
				end

				umsg.Start("recturrettarget")
					umsg.Entity(ent)
					umsg.Short(self:EntIndex())
				umsg.End()

				break
			end
		end
	end
end

util.PrecacheSound("nox/missilesofmagic.ogg")
util.PrecacheSound("npc/turret_floor/die.wav")
ENT["Attack_Magic Missiles"] = function(self)
	self:Fire("attack", "", 1.5)

	if not self.Destroyed then
		local mypos = self:GetPos() + self:GetUp() * 64

		local attacked
		local myteam = self:GetTeamID()
		for _, ent in pairs(ents.FindInSphere(mypos + self:GetForward() * 300, 300)) do
			if ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= myteam and TrueVisible(ent:NearestPoint(mypos), mypos) and ent:IsVisibleTarget(self) then
				if GAMEMODE:DrainPower(self, 20) then
					self:EmitSound("nox/missilesofmagic.ogg")

					for i=1, 3 do
						local proj = ents.Create("projectile_magicmissile")
						if proj:IsValid() then
							proj:SetPos(mypos)
							proj.DontCount = true
							proj:Spawn()
							proj:SetTeamID(myteam)
							for _, pl in pairs(player.GetAll()) do
								if pl:SteamID() == self.Owner and pl:Team() == myteam then
									proj:SetOwner(pl)
									break
								end
							end
							local phys = proj:GetPhysicsObject()
							if phys:IsValid() then
								phys:ApplyForceCenter((ent:GetPos() + Vector(math.Rand(-180, 180), math.Rand(-180, 180), 0) - mypos):GetNormal() * 500)
							end
						end
					end
				else
					self:EmitSound("npc/turret_floor/die.wav")
				end

				umsg.Start("recturrettarget")
					umsg.Entity(ent)
					umsg.Short(self:EntIndex())
				umsg.End()

				break
			end
		end
	end
end

ENT["Attack_Pulse Cannon"] = function(self)
	if self.Destroyed then
		self:Fire("attack", "", 0.5)
		return
	end

	local mypos = self:GetPos() + self:GetUp() * 64 + self:GetForward() * 4

	local attacked
	local myteam = self:GetTeamID()
	for _, ent in pairs(ents.FindInSphere(mypos + self:GetForward() * 650, 650)) do
		if ent:IsPlayer() and ent:Alive() and ent:GetTeamID() ~= myteam and TrueVisible(ent:NearestPoint(mypos), mypos) and ent:IsVisibleTarget(self) then
			if GAMEMODE:DrainPower(self, 1) then
				self:Fire("attack", "", 0.2)
				self:EmitSound("Weapon_AR2.Single")

				local proj = ents.Create("projectile_pulsecannon")
				if proj:IsValid() then
					proj:SetPos(mypos)
					proj.DontCount = true
					local c = self:GetColor()
					proj:SetColor(Color(c.r, c.g, c.b, 255))
					proj:Spawn()
					proj:SetTeamID(myteam)
					for _, pl in pairs(player.GetAll()) do
						if pl:SteamID() == self.Owner and pl:Team() == myteam then
							proj:SetOwner(pl)
							break
						end
					end
					local phys = proj:GetPhysicsObject()
					if phys:IsValid() then
						local dir
						if ent:InVehicle() then
							dir = (ent:LocalToWorld(ent:OBBCenter()) + ent:GetVehicle():GetVelocity() * 0.35 - mypos):GetNormal()
						else
							dir = (ent:LocalToWorld(ent:OBBCenter()) + ent:GetVelocity() * 0.35 - mypos):GetNormal()
						end
						dir:Rotate(Angle(math.Rand(-2, 2), math.Rand(-2, 2), 0))
						phys:SetVelocityInstantaneous(dir * 1100)
					end
				end
			else
				self:Fire("attack", "", 0.5)
				self:EmitSound("npc/turret_floor/die.wav")
			end

			if self.AntiPulseSpam <= CurTime() then
				self.AntiPulseSpam = CurTime() + 0.4
				umsg.Start("recturrettarget")
					umsg.Entity(ent)
					umsg.Short(self:EntIndex())
				umsg.End()
			end

			return
		end
	end

	self:Fire("attack", "", 0.5)
end

function ENT:Attack_NONE()
	self:Fire("attack", "", 1)
end

function ENT:AcceptInput(name, activator, caller)
	if name == "attack" then
		self["Attack_"..self.AmmoType](self)

		return true
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth..","..tostring(self.AmmoType)
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 20
ENT.OffenseBonus = 2
ENT.FragsBonus = 2
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
