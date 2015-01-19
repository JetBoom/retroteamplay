AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/mixerman3d/weapons/axe01.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:SetCollisionBounds(Vector(-20, -4, 0), Vector(4, 4, 16))
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetUseType(SIMPLE_USE)
	self:DrawShadow(true)
	self:SetPos(self:GetPos() + Vector(0, 0, 4))
end
