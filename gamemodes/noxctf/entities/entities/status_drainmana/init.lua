AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.m_NextDrain = 0
ENT.m_LastDrain = 0
ENT.m_StartTime = 0

function ENT:PlayerSet(pPlayer, bExists)
	self:SetStartTime(CurTime() + self.StartTime)

	hook.Add("TranslateActivity", self, self.TranslateActivity)
end

function ENT:StatusShouldRemove(owner)
	return owner:GetVelocity():Length() > 20 or owner:GetMana() >= owner:GetMaxMana() or self:GetLastDrain() > 0 and CurTime() > self:GetLastDrain() + 1
end

function ENT:StatusThink(owner)
	if CurTime() >= self:GetStartTime() and CurTime() >= self:GetNextDrain() then
		self:ScanForTarget()

		local target = self:GetTarget()
		if target:IsValid() then
			self:SetNextDrain(CurTime() + 1 / self.DrainsPerSecond)
			self:SetLastDrain(CurTime())

			owner:SetMana(math.min(owner:GetMaxMana(), owner:GetMana() + self.ManaPerDrain), true)
			target:SetMana(math.max(0, target:GetMana() - self.ManaPerDrain), true)
		end
	end

	self:NextThink(CurTime())
	return true
end

local function drainsort(a, b)
	if a:IsPlayer() and b:IsPlayer() then
		return a._TEMP < b._TEMP
	elseif a:IsPlayer() then
		return true
	end

	return false
end

function ENT:ScanForTarget()
	local curtarget = self:GetTarget()
	if curtarget ~= NULL then
		if self:IsValidTarget(curtarget) then return end
		self:SetTarget(NULL)
	end

	local startpos = self:GetStartPos()
	local foundents = ents.FindInSphere(startpos, self.MaxRange)
	for _, ent in pairs(foundents) do
		ent._TEMP = ent:NearestPoint(startpos):Distance(startpos)
	end

	table.sort(foundents, drainsort)
	for _, ent in pairs(foundents) do
		ent._TEMP = nil
	end

	for _, ent in ipairs(foundents) do
		if self:IsValidTarget(ent) then
			self:SetTarget(ent)
			break
		end
	end
end

function ENT:SetNextDrain(time) self.m_NextDrain = time end
function ENT:GetNextDrain() return self.m_NextDrain end
function ENT:SetLastDrain(time) self.m_LastDrain = time end
function ENT:GetLastDrain() return self.m_LastDrain end
function ENT:SetStartTime(time) self.m_StartTime = time end
function ENT:GetStartTime() return self.m_StartTime end
