AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_EXPLODE
	self.Inversion = INVERSION_SETOWNER_REVERSE
	self:PhysicsInitSphere(5)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 30
end

function ENT:Think()
	local ct = CurTime()

	if self.DeathTime <= ct then
		self:Remove()
	elseif 0 < self:WaterLevel() then
		self:Explode()
	elseif self.PhysicsData then
		self:Explode(self.PhysicsData.HitPos, self.PhysicsData.HitNormal)
	else
		local targ
		local near
		local mindist = 513
		local mypos = self:GetPos()
		local myteam = self:GetTeamID()
		for _, target in pairs(ents.FindInSphere(self:GetPos(), 425)) do
			if target:IsPlayer() and target:GetTeamID() ~= myteam and target:Alive() then
				local nearest = (target:NearestPoint(mypos) + target:GetPos() * 0.75) / 1.75
				if nearest:Distance(mypos) < mindist and TrueVisible(nearest, mypos) then
					targ = target
					near = nearest
					self.DeathTime = ct + 30
				end
			end
		end

		if targ then
			local vHeading = (near - mypos):GetNormal()
			local aOldHeading = self:GetVelocity():Angle()

			self:SetAngles(aOldHeading)
			local diffang = self:WorldToLocalAngles(vHeading:Angle())

			local ft = FrameTime() * 1.75
			aOldHeading:RotateAroundAxis(aOldHeading:Up(), diffang.yaw * ft)
			aOldHeading:RotateAroundAxis(aOldHeading:Right(), diffang.pitch * -ft)

			local vNewHeading = aOldHeading:Forward()
			self:GetPhysicsObject():SetVelocityInstantaneous(vNewHeading * 600)
		end

		self:NextThink(ct)
		return true
	end
end

function ENT:PhysicsCollide(data, physobj)
	self.PhysicsData = data
	self:NextThink(CurTime())
end

function ENT:Explode(hitpos, hitnormal)
	if self.Exploded then return end
	self.Exploded = true
	self.DeathTime = 0

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end
	hitpos = hitpos or self:GetPos()

	ExplosiveDamage(owner, hitpos, 72, 72, 1, 0.5, 1, self)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal or Vector(0,0,1))
	util.Effect("fireboltexplosion", effectdata)
end
