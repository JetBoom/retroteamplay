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
	util.Effect("shockmineexplosion", effectdata, true, true)
	
	local effect2 = ents.Create("point_tesla")
	if effect2:IsValid() then
		effect2:SetKeyValue("m_flRadius", "250")
		effect2:SetKeyValue("m_SoundName", "DoSpark")
		effect2:SetKeyValue("m_Color", "255 255 255")
		effect2:SetKeyValue("texture", "effects/laser1.vmt")
		effect2:SetKeyValue("beamcount_min", "12")
		effect2:SetKeyValue("beamcount_max", "15")
		effect2:SetKeyValue("thick_min", "20")
		effect2:SetKeyValue("thick_max", "50")
		effect2:SetKeyValue("lifetime_min", "0.8")
		effect2:SetKeyValue("lifetime_max", "1")
		effect2:SetKeyValue("interval_min", "0.1")
		effect2:SetKeyValue("interval_max", "0.25")
		effect2:SetPos(self:GetPos() + Vector(0,0,8))
		effect2:Spawn()
		effect2:Fire("DoSpark", "", 0.1)
		effect2:Fire("kill", "", 1)
	end

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
			ent:ManaStun(3)
			ent:TakeSpecialDamage(15, DMGTYPE_SHOCK, attacker, self)
		end
	end

	function self:Think()
		self:Remove()
	end
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
