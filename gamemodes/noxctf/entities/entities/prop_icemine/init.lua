AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MoneyBonus = 0

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:SetTrigger(true)
	self:SetMaterial("models/shiny")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function ENT:DoExplode()
	if self.Exploded then return end
	self.Exploded = true
	self.Gone = true

	self:EmitSound("physics/glass/glass_largesheet_break1.wav")

	local teamid = self:GetTeamID()
	if team.TeamInfo[teamid] then
		team.AddProps(teamid, -1)
	end

	local ownersteam = self.Owner
	local attacker = self
	for _, pl in pairs(player.GetAll()) do
		if pl:SteamID() == ownersteam and pl:Team() == teamid then
			attacker = pl
		end
	end

	function self:Think()
		self:Remove()
	end	
	
	local ent = ents.Create("projectile_icemineprotrusion")
	if ent:IsValid() then
		ent:SetPos(self:GetPos())
		if attacker:IsValid() then
			ent:SetOwner(attacker)
		end
		ent:SetTeamID(teamid)
		ent:Spawn()
	end
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:Team() ~= self:GetTeamID() and not self.Destroyed then
		self:EmitSound("HL1/fvox/activated.wav")
		self:DoExplode()
	end
end

function ENT:DestructionEffect()
	if self.Destroyed then
		local effectdata = EffectData()
			effectdata:SetOrigin(self:GetPos())
		util.Effect("shatter", effectdata, true, true)
		self:EmitSound("physics/glass/glass_sheet_break"..math.random(1, 3)..".wav")
	else
		self:DoExplode()
	end
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	dmginfo:SetDamage(self.MaxPHealth)
	PROPGENERICPROCESSDAMAGE(self, attacker, inflictor, dmginfo)
end
