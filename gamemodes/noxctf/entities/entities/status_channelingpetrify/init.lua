AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.NextDrain = 0

function ENT:PlayerSet(pPlayer, bExists)
	local owner = self:GetOwner()
	
	self:ScanForTarget()

	local target = self:GetTarget()
	if target:IsValid() then
		target:SetJumpPower(0)
		if owner:IsValid() then owner:GiveStatus("pacifism", self:GetDieTime() - CurTime()) end
	end

	hook.Add("TranslateActivity", self, self.TranslateActivity)

	self.LifeTime = self:GetDieTime() - CurTime()
end

function ENT:StatusShouldRemove(owner)
	return owner:GetVelocity():Length() > 20 or owner:GetStatus("manastun") or owner:GetStatus("petrify") or owner:GetStatus("frozen") or owner:GetMana() < self.ManaPerSecond * self.TickTime or not self:IsValidTarget(self:GetTarget())
end

function ENT:StatusOnRemove(owner)
	local owner = self:GetOwner()
	local target = self:GetTarget()
	if not owner:IsValid() or not target:IsValid() then return end

	owner:RemoveStatus("pacifism")
	RestoreSpeed(target)
	if CurTime() >= self:GetDieTime() then target:GiveStatus("petrify", 4) end
end

function ENT:StatusThink(owner)
	if CurTime() > self.NextDrain then
		self.NextDrain = CurTime() + self.TickTime
		owner:SetMana(owner:GetMana() - self.ManaPerSecond * self.TickTime, true)

		local target = self:GetTarget()
		if target:IsValid() then target:SetLastAttacker(owner) end
	end
	
	self:NextThink(CurTime())
	return true
end

function ENT:ScanForTarget()
	if self:HasValidTarget() then return true end

	local owner = self:GetOwner()
	local startpos = self:GetStartPos()
	local dir = owner:GetAimVector()
	for dist = 50, self.MaxRange, 50 do
		for _, ent in pairs(ents.FindInSphere(startpos + dir * dist, 50)) do
			if self:IsValidTarget(ent) then
				self:SetTarget(ent)
				return true
			end
		end
	end

	return false
end