AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:SetGravity(self.GravityMultiplier)
	pPlayer:SetVelocity(Vector(0, 0, self.JumpVelocity))

	self:SetDelta(0)
	self:SetEffectPos(Vector())

	hook.Add("GetFallDamage", self, self.GetFallDamage)
end

function ENT:StatusThink(owner)
	local pos = owner:GetPos()
	local tr = util.TraceHull({start = pos, endpos = pos - owner:GetUp() * 30, filter = owner, mins = Vector(-10, -10, -30), maxs = Vector(10, 10, 0)})
	if tr.Entity:IsValid() and tr.Entity:GetTeamID() ~= owner:GetTeamID() then
		tr.Entity:TakeSpecialDamage(math.Round(self.Damage * self:GetDelta() * self.TouchMultiplier), self.DamageType, owner, self)
		print(math.Round(self.Damage * self:GetDelta() * self.TouchMultiplier))
		
		if tr.Entity:IsPlayer() and tr.Entity:Alive() then
			tr.Entity:GiveStatus(self.Debuff, self.DebuffDuration * self:GetDelta() * self.TouchMultiplier)
		end

		self.Touched = true
		self:Remove()
		return
	end

	local _filter = {}
	table.insert(_filter, owner)
	table.Add(_filter, ents.FindByClass("projectile_harpoon"))
	local pos = owner:GetPos() + Vector(0, 0, owner:OBBMaxs().z)
	local tr = util.TraceHull({start = pos, endpos = pos + owner:GetUp() * 30, filter = _filter, mins = Vector(-10, -10, -30), maxs = Vector(10, 10, 0), mask = MASK_PLAYERSOLID})
	if tr.Hit then
		owner:GiveStatus("stun", self.SelfStunDuration)

		self.Touched = true
		self:Remove()
		return
	end

	self:SetDelta(math.abs(owner:GetVelocity().z/self.JumpVelocity))
	self:SetEffectPos(owner:GetPos())

	self:NextThink(CurTime())
	return true
end


function ENT:StatusShouldRemove(owner)
	return owner:OnGround() or owner:IsAnchored() or owner:IsCarrying() or owner:WaterLevel() > 0
end

function ENT:StatusOnRemove(owner)
	if not self.Touched then
		local delta = self:GetDelta()
		local pos = owner:GetPos()
		local rad = math.Clamp(self.DamageRadius * delta, 0, self.DamageRadius * 2)

		util.ScreenShake(pos, 15, 5, 0.75, rad)
		for _, ent in pairs(ents.FindInSphere(pos, rad)) do
			if ent:IsValid() and ent:GetTeamID() ~= owner:GetTeamID() and TrueVisible(pos, ent:NearestPoint(pos)) then
			ent:TakeSpecialDamage(math.Round(self.Damage * delta), self.DamageType, owner, self)

				if ent:IsPlayer() and ent:Alive() then
					local dir = ent:GetPos() - owner:GetPos()
					dir.z = 0
					dir = dir:GetNormal() * self.XYOffset * delta
					dir.z = self.ZOffset * delta
					
					ent:GiveStatus(self.Debuff, self.DebuffDuration * delta)
					ent:SetGroundEntity(NULL)
					ent:SetVelocity(dir)
				end
			end
		end
	end

	owner:SetGravity(1)
	owner:SetLocalVelocity(Vector(0,0,0))
end

