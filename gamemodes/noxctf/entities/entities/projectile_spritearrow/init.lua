AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self.DeathTime = CurTime() + 30
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInitSphere(1)
	self:SetCollisionGroup(COLLISION_GROUP_PROJECTILE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0.05)
		phys:Wake()
	end

	self:EmitSound("nox/arrow_flying0"..math.random(1,2)..".ogg")
end

function ENT:Think()
	if self.PhysicsData and not self.Hit then
		self.Hit = true

		local data = self.PhysicsData
		self.PhysicsData = nil

		local ent = data.HitEntity
		if ent:IsValid() then
			local owner = self:GetOwner()
			if not owner:IsValid() then owner = self end

			if ent:IsPlayer() then
				ent:BloodSpray(data.HitPos, math.random(5, 7), data.OurOldVelocity:GetNormal(), 125)
			end
			ent:TakeSpecialDamage(self.Damage, DMGTYPE_PIERCING, owner, self)
			ent:EmitSound("weapons/crossbow/hitbod"..math.random(1,2)..".wav")
			self.DeathTime = 0
		else
			self:EmitSound("physics/metal/sawblade_stick"..math.random(1, 3)..".wav")
			self.DeathTime = CurTime() + 5
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				--print("Distance: "..tostring(self:GetPos():Distance(self.Owner:GetPos())))
				--print("Velocity: "..tostring(phys:GetVelocity()))
				phys:EnableMotion(false)
				phys:EnableCollisions(false)
			end
		end
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end

	if not self.Hit then
		local mypos = self:GetPos()
		local myteam = self:GetTeamID()
		local owner = self:GetOwner()
		for _, ent in pairs(ents.FindInSphere(mypos, 512)) do
			if ent:IsPlayer() and ent:Alive() and ent:Team() ~= myteam then
				if ent:IsVisibleTarget(owner) and TrueVisible(mypos, ent:NearestPoint(mypos)) then
					local nearest = ent:LocalToWorld(ent:OBBCenter())
					local vHeading = (nearest - mypos):GetNormal()
					local aOldHeading = self:GetVelocity():Angle()
					local vel = self:GetVelocity():Length()

					self:SetAngles(aOldHeading)
					local diffang = self:WorldToLocalAngles(vHeading:Angle())

					local ft = FrameTime() * math.max(2.5, 60 - nearest:Distance(mypos))
					aOldHeading:RotateAroundAxis(aOldHeading:Up(), diffang.yaw * ft)
					aOldHeading:RotateAroundAxis(aOldHeading:Right(), diffang.pitch * -ft)

					local vNewHeading = aOldHeading:Forward()
					local phys = self:GetPhysicsObject()
					phys:SetVelocityInstantaneous(vNewHeading * 1100)

					if vNewHeading:Distance(vHeading) < 1.25 then
						phys:EnableGravity(false)
						phys:SetVelocityInstantaneous(vNewHeading * 1100)
						self.DeathTime = CurTime() + 7
						break
					else
						phys:EnableGravity(true)
					end
				end
			end
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
