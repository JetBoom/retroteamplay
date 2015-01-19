AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/w_nox_longbow.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)
	self:SetAngles(Angle(0, 0, 68))
	self:SetPos(self:GetPos() + Vector(0, 0, -4))
end
