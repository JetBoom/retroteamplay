include("shared.lua")
AddCSLuaFile("shared.lua")
AddCSLuaFile("cl_init.lua")

function ENT:Initialize()
	self.PoisonCounter = {}

	self.DeathTime = CurTime() + 6
	self:SetStartTime(CurTime() + 1)

	self:DrawShadow(false)
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
		return
	end

	if CurTime() < self:GetStartTime() then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	local pos = self:GetPos()
	for _, ent in pairs(ents.FindInBox(pos + Vector(-230, -230, -2000), pos + Vector(230, 230, 0))) do
		if ent:IsValid() and ent:IsPlayer() and ent:Alive() and (ent:Team() ~= owner:Team() or ent == owner) and TrueVisible(pos, ent:NearestPoint(pos)) then
			self.PoisonCounter[ent] = (self.PoisonCounter[ent] or 0) + 1
			if self.PoisonCounter[ent] == 12 then
				ent:Poison(5)
			end

			ent:TakeSpecialDamage(3, DMGTYPE_POISON, owner, self)
			ent:EmitSound("player/pl_pain"..math.random(5, 7)..".wav")
		end
	end
	
	self:NextThink(CurTime() + 0.2) 
	return true
end
