include("shared.lua")

--[[function ENT:Draw()
	local owner = self:GetOwner()
	local eyepos = owner:EyePos()
	render.DrawWireframeSphere( eyepos + owner:GetAimVector() * 35, 22, 10, 10, COLOR_RED, true )
end]]