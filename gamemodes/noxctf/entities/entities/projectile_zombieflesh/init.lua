AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self.DieTime = CurTime() + 7

	self:DrawShadow(false)
	self:PhysicsInitSphere(10)
	self:SetSolid(SOLID_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMass(4)
		phys:EnableMotion(true)
		phys:Wake()
	end
end

function ENT:Think()
	if self.DieTime < CurTime() then
		local data = self.HitData
		if data then
			local hitent = data.HitEntity
			if hitent and hitent:IsValid() then
				local owner = self:GetOwner()
				if not owner:IsValid() then owner = self end
				hitent:TakeSpecialDamage(12, DMGTYPE_POISON, owner, self)
				if owner ~= self and hitent.Poison and 0 < hitent:Health() and hitent:Team() ~= owner:Team() then
					hitent:Poison()
				end
			end

			self.HitData = nil
		end

		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	if self.HitData then return end

	self.HitData = data
	self.DieTime = 0

	local effectdata = EffectData()
		effectdata:SetOrigin(data.HitPos)
		effectdata:SetNormal(data.HitNormal)
	util.Effect("zombiefleshhit", effectdata)

	self:NextThink(CurTime())
	return true
end

function ENT:UpdateTransmitState()
	return TRANSMIT_PVS
end
