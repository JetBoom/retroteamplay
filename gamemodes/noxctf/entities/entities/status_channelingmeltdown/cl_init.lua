include("shared.lua")

ENT.NextEffect = 0

function ENT:StatusThink(owner)
	if CurTime() < self.NextEffect then return end
	self.NextEffect = CurTime() + 0.25

	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local pos = owner:LocalToWorld(owner:OBBCenter()) + VectorRand():GetNormal() * math.Rand(0, 250)
	if TrueVisible(pos, owner:NearestPoint(pos)) then
		local effectdata = EffectData()
			effectdata:SetOrigin(pos)
			effectdata:SetNormal(VectorRand():GetNormal())
		util.Effect("rovercannonexplosion", effectdata)
	end
end
