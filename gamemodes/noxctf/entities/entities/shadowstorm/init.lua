AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	local owner = self:GetOwner()
	local pos = self:GetPos()
	if owner:IsValid() and owner:GetCenter():Distance(pos) <= self.Radius and TrueVisible(pos, owner:NearestPoint(pos)) and not owner:GetStatus("shadowstorm") then
		owner:GiveStatus("shadowstorm"):SetEnt(self)
	end

	self:NextThink(CurTime())
	return true
end