AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

function ENT:Initialize()
	self:SetModel("models/Items/combine_rifle_ammo01.mdl")
	self:PhysicsInitSphere(4)
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:SetSolid(SOLID_VPHYSICS)
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
	self:SetTrigger(true)
	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
	end

	self.CounterSpell = COUNTERSPELL_DESTROY
	self.Inversion = INVERSION_CUSTOM
	self.EffectType = self.EffectType or "Anchor"
	self.DeathTime = CurTime() + 5
	self.SpawnTime = CurTime() + 0.3
	self.Target = self.Target or NULL
end

function ENT:Think()
	if self.DeathTime <= CurTime() then
		self:Remove()
		return
	end

	if not self.Trailed then
		self.Trailed = true
		if self.Friendly then
			util.SpriteTrail(self, 0, Color(100, 200, 255, 255), false, 12, 12, 1, 0.023, "trails/laser.vmt")
		else
			util.SpriteTrail(self, 0, Color(255, 200, 100, 255), false, 12, 12, 1, 0.023, "trails/laser.vmt")
		end
	end

	local target = self.Target
	local owner = self:GetOwner()
	if owner:IsPlayer() then
		local mypos = self:GetPos()
		if target:IsValid() and target:Alive() and not target:InVehicle() and target:EyePos():Distance(mypos) < 550 and IsVisible(mypos, target:EyePos()) then
			self:GetPhysicsObject():SetVelocityInstantaneous((target:EyePos() - mypos):GetNormal() * 300 + self:GetVelocity() * 0.7)
		else
			local myteam = owner:Team()
			for _, ent in pairs(ents.FindInSphere(mypos, 400)) do
				if ent:IsPlayer() and ent:Alive() and not ent:InVehicle() and IsVisible(mypos, ent:EyePos()) then
					if self.Friendly then
						if ent:Team() == myteam and ent ~= owner and ent:IsVisibleTarget(owner) then
							self.Target = ent
							self.DeathTime = CurTime() + 4
							break
						end
					elseif ent:Team() ~= myteam and ent:IsVisibleTarget(owner) then
						self.Target = ent
						self.DeathTime = CurTime() + 4
						break
					end
				end
			end
			self:NextThink(CurTime() + 0.25)
			return true
		end
	end
end

function ENT:PhysicsCollide(data, physobj)
	physobj:SetVelocityInstantaneous(physobj:GetVelocity():GetNormal() * data.OurOldVelocity:Length())
end

function ENT:Inverted(pl)
	if self.Touched then return end

	self.Target = self:GetOwner()
	self:SetOwner(pl)
	local effectdata = EffectData()
		effectdata:SetOrigin(self:GetPos())
		effectdata:SetNormal((self:GetPos() - pl:EyePos()):GetNormal())
	util.Effect("inversion", effectdata)
	self:GetPhysicsObject():SetVelocityInstantaneous(self:GetVelocity() * -1)
	self:SetTeamID(pl:Team())
	self.DeathTime = CurTime() + 4
end

function ENT:Touch(ent)
	if self.Touched then return end

	if ent:IsPlayer() and ent ~= self:GetOwner() then
		if self.Friendly and ent:GetTeamID() == self:GetTeamID() then
			self.DeathTime = 0
			if GenericHit[self.EffectType] then
				GenericHit[self.EffectType](ent, self)
			end
			self.Touched = true
		elseif not self.Friendly and ent:Team() ~= self:GetTeamID() then
			self.DeathTime = 0
			if GenericHit[self.EffectType] then
				GenericHit[self.EffectType](ent, self)
			end
			self.Touched = true
		end
	end
end

function ENT:Explode()
	self.DeathTime = 0
end
