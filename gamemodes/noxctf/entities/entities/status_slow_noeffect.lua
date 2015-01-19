AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "status_slow"

ENT.StartSound = false
ENT.EndSound = false
ENT.StatusImage = false

if SERVER then return end

ENT.RenderGroup = RENDERGROUP_NONE

function ENT:StatusInitialize()
end

function ENT:Draw()
end
