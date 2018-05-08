include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
	self.DeathTime = CurTime() + self.DeathTime
	self:SetEruptTime(CurTime() + self.EruptTime)
	self.Touched = {}

	self:DrawShadow(false)
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
		return
	end

	if CurTime() >= self:GetEruptTime() then
		if not self.Splashed then
			self.Splashed = true
			self:EmitSound(")vehicles/Airboat/pontoon_splash"..math.random(1,2)..".wav")
			self:EmitSound("ambient/machines/thumper_top.wav")
		end

		local owner = self:GetOwner()
		if not owner:IsValid() then owner = self end

		local myteam = self:GetTeamID()
		local pos = self:GetPos()
		for _, ent in pairs(ents.FindInSphere(pos, self.Radius)) do
			if ent:GetSolid() > 0 and not self.Touched[ent] and (ent:GetTeamID() ~= myteam or ent == owner) and TrueVisible(pos, ent:NearestPoint(pos)) and math.abs((ent:GetPos() - pos).z) <= 10 then
				self.Touched[ent] = true

				if ent:IsPlayer() and ent:Alive() then
					ent:SetGroundEntity(NULL)
					ent:SetVelocity(Vector(0, 0, 600))
				end

				if ent == owner then
					ent:Fire("ignorefalldamage", "2.5", 0)
				else
					ent:TakeSpecialDamage(self.Damage, DMGTYPE_COLD, owner, self)
				end
			end
		end

		self:NextThink(CurTime())
		return true
	end
end
