AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	hook.Add("PlayerHurt", self, self.PlayerHurt)

	local effectdata = EffectData()
		effectdata:SetOrigin(pPlayer:EyePos())
		effectdata:SetEntity(pPlayer)
	util.Effect("invisibility_in", effectdata, true)
end

function ENT:PlayerHurt(pl, attacker, healthremaining, damage)
	if pl ~= self:GetOwner() then return end

	if damage > 0 and not pl:StatusWeaponHook("ShouldRemainInvisible") then
		self:Remove()
	end
end

function ENT:StatusOnRemove(owner)
	local effectdata = EffectData()
		effectdata:SetOrigin(owner:EyePos())
		effectdata:SetEntity(owner)
	util.Effect("invisibility_out", effectdata, true)

	--Also remove thread lightly
	owner:RemoveStatus("treadlightly", false, true)
end