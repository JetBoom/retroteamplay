AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel("models/morrowind/dwemer/mace/w_dwemer_mace.mdl")
	self:SetOrbSize(CurTime())
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.WeaponStatus = self
end