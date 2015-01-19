AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetMass(5)
		phys:Wake()
	end

	self:SetMaterial("models/shiny")

	self.SpawnTime = CurTime()
	self.DeathTime = CurTime() + 30
end

function ENT:Think()
	if CurTime() >= self.DeathTime then
		self:Remove()
	elseif self:WaterLevel() >= 1 or self.ShouldExplode then
		self:Explode()
		self:Remove()
	end

	self:NextThink(CurTime())
	return true
end

function ENT:PhysicsCollide(data, physobj)
	if 20 < data.Speed and 0.2 < data.DeltaTime then
		self:EmitSound("physics/metal/metal_canister_impact_hard"..math.random(1,3)..".wav", 80, math.random(137, 143))
	end

	if CurTime() >= self.SpawnTime + self.AirTime then
		self.ShouldExplode = true
	else
		local normal = data.OurOldVelocity:GetNormal()
		local DotProduct = data.HitNormal:Dot(normal * -1)

		physobj:SetVelocityInstantaneous((2 * DotProduct * data.HitNormal + normal) * data.Speed * 0.75)
	end
end

function ENT:Explode()
	if self.Exploded then return end
	self.Exploded = true

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	ExplosiveDamage(owner, self, 290, 290, 1, 0.48, 8)

	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
	util.Effect("FireBombExplosion", effectdata)

	self.DeathTime = 0
end
