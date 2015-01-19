AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	--self:SetModel("models/props_trainstation/trashcan_indoor001b.mdl")
	self:DrawShadow(false)
end
