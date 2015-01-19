AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(CONTINUOUS_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end

	self.Charge = 0
	self.NextSound = 0
	self.NextCharge = 0

	--self:Fire("evaluate", "", 0.1)
end

function ENT:AcceptInput(name, activator, caller)
	--[[if name == "evaluate" then
		self:Fire("evaluate", "", 1)

		GAMEMODE:Evaluate(self)

		return true
	end]]
end

function ENT:Think()
	local ct = CurTime()
	if self.NextCharge < ct then
		self.NextCharge = ct + 1
		--if GAMEMODE:DrainPower(self, 2) then
			self.Charge = math.min(200, self.Charge + 2)
		--end
	end
end

util.PrecacheSound("items/medshot4.wav")
util.PrecacheSound("items/suitchargeno1.wav")
function ENT:Use(activator, caller)
	if not self.Destroyed and activator:Health() < activator:GetMaxHealth() then
		activator.NextHealthCharge = activator.NextHealthCharge or 0
		local ct = CurTime()
		if activator.NextHealthCharge < ct then
			activator.NextHealthCharge = ct + 0.2

			if 0 < self.Charge then
				local owner = NULL
				for _, pl in pairs(player.GetAll()) do
					if pl:SteamID() == self.Owner then
						owner = pl
						break
					end
				end
				GAMEMODE:PlayerHeal(activator, owner, 2)
				self.Charge = self.Charge - 2
				if self.NextSound < ct then
					self.NextSound = ct + 0.75
					self:EmitSound("items/medshot4.wav")
				end
			elseif self.NextSound < ct then
				self.NextSound = ct + 0.75
				self:EmitSound("items/suitchargeno1.wav")
				activator:SendLua("LMR(57)")
			end
		end
	end
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth..","..self.Charge--..","..tostring(self.Powered)
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT
ENT.MoneyBonus = 10
ENT.OffenseBonus = 1
ENT.FragsBonus = 1
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
