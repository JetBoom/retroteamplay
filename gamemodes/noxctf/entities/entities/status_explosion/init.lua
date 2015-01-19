AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.CounterSpell = COUNTERSPELL_CUSTOM

function ENT:CounterSpelled(pl)
	self.SilentRemove = true

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("counterspell", effectdata, true)

	self:Remove()
end

function ENT:DoExplode(ent)
	local effectdata = EffectData()
		effectdata:SetOrigin(ent:EyePos())
	util.Effect("explosionexplosion", effectdata)
	ExplosiveDamage(self.Attacker, self, 100, 100, 1, 0.25, 8)
end

function ENT:StatusOnRemove(owner)
	if not self.SilentRemove then
		self:DoExplode(owner)
	end
end
