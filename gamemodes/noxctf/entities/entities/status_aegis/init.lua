AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:StatusInitialize()
	self:SetModel(math.random(2) == 1 and "models/props_wasteland/rockcliff01b.mdl" or "models/props_wasteland/rockcliff01c.mdl")
end
