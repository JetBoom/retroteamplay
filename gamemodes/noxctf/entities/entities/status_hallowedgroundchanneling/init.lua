AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	self.StartTime = CurTime()
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:Stun(self:GetDieTime() - CurTime(), true, true)
end

function ENT:StatusShouldRemove(owner)
	return not owner:OnGround() or owner:GetStatus("manastun")
end

function ENT:StatusThink(owner)
	local pos = owner:GetPos()
	for _, ent in pairs(ents.FindInSphere(pos, 400)) do
		if ent:IsValid() and ent:IsPlayer() and ent:GetTeamID() == owner:Team() and ent:Alive() then
			ent:GiveStatus("hallowedground")
		end
	end
	self:NextThink(CurTime())
	return true
end

function ENT:StatusOnRemove(owner)
	local pos = owner:GetPos()
	owner:RemoveStatus("stun_noeffect")
	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetNormal(Vector(0,0,1))
	util.Effect("shockwave", effectdata)
	local effectdata2 = EffectData()
		effectdata2:SetOrigin(pos)
		effectdata2:SetEntity(owner)
	util.Effect("soulexplosion", effectdata2)

	local charges = 15 + self:GetCharges() * 2
	for _, ent in pairs(ents.FindInSphere(pos, 400)) do
		if ent:GetTeamID() == owner:Team() then
			if ent:IsPlayer() and ent:Alive() then
				GAMEMODE:PlayerHeal(ent, owner, charges)
			end
		else
			ent:TakeSpecialDamage(charges, DMGTYPE_ARCANE, owner, self)
		end
	end
end
