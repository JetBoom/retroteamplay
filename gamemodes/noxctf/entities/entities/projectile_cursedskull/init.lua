AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")

include("shared.lua")

util.PrecacheModel( "models/Gibs/HGIBS.mdl" )

function ENT:Initialize()
	self:SetModel("models/Gibs/HGIBS.mdl")
	self:DrawShadow(false)
	self.CounterSpell = COUNTERSPELL_DESTROY
	self.Inversion = INVERSION_DESTROY
	self:PhysicsInitSphere(3)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS_TRIGGER)
	self:SetSolid(SOLID_BBOX)
	self:SetTrigger(true)

	local phys = self:GetPhysicsObject()
	if phys:IsValid() then
		phys:EnableDrag(false)
		phys:EnableGravity(false)
		phys:Wake()
		phys:ApplyForceCenter(vector_up * 300 + VectorRand() * 100)
	end

	self.Target = NULL
end

function ENT:Think()
	if self.Die then self:Remove() return end

	local owner = self:GetOwner()
	
	if not self.Skulls then
		owner:DI(NameToSpell["Cursed Skulls"],-1)
		self.Skulls = true
	end
	
	if owner:IsValid() and owner:Alive() then
		if CLASSES[owner:GetPlayerClass()].Name ~= "Necromancer" then self:Remove() return end
		local entitypos = self:GetPos()
		if self.Target:IsValid() and self.Target.SendLua and self.Target:Alive() and entitypos:Distance(self.Target:GetPos()) < 512 and IsVisible(entitypos, self.Target:NearestPoint(entitypos)) and self.Target:GetManaRegeneration() ~= 0 then
			self:GetPhysicsObject():SetVelocityInstantaneous((self.Target:NearestPoint(entitypos) - entitypos):GetNormal() * 200 + self:GetVelocity() * 0.7)

			if not self.Target:IsVisibleTarget(owner, 20) then
				self.Target = NULL
			end
		else
			local phys = self:GetPhysicsObject()
			
			local ownerpos = owner:GetPos() + Vector(0,0,owner:OBBMaxs().z * 0.5)
			local dist = ownerpos:Distance(entitypos)
			if dist > 562 then
				self:SetPos(ownerpos + VectorRand() * 16)
				phys:SetVelocityInstantaneous(Vector(0, 0, 0))
			else
				local rot = RealTime() * 2
				local offset = Vector(25 * math.cos( rot ), 25 * math.sin( rot ), -25 * math.sin( rot ))
				ownerpos = ownerpos + offset + VectorRand() * 10
				local norm = (ownerpos - entitypos):GetNormal()
				local topos = ownerpos + norm * 24
				phys:SetVelocityInstantaneous((topos - entitypos):GetNormal() * math.min(70, dist) + self:GetVelocity() * 0.8)
			end

			for _, ent in pairs(ents.FindInSphere(ownerpos, 256)) do
				if ent.SendLua and ent:Alive() and ent:Team() ~= owner:Team() and IsVisible(entitypos, ent:NearestPoint(entitypos)) and ent:IsVisibleTarget(owner, 20) then
					self.Target = ent
					break
				end
			end
		end
	else
		self.Die = true
	end
end

function ENT:OnRemove()
	self:GetOwner():DI(NameToSpell["Cursed Skulls"],0)
	for _, ent in pairs(ents.FindByClass("projectile_cursedskull")) do
		if ent:GetOwner() == self:GetOwner() then
			ent.Skulls = false
		end
	end
end

function ENT:PhysicsCollide(data, physobj)
end

function ENT:Touch(ent)
	if self.Die then return end

	local owner = self:GetOwner()
	if not owner:IsValid() then owner = self end

	if ent:IsPlayer() and ent:GetTeamID() ~= self:GetTeamID() and ent:GetManaRegeneration() ~= 0 then
		local mana = math.min(25, ent:GetMana())
		if mana > 0 then
			ent:SetMana(ent:GetMana() - mana, true)
			if owner:IsPlayer() then
				owner:SetMana(math.min(owner:GetMaxMana(), mana + owner:GetMana()), true)
			end
			local effectdata = EffectData()
				effectdata:SetOrigin(self:GetPos())
			util.Effect("cursedskullhit", effectdata)
			self.Die = true
		end
	end
end
