AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self:DrawShadow(false)
	self.DeathTime = CurTime() + 30
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:SetBuoyancyRatio(0.05)
		phys:Wake()
	end

	self:EmitSound("nox/arrow_flying0"..math.random(1,2)..".ogg")
end

function ENT:Think()
	if self.PhysicsData then
		self:Hit(self.PhysicsData.HitPos, self.PhysicsData.HitNormal, self.PhysicsData.HitEntity)
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:Hit(hitpos, hitnormal, hitentity)
	if self.Exploded then return end
	self.Exploded = true

	hitpos = hitpos or self:GetPos()
	hitnormal = hitnormal or Vector(0, 0, 1)
	hitentity = hitentity or NULL

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	if hitentity:IsValid() then
		self.DeathTime = 0

		hitentity:EmitSound("weapons/crossbow/hitbod"..math.random(1,2)..".wav")
		local stuntime = 2 + math.Remap(self.AttackStrength, 0.5, 1, 0, 3)

		if hitentity:IsPlayer() and hitentity:Team() ~= self:GetTeamID() then
			hitentity:RemoveInvisibility()
			--hitentity:RemoveAllStatus(false, true)
			hitentity:RemoveStatus("*", false, true, "weapon_")
			hitentity:ManaStun(stuntime)
		end

		self:NextThink(CurTime())
	else
		self:EmitSound("physics/metal/sawblade_stick"..math.random(1,3)..".wav")
		local phys = self:GetPhysicsObject()
		if phys:IsValid() then
			phys:EnableMotion(false)
			phys:EnableCollisions(false)
		end
		self.DeathTime = CurTime() + 5
	end

	local effectdata = EffectData()
		effectdata:SetOrigin(hitpos)
		effectdata:SetStart(hitpos + hitnormal * 8)
	util.Effect("gunmage_silverbullet", effectdata)

	CounterSpellEffect(owner, hitpos, 256)
end

function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
