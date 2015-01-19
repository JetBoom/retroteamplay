AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	self.CounterSpell = COUNTERSPELL_CUSTOM

	pPlayer.Explosion = true
	pPlayer:EmitSound("ambient/fire/mtov_flame2.wav")
end

function ENT:DoExplode(ent)
	local effectdata = EffectData()
		effectdata:SetOrigin(ent:EyePos())
	util.Effect("explosionexplosion", effectdata)
	ExplosiveDamage(self.Attacker, self, 100, 100, 1, 0.25, 8)
end

function ENT:OnRemove()
	local parent = self:GetParent()
	if parent:IsValid() then
		if not self.SilentRemove then
			self:DoExplode(parent)
		end
		parent.Explosion = nil
	end
end
