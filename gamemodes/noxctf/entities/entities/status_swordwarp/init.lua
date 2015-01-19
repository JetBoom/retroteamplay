AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	self:SetModel(self:GetOwner():GetModel()) 
end

function ENT:StatusOnRemove(owner)
	if owner:IsValid() then
		local vel = owner:GetVelocity() * 0.3
		owner:SetLocalVelocity(vel)
	end
end

function ENT:StatusThink(owner)
	local ct = CurTime()
	local _filter = {}
	table.insert(_filter,self)
	table.Add(_filter, ents.FindByClass("projectile_swordthrow"))
	for _, p in pairs(player.GetAll()) do
		if p:Team() == owner:Team() then
			table.insert(_filter, p)
		end
	end

	for _, ent in pairs(ents.FindByClass("projectile_swordthrow")) do
		if ent:GetOwner() == owner then
			if not self.StopWarping then
				local midpos = owner:LocalToWorld(owner:OBBCenter())
				local tr = util.TraceEntityHull({start=midpos, endpos=midpos + (owner:GetPos() - ent:GetPos()):GetNormal() * -16, filter=_filter}, owner)
				local hitent = tr.Entity
				if tr.Hit then
					self:EmitSound("physics/concrete/boulder_impact_hard"..math.random(1,4)..".wav", 80, math.Rand(83, 87))
					self.StopWarping = true
					self:Remove()
				end
			end
			owner:SetGroundEntity(NULL)
			owner:SetLocalVelocity((owner:GetPos() - ent:GetPos()):GetNormal() * -1400)
			if owner:GetPos():Distance(ent:GetPos()) < 120 then
				ent:Remove()
				self:Remove()
			end
		end
	end

end

function ENT:StatusShouldRemove(owner)
	return owner:IsAnchored() or owner:IsCarrying()
end