AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include('shared.lua')

function ENT:Initialize()
	self:SetModel("models/Items/CrossbowRounds.mdl")
	self:PhysicsInit(SOLID_VPHYSICS)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:Wake()
	end

	self.DeathTime = CurTime() + 30

	self:EmitSound("nox/arrow_flying0"..math.random(1, 2)..".ogg")
end

function ENT:Think()
	if self.PhysicsData and not self.Hit then
		self.Hit = true

		local data = self.PhysicsData
		self.PhysicsData = nil

		local ent = data.HitEntity
		if ent:IsValid() then
			self.DeathTime = 0

			local owner = self:GetOwner()
			if not owner:IsValid() then owner = self end

			local damage = self.Damage
			if ent:IsPlayer() then
				ent:BloodSpray(data.HitPos, math.random(5, 7), data.OurOldVelocity:GetNormal(), 125)
				damage = math.min(damage, ent:Health())

				if owner:IsPlayer() and owner:Alive() and ent:Team() ~= owner:Team() then
					local manaleech = math.min(damage, ent:GetMana())
					if 0 < manaleech then
						local effectdata = EffectData()
							effectdata:SetOrigin(owner:LocalToWorld(owner:OBBCenter()))
							effectdata:SetEntity(ent)
							effectdata:SetMagnitude(0)
						util.Effect("drainmana", effectdata)

						owner:SetMana(math.min(owner:GetMaxMana(), manaleech + owner:GetMana()), true)
						ent:SetMana(ent:GetMana() - manaleech, true)
					end
				end
			end

			ent:TakeSpecialDamage(damage, DMGTYPE_PIERCING, owner, self)
		else
			self:EmitSound("physics/metal/sawblade_stick"..math.random(1, 3)..".wav")
			local phys = self:GetPhysicsObject()
			if phys:IsValid() then
				phys:EnableMotion(false)
				phys:EnableCollisions(false)
			end
			self.DeathTime = CurTime() + 5
		end
	end

	if self.DeathTime <= CurTime() then
		self:Remove()
	end
end

function ENT:PhysicsCollide(data, phys)
	self.PhysicsData = data
	self:NextThink(CurTime())
end
