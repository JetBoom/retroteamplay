AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	GAMEMODE:KOTH_AwardPoints()
	self:NextThink(CurTime() + 1)

	return true
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end
