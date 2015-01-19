AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/hunter/misc/sphere1x1.mdl")
	self:SetMaterial("models/shiny")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:DrawShadow(false)
end
