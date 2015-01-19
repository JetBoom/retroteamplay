AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(self.ShouldDrawShadow)

	self:StatusInitialize()
end

function ENT:OnRemove()
	local owner = self:GetParent()
	if owner:IsValid() and not self.SilentRemove then
		self:PlaySound(owner, "End")
	end
	
	if self.Animation then owner:StopLuaAnimation(self.Animation, .1) end
	if self.DisableJump then RestoreSpeed(owner) end

	self:StatusOnRemove(owner, self.SilentRemove)
end

function ENT:StatusShouldRemove(owner)
	return false
end

function ENT:SetPlayer(pPlayer, bExists)
	self:PlaySound(pPlayer, "Start")

	if bExists then
		self:PlayerSet(pPlayer, bExists)
	else
		local bValid = pPlayer and pPlayer:IsValid()
		if bValid then
			self:SetPos(pPlayer:GetPos() + Vector(0, 0, 16))
		end
		self.Owner = pPlayer
		pPlayer[self:GetClass()] = self
		self:SetOwner(pPlayer)
		self:SetParent(pPlayer)
		
		if self.Animation then pPlayer:ResetLuaAnimation(self.Animation) end
		if self.Move ~= nil then hook.Add("Move", self, self.Move) end
		if self.PreMove ~= nil then hook.Add("PreMove", self, self.PreMove) end
		if self.PostMove ~= nil then hook.Add("PostMove", self, self.PostMove) end
		
		self.TeamCol = team.GetColor(pPlayer:GetTeamID()) or color_white
		
		if bValid then
			self:PlayerSet(pPlayer)
		end
	end
end

function ENT:Think()
	local owner = self:GetOwner()
	if owner:IsValid() then
		if self:GetDieTime() > 0 and CurTime() >= self:GetDieTime() or self:StatusShouldRemove(owner) then
			self:Remove()
			return
		end
		
		if self.DisableJump then owner:SetJumpPower(0) end

		return self:StatusThink(owner)
	end
end

function ENT:PlayerSet(pPlayer, bExists)
end
