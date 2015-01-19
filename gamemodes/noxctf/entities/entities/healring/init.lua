AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_DESTROY

	self.DeathTime = CurTime() + 1.75

	self:GetOwner().HealRing = self
	RestoreSpeed(self:GetOwner())
end

function ENT:Think()
	local owner = self:GetOwner()
	if self.DeathTime and owner:IsPlayer() and owner:Alive() then
		if self.DeathTime <= CurTime() then
			self.DeathTime = nil

			local pos = self:GetPos()
			for _, ent in pairs(ents.FindInSphere(pos, 150)) do
				if ent:IsPlayer() and ent:Team() == self:GetTeamID() and ent:Alive() and TrueVisible(ent:NearestPoint(pos), pos) then
					GAMEMODE:PlayerHeal(ent, self:GetOwner(), ent:GetMaxHealth())
				end
			end

			local effectdata = EffectData()
				effectdata:SetOrigin(pos)
			util.Effect("healringcomplete", effectdata)
		end
	else
		self:Remove()
	end
end

function ENT:OnRemove()
	local owner = self:GetOwner()
	if owner:IsValid() then
		owner.HealRing = nil
		RestoreSpeed(owner)
	end
end
