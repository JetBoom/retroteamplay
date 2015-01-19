AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:DrawShadow(false)
	self:PhysicsInitSphere(2)
	self:SetMoveType(MOVETYPE_VPHYSICS)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self:Fire("kill", "", 10)
end

function ENT:Think()
	if self:WaterLevel() > 0 then
		self:Remove()
	elseif self.ShouldExplode then
		self:Explode()
	else
		for _, ent in pairs(ents.FindInSphere(self:GetPos(), 150)) do
			local parent = ent:GetVehicleParent()
			if parent:IsValid() then ent = parent end

			if ent.ScriptVehicle and ent:GetTeamID() ~= self:GetTeamID() then
				self.ShouldExplode = true
				self:NextThink(CurTime() + 0.1)
				return true
			end
		end

		self:NextThink(CurTime())
		return true
	end
end

function ENT:PhysicsCollide(data, phys)
	self:EmitSound("physics/metal/metal_sheet_impact_bullet1.wav", 75, math.random(85, 115))
	self:Fire("kill", "", 0.01)
end

function ENT:Explode(hitpos, normal)
	if self.Exploded then return end
	self.Exploded = true

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	ExplosiveDamage(owner, hitpos, 200, 200, 1, 0.25, 1, self)

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetNormal(hitnormal)
	util.Effect("explosionexplosion", effectdata)

	self:Remove()
end
