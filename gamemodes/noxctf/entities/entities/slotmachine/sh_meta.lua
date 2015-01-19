function ENT:ResetSlotMachine()
	self:SetSlotPlayer(NULL)
	self:SetJackpot(false)
	self:SetWon(false)
end

--Player based functions
function ENT:SetSlotPlayer(ent)
	self:SetDTEntity(0, ent)
end
function ENT:GetSlotPlayer()
	return self:GetDTEntity(0)
end

function ENT:IsCloseDistance(pl)
	return self:GetPos():Distance(pl:EyePos()) <= self.SlotDistance
end
function ENT:GetYawSum(pl)
	return math.abs(self:GetForward():Angle().yaw - pl:GetForward():Angle().yaw)
end

--Slot Win Value
function ENT:SetSlotWinValue(value)
	self:SetDTFloat(0, value)
end
function ENT:GetSlotWinValue()
	return self:GetDTFloat(0)
end

--Jackpot "pot" value
function ENT:AddJackpotValue(value)
	self:SetDTFloat(1, self:GetJackpotValue() + value)
end
function ENT:SetJackpotValue(value)
	self:SetDTFloat(1, value)
end
function ENT:GetJackpotValue()
	return self:GetDTFloat(1)
end

--Booleans
function ENT:SetJackpot(bool)
	self:SetDTBool(0, bool)
end
function ENT:GetJackpot()
	return self:GetDTBool(0)
end

function ENT:SetWon(bool)
	self:SetDTBool(1, bool)
end
function ENT:GetWon()
	return self:GetDTBool(1)
end

function ENT:SetRolling(bool)
	self:SetDTBool(2, bool)
end
function ENT:IsRolling()
	return self:GetDTBool(2)
end