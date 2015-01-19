AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.m_NextZap = 0
ENT.m_LastZap = 0

function ENT:PlayerSet(pPlayer, bExists)
	self:SetStartTime(CurTime() + self.StartTime)

	hook.Add("TranslateActivity", self, self.TranslateActivity)
end

function ENT:StatusShouldRemove(owner)
	return owner:GetVelocity():Length() > 20 or owner:GetMana() < self.ManaPerZap or self:GetLastZap() > 0 and CurTime() > self:GetLastZap() + 1
end

function ENT:StatusThink(owner)
	if CurTime() >= self:GetStartTime() and CurTime() >= self:GetNextZap() then
		self:ScanForTarget()

		local target = self:GetTarget()
		if self:IsValidTarget(target) then
			self:SetNextZap(CurTime() + 1 / self.ZapsPerSecond)
			self:SetLastZap(CurTime())

			owner:SetMana(owner:GetMana() - self.ManaPerZap, true)
			target:TakeSpecialDamage(self.DamagePerZap, DMGTYPE_LIGHTNING, owner, self, owner:EyePos())
		elseif self:GetTarget() ~= NULL then
			self:SetTarget(NULL)
		end
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

function ENT:SetNextZap(time) self.m_NextZap = time end
function ENT:GetNextZap() return self.m_NextZap end
function ENT:SetLastZap(time) self.m_LastZap = time end
function ENT:GetLastZap() return self.m_LastZap end
