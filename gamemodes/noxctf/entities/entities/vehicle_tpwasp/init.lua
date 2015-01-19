AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:VehicleThink()
	local driver = self:GetDriver()
	if not driver:IsValid() then return end

	local firing = driver:KeyDown(IN_ATTACK) and not self:IsMDF() and self:GetVelocity():Length() > self.HoverSpeed
	if self:GetFiring() ~= firing then
		self:SetFiring(firing)
	end

	if not firing or CurTime() < self.NextShoot then return end
	self.NextShoot = CurTime() + self.PhotonCannonDelay

	local ang = self:GetAngles()
	ang:RotateAroundAxis(ang:Right(), math.Rand(-1, 1))
	ang:RotateAroundAxis(ang:Up(), math.Rand(-1, 1))
	local dir = ang:Forward()

	local ent = ents.Create("projectile_photoncannon")
	if ent:IsValid() then
		ent:SetPos(self:GetPos() + dir * 65)
		ent:SetOwner(driver)
		ent:Spawn()
		ent:SetTeamID(driver:GetTeamID())

		ent.Damage = self.PhotonCannonDamage
		ent.Inflictor = self

		ent:Launch(dir)
	end
end

function ENT:TeamSet(teamid)
	if self.LWTrail and self.LWTrail:IsValid() then
		self.LWTrail:Remove()
	end
	if self.RWTrail and self.RWTrail:IsValid() then
		self.RWTrail:Remove()
	end

	self.LWTrail = util.SpriteTrail(self.LeftWing, 0, team.GetColor(teamid), false, 18, 14, 0.75, 0.02, "trails/smoke.vmt")
	self.RWTrail = util.SpriteTrail(self.RightWing, 0, team.GetColor(teamid), false, 18, 14, 0.75, 0.02, "trails/smoke.vmt")
end
