include("shared.lua")
--[[
function ENT:Draw()
	local owner = self:GetOwner()
	local eyepos = owner:EyePos()
	render.DrawWireframeSphere( eyepos + owner:GetAimVector() * 30, 15, 10, 10, COLOR_RED, true )
end]]