AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	pPlayer:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
end

function ENT:Think()
	if self:GetBlades() <= 0 then self:Remove() end
end