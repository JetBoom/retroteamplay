AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel("models/Gibs/HGIBS.mdl")
end

function ENT:StatusThink(owner)
	owner:ViewPunch( Angle(math.random(-17,17),math.random(-17,17),math.random(-8,8)))
	self:NextThink(CurTime() + 0.25)
	return true
end
