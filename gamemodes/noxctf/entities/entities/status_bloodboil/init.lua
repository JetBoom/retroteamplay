AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusOnRemove(owner)
	if not owner:IsValid() or owner:Alive() or owner.Suicided then return end

	local pos = owner:GetCenter()

	ExplosiveDamage(self.BloodBoilOwner, pos, self.ExplosionRadius, self.ExplosionRadius, 1, 0.375, 0, DUMMY_BLOODBOIL, DMGTYPE_FIRE)

	local effectdata = EffectData()
		effectdata:SetOrigin(pos)
		effectdata:SetMagnitude(self.ExplosionRadius)
	util.Effect("bloodboil", effectdata, true, true)
end