ENT.Type = "anim"
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

function ENT:SetCarrier(ent)
	self:SetDTEntity(0, ent)

	if SERVER then
		if ent:IsValid() then
			self.Phys:EnableCollisions(false)
			self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
		else
			self.Phys:EnableCollisions(true)
			self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		end
	end
end

function ENT:GetCarrier()
	return self:GetDTEntity(0)
end

function ENT:AlignToCarrier()
	local carrier = self:GetCarrier()
	if carrier:IsValid() then
		local set = false
		local attachid = carrier:LookupAttachment("anim_attachment_lh")
		if attachid and attachid > 0 then
			local attach = carrier:GetAttachment(attachid)
			if attach then
				self:SetPos(attach.Pos)
				self:SetAngles(attach.Ang)
				set = true
			end
		end

		if not set then
			self:SetPos(carrier:LocalToWorld(carrier:OBBCenter()))
		end
	end
end
function ENT:SetImmunity(time)
	self:SetDTFloat(0, time)
end

function ENT:GetImmunity()
	return self:GetDTFloat(0)
end
