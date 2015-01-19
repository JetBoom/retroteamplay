AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self.DeathTime = CurTime() + self.ExplodeTime -- when it blows up
	self.PlaceTime = CurTime() + self.SetTime -- when it's placed
end

function ENT:Think()
	local owner = self.Owner
	if self.DeathTime < CurTime() then
		local pos1 = self.ExplodePos
		local rad = self.Radius
		if DEBUG then debugoverlay.Sphere(pos1, rad, 5, COLOR_RED) end
		for _, ent in pairs(ents.FindInSphere(pos1, rad)) do
			local pos2 = ent:GetCenter()
			if ent:IsValid() and ent:IsPlayer() and TrueVisible(pos1, pos2) then
				if ent:GetTeamID() ~= self:GetTeamID() then
					ent:TakeSpecialDamage(self.Damage, DMGTYPE_GENERIC, owner, self)
				else
					GAMEMODE:PlayerHeal(ent, owner, self.Damage)
				end
			end
		end
		
		local effectdata = EffectData()
			effectdata:SetOrigin(pos1)
			effectdata:SetNormal(Vector(0, 0, -1))
			effectdata:SetScale(self:GetTeamID())
			effectdata:SetEntity(owner)
		util.Effect("holynova", effectdata)
		self:Remove()
	elseif self.PlaceTime >= CurTime() then
		if not owner:IsValid() or not owner:Alive() then
			self:Remove()
		end
	else
		if not self.ExplodePos then
			self.ExplodePos = owner:EyePos() + owner:EyeAngles():Forward() * 29
		end
	end
	
	self:NextThink(CurTime())
	return true
end

