AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	hook.Add("PlayerHurt", self, self.PlayerHurt)
	self.Start = CurTime()
end

function ENT:PlayerHurt(pl, attacker, healthremaining, damage)
	if pl ~= self:GetOwner() then return end

	if damage > 0 and not pl:StatusWeaponHook("ShouldRemainInvisible") then
		self:Remove()
	end
end

function ENT:StatusShouldRemove(owner)
	return owner:GetVelocity():Length() > 20 or owner:GetStatus("manastun") or owner:GetMana() < self.ManaPerTick
end

function ENT:StatusThink(owner)
	if not self.NextTick or CurTime() >= self.NextTick then
		self.NextTick = CurTime() + self.TickInterval
		owner:SetMana(owner:GetMana() - self.ManaPerTick, true)
		GAMEMODE:PlayerHeal(owner, owner, 2)
	end
	
	self:NextThink(CurTime())
	return true
end

function ENT:StatusOnRemove(owner, silent)
	if owner:GetStatus("dragonblood") then
		if owner:GetStatus("dragonblood"):GetDieTime() > (CurTime() - self.Start) + CurTime() then
			return
		end
	end
	if owner:Alive() and (CurTime() - self.Start) > 0.4 then
		owner:GiveStatus("dragonblood", math.min((CurTime() - self.Start) * 2, 10))
	end
end

