AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Stun(1.75, true, true)
	pPlayer:Channeling(1.75)
	pPlayer:ResetLuaAnimation("VOLCANICBLAST")
end

function ENT:OnRemove()
	local parent = self:GetOwner()
	if parent:IsValid() then
		if not self.SilentRemove and self.DieTime <= CurTime() and parent:Alive() then
			local c = parent:GetColor()
			local ang = parent:EyeAngles()
			ang.pitch = math.min(ang.pitch, 0)

			local ent = ents.Create("projectile_dreadnautbomb")
			if ent:IsValid() then
				ent:SetPos(parent:GetShootPos())
				ent:SetOwner(parent)
				ent:SetTeamID(parent:Team())
				ent:SetColor(Color(c.r, c.g, c.b, 255))
				ent:Spawn()
				local phys = ent:GetPhysicsObject()
				if phys:IsValid() then
					phys:SetVelocityInstantaneous(ang:Forward() * 900)
				end
			end
		else
			parent.Stunned = nil
			parent.ChannelingSpell = nil
			parent:StopLuaAnimation("VOLCANICBLAST")
		end
	end
end

function ENT:Think()
	if self.DieTime <= CurTime() then
		self:Remove()
		return
	end
	
	local owner = self:GetOwner()
	if owner:IsValid() then
		if owner.ManaStunned then
			self.SilentRemove = true
			self:Remove()
			return
		end
	end
end
