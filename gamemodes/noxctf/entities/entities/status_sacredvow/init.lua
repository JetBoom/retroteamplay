AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	local caster = self:GetCaster()
	if caster:IsValid() and caster:Alive() then 
		caster.SacredVowCaster = self
	end
end

function ENT:StatusShouldRemove(owner)
	local caster = self:GetCaster()
	return not caster:IsValid() or not caster:Alive() or owner:GetCenter():Distance(caster:GetCenter()) > self.Dist or CLASSES[caster:GetPlayerClass()].Name ~= "Paladin"
end

function ENT:StatusThink(owner)
	local caster = self:GetCaster()
	if not caster.SacredVowCaster then
		caster.SacredVowCaster = self -- in case another protected player breaks a different tether
	end
		
	-- we only want one foot effect playing if there are multiple statuses placed on allies
	if caster.SacredVowCaster == self then
		self:SetSkin(1)
	else
		self:SetSkin(0)
	end
	
end

function ENT:StatusOnRemove(owner)
	self:GetCaster().SacredVowCaster = nil
end
