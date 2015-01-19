AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:VehicleThink()
	if self:GetVelocity():Length() <= self.HoverSpeed or self:IsMDF() then return end

	local driver = self:GetDriver()
	if driver:IsValid() and driver:KeyDown(IN_ATTACK) and CurTime() >= self.NextShoot and self:GetUp().z >= self.BombZ and self:GetVelocity():Length() > 500 then
		self.NextShoot = CurTime() + self.BombDelay

		self:EmitSound("npc/attack_helicopter/aheli_mine_drop1.wav")

		self.AlternateBomb = not self.AlternateBomb

		local proj = ents.Create("projectile_vulturebomb")
		if proj:IsValid() then
			proj:SetPos((self.AlternateBomb and self.LeftWing:GetPos() or self.RightWing:GetPos()) + self:GetUp() * -64)
			proj:SetOwner(driver)
			proj:Spawn()
			proj:SetTeamID(driver:GetTeamID())
			proj:SetColor(team.GetColor(driver:GetTeamID()))
			
			local phys = proj:GetPhysicsObject()
			if phys:IsValid() then
				phys:Wake()
				phys:AddAngleVelocity(VectorRand() * math.Rand(100, 200))
				phys:SetVelocityInstantaneous(self:GetVelocity())
			end
		end
	end

	local gunner = self.TailGunnerSeat:GetDriver()
	if gunner:IsValid() and gunner:KeyDown(IN_ATTACK) and CurTime() >= self.NextShoot2 then
		self.NextShoot2 = CurTime() + self.FlakCannonDelay
		
		local pos = gunner:GetShootPos()
		local dir = gunner:GetAimVector()
		local ent = ents.Create("projectile_flakcannon")
		if ent:IsValid() then
			ent:SetPos(pos + dir * 65)
			ent:SetOwner(gunner)
			ent:Spawn()
			ent:SetTeamID(gunner:GetTeamID())

			local phys = ent:GetPhysicsObject()
			if phys:IsValid() then
				phys:SetVelocityInstantaneous(dir * 1700)
			end
		end
	end
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
	self.Destroy = -1
	self:SetTeamID(pl:GetTeamID())
	self.LastDriver = pl
	local gunner = self:GetGunnerSeat():GetDriver()
	if gunner:IsValid() and gunner:GetTeamID() ~= self:GetTeamID() then
		gunner:ExitVehicle()
		self:GetGunnerSeat():SetOwner(NULL)
	end

	self:GetPilotSeat():SetOwner(pl)
end

function ENT:PilotExit(pl)
	self.LastDriver = NULL

	self:GetPilotSeat():SetOwner(NULL)
end

function ENT:GunnerEnter(pl)
	self:GetGunnerSeat():SetOwner(pl)
	local driver = self:GetPilotSeat():GetDriver()
	if not driver:IsValid() then
		self:SetTeamID(pl:GetTeamID())
	end
end

function ENT:GunnerExit(pl)
	self:GetGunnerSeat():SetOwner(NULL)
end

function ENT:TeamSet(teamid)
	if self.LWTrail and self.LWTrail:IsValid() then
		self.LWTrail:Remove()
	end
	if self.RWTrail and self.RWTrail:IsValid() then
		self.RWTrail:Remove()
	end

	self.LWTrail = util.SpriteTrail(self.LeftWing, 0, team.GetColor(teamid), false, 18, 15, 0.75, 0.02, "trails/smoke.vmt")
	self.RWTrail = util.SpriteTrail(self.RightWing, 0, team.GetColor(teamid), false, 18, 15, 0.75, 0.02, "trails/smoke.vmt")
end
