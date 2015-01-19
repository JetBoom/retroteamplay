AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/props_phx/wheels/trucktire.mdl") --self:SetModel("models/props_vehicles/carparts_wheel01a.mdl")
	self:PhysicsInit(SOLID_VPHYSICS) --self:PhysicsInitSphere(14, "rubber")

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(40)
		phys:Wake()
	end
end
