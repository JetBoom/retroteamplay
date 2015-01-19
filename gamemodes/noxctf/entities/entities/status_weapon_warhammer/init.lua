AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel("models/morrowind/orcish/hammer/w_orcish_hammer.mdl")
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.WeaponStatus = self
end