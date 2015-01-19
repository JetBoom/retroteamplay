AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

CAPACITORS = {}

function ENT:Initialize()
	self:SetModel("models/props_trainstation/trainstation_ornament001.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetUseType(SIMPLE_USE)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then phys:EnableMotion(false) end
	self:SetMaterial("models/shiny")

	local myteam = self:GetTeamID()
	local col = team.TeamInfo[myteam].Color
	self:SetColor(Color(col.r, col.g, col.b, 255))

	self:SetName(myteam)
	team.SetScore(myteam, 0)

	self.GCHealth = GC_HEALTH
	self:Fire("heal", "", GC_OVERTIME_MANAGAINTIME)
	self.ManaStorage = 0
	self.MaxManaStorage = GC_MAX_MANA
	self:SetMana(0)
	
	self.Warned_50 = false
	self.Warned_90 = false
	
	self.MaterialType = RESISTANCE_INVULNERABLE
	
	self.GrandCapacitor = true
	
	table.insert(CAPACITORS, self)

	self.Think = nil
end

function ENT:AcceptInput(name, activator, caller)
	if name == "heal" then
		self:Fire("heal", "", GC_OVERTIME_MANAGAINTIME)
			if OVERTIME then
				local myteam = self:GetTeamID()
				
				self.ManaStorage = self.ManaStorage + GC_OVERTIME_MANAGAIN
				self:SetMana(self.ManaStorage)
				team.SetScore(myteam, self.ManaStorage)
				
				if self.ManaStorage >= GC_MAX_MANA * .5 and not self.Warned_50 then
					self.Warned_50 = true
					GAMEMODE:CenterPrintAll("The "..team.GetName(myteam).." grand capacitor is 50% full!")	
				end
	
				if self.ManaStorage >= GC_MAX_MANA * .9 and not self.Warned_90 then
					self.Warned_90 = true
					GAMEMODE:CenterPrintAll("The "..team.GetName(myteam).." grand capacitor is 90% full!")	
				end

				if self.ManaStorage >= GC_MAX_MANA then
					GAMEMODE:EndGame(myteam, {})
					GAMEMODE:CenterPrintAll("The "..team.GetName(myteam).." grand capacitor is full!")
				end
			end
		return true
	end
end

function ENT:UpdateTransmitState()
	return TRANSMIT_ALWAYS
end

function ENT:ManaReceived(from, amount)
	self:SetMana(self.ManaStorage)
	
	local myteam = self:GetTeamID()
	team.SetScore(myteam, self.ManaStorage)

	if self.ManaStorage >= GC_MAX_MANA * .5 and not self.Warned_50 then
		self.Warned_50 = true
		GAMEMODE:CenterPrintAll("The "..team.GetName(myteam).." grand capacitor is 50% full!")	
	end
	
	if self.ManaStorage >= GC_MAX_MANA * .9 and not self.Warned_90 then
		self.Warned_90 = true
		GAMEMODE:CenterPrintAll("The "..team.GetName(myteam).." grand capacitor is 90% full! Destroy their translocators!")	
	end
	
	if self.ManaStorage >= GC_MAX_MANA - 50 then
		GAMEMODE:EndGame(myteam, {})
		GAMEMODE:CenterPrintAll("The "..team.GetName(myteam).." grand capacitor is full!")
	end
end

function ENT:Info(pl)
	return self.GCHealth..","..self.GCHealth..","..self.MaxManaStorage
end