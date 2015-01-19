AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	self.Think = nil
	self.AmmoType = "Plasma"
end

function ENT:GetTurretModel(turret)
	return "models/props_c17/canister_propane01a.mdl"
end

function ENT:AcceptInput(name, activator, caller, args)
	if name == "created" then
		local bo = self.BasedOn
		if bo and bo:IsValid() and bo:GetClass() == "prop_mountableturret" and bo:GetTeamID() == self:GetTeamID() and bo:NearestPoint(self:GetPos()):Distance(self:GetPos()) < 128 then
			bo:Attach(self)
		end
		return true
	end
end

function ENT:GetTurretPos(turret, seat)
	return seat:GetPos() + seat:GetForward() * -32
end

function ENT:GetTurretAngles(turret, seat)
	return seat:GetAngles()
end

util.PrecacheSound("npc/dog/dog_servo2.wav")
function ENT:BarrelChanged(turret, barrel)
	turret:EmitSound("npc/dog/dog_servo2.wav")
end

function ENT:Use(activator, caller)
	if self.Destroyed then return end
	if not activator:IsPlayer() then return end

	if activator:Team() == self:GetTeamID() then
		if not (self.Connection and self.Connection:IsValid()) then
			if activator.mTurretConnecting and activator.mTurretConnecting == self then
				activator:PrintMessage(4, "You decide not to attach it to anything.")
				activator:SendLua([[surface.PlaySound("buttons/button16.wav")]])
				activator.mTurretConnecting = nil
			else
				activator:PrintMessage(4, "Press USE on a turret to attach the barrel.")
				activator:SendLua([[surface.PlaySound("buttons/button9.wav")]])
				activator.mTurretConnecting = self
			end
		end
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 10
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
