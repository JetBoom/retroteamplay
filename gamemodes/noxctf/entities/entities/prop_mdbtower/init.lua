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
end

function ENT:Think()
	if self.Destroyed then return end

	local myteam = self:GetTeamID()
	local mypos = self:GetPos() + self:GetUp() * 288
	for _, ent in pairs(ents.FindInSphere(mypos, 1500)) do
		if ent.ScriptVehicle and ent:GetTeamID() ~= myteam and TrueVisible(mypos, ent:NearestPoint(mypos)) and not (ent.MDF and CurTime() <= ent.MDF) and not (ent.MDFImmune and CurTime() <= ent.MDFImmune) and ent:Alive() and GAMEMODE:DrainPower(self, 50) then
			ent.MDF = CurTime() + 5
			ent.MDFImmune = CurTime() + 6
			local effectpos = self:GetPos() + self:GetUp() * 243
			local effectdata = EffectData()
				effectdata:SetOrigin(ent:NearestPoint(effectpos))
				effectdata:SetStart(effectpos)
				effectdata:SetEntity(ent)
			util.Effect("mdb", effectdata)

			local owner = NULL
			for _, pl in pairs(player.GetAll()) do
				if pl:SteamID() == self.Owner and pl:Team() == myteam then owner = pl break end
			end

			ent:TakeSpecialDamage(50, DMGTYPE_SHOCK, owner, self)

			if owner ~= NULL then
				for _, veh in pairs(ents.FindByClass("prop_vehicle_prisoner_pod")) do
					if veh:GetDTEntity(0) == ent then
						local driver = veh:GetDriver()
						if driver:IsPlayer() then driver:SetLastAttacker(owner) end
					end
				end

				ent.LastAttacked = CurTime()
				ent.Attacker = owner
			end

			break
		end
	end

	self:NextThink(CurTime() + 0.5)
	return true
end

function ENT:Info(pl)
	if pl:Team() == self:GetTeamID() then
		return self.PHealth..","..self.MaxPHealth
	end

	return "deny"
end

ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT2
ENT.MoneyBonus = 30
ENT.OffenseBonus = 3
ENT.FragsBonus = 3
ENT.ProcessDamage = PROPGENERICPROCESSDAMAGE
