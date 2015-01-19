AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:VehicleThink()
	if self:GetVelocity():Length() <= self.HoverSpeed or self:IsMDF() then return end

	local driver = self:GetDriver()
	if not driver:IsValid() then return end

	if driver:KeyDown(IN_ATTACK) and self.NextShoot <= CurTime() then
		self.NextShoot = CurTime() + self.PhotonCannonDelay

		local dir = self:GetForward()
		local ent = ents.Create("projectile_photoncannon")
		if ent:IsValid() then
			ent:SetPos(self.LeftStub:GetPos() + dir * 65)
			ent:SetOwner(driver)
			ent:Spawn()
			ent:SetTeamID(driver:GetTeamID())

			ent.Damage = self.PhotonCannonDamage
			ent.Inflictor = self

			ent:Launch(dir)
		end

		ent = ents.Create("projectile_photoncannon")
		if ent:IsValid() then
			ent:SetPos(self.RightStub:GetPos() + dir * 65)
			ent:SetOwner(driver)
			ent:Spawn()
			ent:SetTeamID(driver:GetTeamID())

			ent.Damage = self.PhotonCannonDamage
			ent.Inflictor = self

			ent:Launch(dir)
		end

		self:EmitSound("npc/strider/strider_minigun2.wav")
	end

	if driver:KeyDown(IN_ATTACK2) and self.NextShoot <= CurTime() then
		self.NextShoot = CurTime() + self.HomingMissileDelay

		local forward = self:GetForward()
		local attacker = self:GetDriver()
		local trent = util.TraceHull({start = self:GetPos() + forward * 104, endpos = self:GetPos() + forward * 10240, mask = MASK_SHOT, mins = Vector(-24, -24, -24), maxs = Vector(24, 24, 24)}).Entity
		local ent = NULL
		if trent:IsValid() then
			if string.find(trent:GetClass(), "vehicle_tp") and trent:GetTeamID() ~= attacker:Team() then
				ent = trent
			elseif trent:GetVehicleParent():IsValid() then
				local parent = trent:GetVehicleParent()
				if string.find(parent:GetClass(), "vehicle_tp") and parent:GetTeamID() ~= attacker:Team() then
					ent = parent
				end
			end
		end

		local proj = ents.Create("projectile_ravenmissile")
		if proj:IsValid() then
			self.Alt = not self.Alt
			if self.Alt then
				proj:SetPos(self.LeftStub:GetPos() + self.LeftStub:GetForward() * 65)
				proj:SetAngles(self.LeftStub:GetAngles())
				self.LeftStub:EmitSound("weapons/rpg/rocketfire1.wav")
			else
				proj:SetPos(self.RightStub:GetPos() + self.RightStub:GetForward() * 65)
				proj:SetAngles(self.RightStub:GetAngles())
				self.RightStub:EmitSound("weapons/rpg/rocketfire1.wav")
			end

			proj:SetOwner(driver)
			proj:SetColor(team.GetColor(self:GetTeamID()))
			proj:Spawn()
			proj:SetTeamID(self:GetTeamID())

			if ent:IsValid() then
				proj:SetTarget(ent, driver)
			end

			local phys = proj:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(forward * 2800)
			end
		end
	end
	
	if driver:KeyDown(IN_RELOAD) and self.NextShoot <= CurTime() then
		self.NextShoot = CurTime() + self.AirMineDelay

		local dir = self:GetForward()
		local ent = ents.Create("projectile_ravenmine")
		if ent:IsValid() then
			self.Alt = not self.Alt
			if self.Alt then
				ent:SetPos(self.LeftStub:GetPos() + self.LeftStub:GetForward() * -105)
				self.LeftStub:EmitSound("weapons/rpg/rocketfire1.wav")
			else
				ent:SetPos(self.RightStub:GetPos() + self.RightStub:GetForward() * -105)
				self.RightStub:EmitSound("weapons/rpg/rocketfire1.wav")
			end
			ent:SetOwner(driver)
			ent:Spawn()
			ent:SetTeamID(driver:GetTeamID())
			ent:SetColor(team.GetColor(driver:GetTeamID()))
		end
	end
end

function ENT:TeamSet(teamid)
	if self.LWTrail and self.LWTrail:IsValid() then
		self.LWTrail:Remove()
	end
	if self.RWTrail and self.RWTrail:IsValid() then
		self.RWTrail:Remove()
	end

	self.LWTrail = util.SpriteTrail(self.LeftStub, 0, team.GetColor(teamid), false, 18, 14, 0.75, 0.02, "trails/smoke.vmt")
	self.RWTrail = util.SpriteTrail(self.RightStub, 0, team.GetColor(teamid), false, 18, 14, 0.75, 0.02, "trails/smoke.vmt")
end
