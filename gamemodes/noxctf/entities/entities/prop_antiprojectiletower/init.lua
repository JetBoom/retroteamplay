AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

ENT.MoneyBonus = 30
ENT.OffenseBonus = 3
ENT.FragsBonus = 3
ENT.DestructionEffect = PROPGENERICDESTRUCTIONEFFECT2

function ENT:Initialize()
	self.BaseClass.Initialize(self)

	local effect2 = ents.Create("point_tesla")
	if effect2:IsValid() then
		effect2:SetKeyValue("m_flRadius", "150")
		effect2:SetKeyValue("m_SoundName", "DoSpark")
		effect2:SetKeyValue("m_Color", "220 220 255")
		effect2:SetKeyValue("texture", "effects/laser1.vmt")
		effect2:SetKeyValue("beamcount_min", "6")
		effect2:SetKeyValue("beamcount_max", "9")
		effect2:SetKeyValue("thick_min", "15")
		effect2:SetKeyValue("thick_max", "35")
		effect2:SetKeyValue("lifetime_min", "0.5")
		effect2:SetKeyValue("lifetime_max", "1")
		effect2:SetKeyValue("interval_min", "0.1")
		effect2:SetKeyValue("interval_max", "0.25")
		effect2:SetPos(self:GetPos() + self:GetUp() * 100)
		effect2:Spawn()
		effect2:SetParent(self)
		self.Tesla = effect2
	end
end

function ENT:Think()
	if not self.Destroyed then
		local pos = self:GetPos() + self:GetUp() * 100
		local attacked
		local myteam = self:GetTeamID()
		for _, ent in pairs(ents.FindInSphere(pos, 768)) do
			if string.sub(ent:GetClass(), 1, 11) == "projectile_" and ent:GetClass() ~= "projectile_protrusionspike" and ent:GetTeamID() ~= myteam and ent:GetMoveType() == MOVETYPE_VPHYSICS then
				local entpos = ent:GetPos()
				if not util.TraceLine({start=pos, endpos=entpos, filter=ent}).Hit and GAMEMODE:DrainPower(self, ent.APTowerMana or 10) then
					attacked = true

					local effectdata = EffectData()
						effectdata:SetOrigin(entpos)
						effectdata:SetStart(pos)
					util.Effect("gunmage_silverbullet", effectdata)
					if ent.Explode then
						ent:Explode(entpos, ent:GetVelocity():GetNormal() * -1)
					else
						ent:Remove()
					end
				end
			end
		end
		if attacked then
			self.Tesla:Fire("DoSpark", "", 0.1)
			self.Tesla:Fire("DoSpark", "", 0.3)
		end
	end

	self:NextThink(CurTime() + 0.3)
	return true
end
