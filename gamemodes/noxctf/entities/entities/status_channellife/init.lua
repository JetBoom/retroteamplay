AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	hook.Add("DoPlayerDeath", self, self.DoPlayerDeath)
end

function ENT:PlayerSet(pPlayer, bExists)
	local owner = self:GetOwner()
	self.Sacrifice = math.min(30, owner:Health() - 1, owner:GetMaxMana() - owner:GetMana())
	owner:SetHealth(owner:Health() - self.Sacrifice)
	owner.LastAttacker = owner
	owner.LastAttacked = CurTime()
end

function ENT:StatusThink(owner)
	if not self.Mana then
		self.Mana = true
		owner:SetMana(math.min(owner:GetMana() + self.Sacrifice,owner:GetMaxMana()), true)
	end
end

function ENT:DoPlayerDeath(pl, attacker, dmginfo)
	if attacker ~= self:GetOwner() then return end

	attacker:SetHealth(math.min(attacker:GetMaxHealth(), attacker:Health() + self.Sacrifice))
	attacker:RemoveStatus("channellife")
	attacker:EmitSound("nox/heal.ogg", 80, 75)

	local effectdata = EffectData()
		effectdata:SetOrigin(pl:GetPos())
		effectdata:SetStart(attacker:GetPos())
	util.Effect("greaterheal", effectdata)
end
