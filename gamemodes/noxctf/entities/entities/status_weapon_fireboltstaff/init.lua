AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel("models/morrowind/daedric/staff/w_daedric_staff.mdl")
end

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer.WeaponStatus = self
end
