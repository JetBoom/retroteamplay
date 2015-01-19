AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	hook.Add("EntityTakeDamage", self, self.EntityTakeDamage)
end
