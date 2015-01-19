AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MoneyBonus = 0

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	self:SetTrigger(true)
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
end

function ENT:DoExplode()
	if self.Exploded then return end
	self.Exploded = true
	self.Gone = true

	self:EmitSound("nox/explosion02.ogg", 88, 100)

	local effectdata = EffectData()
		effectdata:SetRadius(1)
		effectdata:SetMagnitude(1)
		effectdata:SetScale(1)
		effectdata:SetEntity(self)
		local mypos = self:GetPos() + Vector(0,0,8)
		effectdata:SetOrigin(mypos)
	util.Effect("poisonmineexplosion", effectdata, true, true)

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

	for _, ent in pairs(ents.FindInSphere(self:GetPos(),150)) do
		if ent:IsPlayer() and ent:Team() ~= self:GetTeamID() and ent:Alive() then
			ent:SetGroundEntity(NULL)
			ent:SetVelocity(50 * (ent:LocalToWorld(ent:OBBCenter()) - mypos):GetNormal())
			local dist = math.Clamp(8-math.Round(ent:GetPos():Distance(self:GetPos())/3),0,2)
			ent:Poison(10 + dist, 1, true)
		end
	end
	
	local cloud = ents.Create("toxicminecloud")
	if cloud:IsValid() then
		cloud:SetPos(self:GetPos())
		cloud:SetOwner(attacker)
		cloud:SetTeamID(attacker:GetTeamID())
		cloud:Spawn()
		cloud:Fire("kill", "", 6)
	end

	self:Remove()
end

function ENT:StartTouch(ent)
	if ent:IsPlayer() and ent:Team() ~= self:GetTeamID() and not self.Destroyed then
		self.ArmedBy = ent
		self:EmitSound("HL1/fvox/activated.wav")
		self:DoExplode()
	end
end

function ENT:EndTouch(ent)
--	if self.ArmedBy and ent == self.ArmedBy then
--		self:DoExplode()
--	end
end

function ENT:DestructionEffect()
	if self.Destroyed then
		local effectdata = EffectData()
			effectdata:SetRadius(1)
			effectdata:SetMagnitude(1)
			effectdata:SetScale(1)
			effectdata:SetOrigin(self:GetPos())
		util.Effect("Explosion", effectdata, true, true)
	else
		self:DoExplode()
	end
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	dmginfo:SetDamage(self.MaxPHealth)
	PROPGENERICPROCESSDAMAGE(self, attacker, inflictor, dmginfo)
end
