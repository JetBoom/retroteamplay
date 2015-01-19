AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end

	self.IgnoreDamageTime = 0
end

function ENT:PhysicsCollide(data, phys)
	local vp = self:GetVehicleParent()
	if vp and vp:IsValid() then
		data.Speed = data.Speed * 0.75
		vp:PhysicsCollide(data, vp:GetPhysicsObject(), true)
	end
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	local vp = self:GetVehicleParent()
	if vp and vp:IsValid() and vp.IgnoreDamageTime ~= CurTime() then
		local dmgtype = dmginfo:GetDamageType()
		vp.IgnoreDamageTime = CurTime()
		if dmgtype == DMGTYPE_GENERIC or dmgtype == DMGTYPE_IMPACT or dmgtype == DMGTYPE_PIERCING or dmgtype == DMGTYPE_SLASHING then
			dmginfo:SetDamage(dmginfo:GetDamage() / 3)
		end
		vp:TakeDamageInfo(dmginfo)
	end
end
