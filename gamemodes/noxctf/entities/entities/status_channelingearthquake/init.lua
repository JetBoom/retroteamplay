AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	self.NextQuake = CurTime() + self.QuakeInterval
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Stun(self:GetDieTime() - CurTime(), true, true)
end

function ENT:StatusShouldRemove(owner)
	return not owner:OnGround() or owner:GetStatus("manastun")
end

function ENT:StatusThink(owner)
	if CurTime() >= self.NextQuake then
		self.NextQuake = CurTime() + self.QuakeInterval
		
		local pos = owner:GetPos()
		owner:EmitSound("nox/earthquake.ogg")
		util.ScreenShake(pos, 15, 5, 0.75, 1000)
		
		--debugoverlay.Sphere(pos, self.Radius, 5, COLOR_YELLOW)
		for _, ent in pairs(ents.FindInSphere(pos, self.Radius)) do
			if ent:IsValid() and ent:IsPlayer() and ent:GetTeamID() ~= owner:Team() and ent:Alive() and ent:OnGround() and math.abs((ent:GetPos() - pos).z) <= 72 then
				ent:SetGroundEntity(NULL)
				local offset = VectorRand():GetNormal() * self.XYVel
				offset.z = 0
				ent:SetVelocity(Vector(0, 0, self.ZVel) + offset)
				if TrueVisible(ent:GetPos(), pos) then
					ent:TakeSpecialDamage(self.QuakeDamage, self.DMGType, owner, self)
				end
			end
		end
	end

	self:NextThink(CurTime())
	return true
end

function ENT:StatusOnRemove(owner)
	owner:RemoveStatus("stun_noeffect")
end
