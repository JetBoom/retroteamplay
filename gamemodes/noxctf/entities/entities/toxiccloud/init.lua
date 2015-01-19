AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
end

function ENT:Think()
	local owner = self:GetOwner()
	if not owner:IsValid() then
		if self.FireCaster and self.FireCaster:IsValid() then
			self:SetOwner(self.FireCaster)
		else
			self:Remove()
			return
		end
	end

	local pos = self:GetPos()
	local firedamage = self:GetSkin() == 1
	for _, ent in pairs(ents.FindInSphere(pos, 128)) do
		if (ent:IsPlayer() or firedamage and ent.ScriptVehicle) and TrueVisible(pos, ent:NearestPoint(pos)) then
			if firedamage then
				ent:TakeSpecialDamage(3, DMGTYPE_FIRE, owner, DUMMY_FIRECLOUD)
				if 0 < ent:Health() then
					local firecaster = self.FireCaster
					if not (firecaster and firecaster:IsPlayer()) then firecaster = owner end
					ent:TakeSpecialDamage(3, DMGTYPE_FIRE, firecaster, DUMMY_FIRECLOUD)
				end
			else
				ent:TakeSpecialDamage(3, DMGTYPE_POISON, owner, self)
			end
		end
	end

	self:NextThink(CurTime() + 0.2)
	return true
end

function ENT:ProcessDamage(attacker, inflictor, dmginfo)
	if dmginfo:GetDamageType() == DMGTYPE_FIRE and dmginfo:GetDamage() >= 30 and self:GetSkin() ~= 1 then
		self:SetSkin(1)
		self:EmitSound("ambient/fire/gascan_ignite1.wav")
		if attacker:IsPlayer() and attacker:Team() == self:GetTeamID() then
			self.FireCaster = attacker
		end
	end
end
