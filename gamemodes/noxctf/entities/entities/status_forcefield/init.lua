AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:PlayerSet(pPlayer, bExists)
	self:SetModel("models/hunter/misc/sphere1x1.mdl") -- models/XQM/Rails/gumball_1.mdl
	self:SetForceFieldHealth(math.max(self:GetForceFieldHealth() or self.MaxForceFieldHealth, self.MaxForceFieldHealth))
end


