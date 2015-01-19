function EFFECT:Init(data)
	local dir = data:GetNormal()
	local speed = data:GetScale() * 100

	local max = Vector(3,3,3)
	local min = max * -1
	self.Entity:PhysicsInitBox(min,max)
	self.Entity:SetCollisionBounds(min,max) 
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
	end
	self.Living = RealTime() + 1
	self.Emitter = ParticleEmitter(self.Entity:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self.Dir = dir
	self.Speed = speed
	local dum = VectorRand():GetNormal()
	self.Col = Color(dum.x * 255, dum.y * 255, dum.z * 255, 255)
end

function EFFECT:Think()
	local tr = util.TraceLine({start = self.Entity:GetPos(), endpos = self.Entity:GetPos() + self.Entity:GetVelocity():GetNormal() * 16, mask = MASK_NPCWORLDSTATIC})
	if tr.Hit then
		self.Living = -5
	end

	if self.Living < RealTime() then
		local particle = self.Emitter:Add("sprites/glow04_noz", self.Entity:GetPos())
		particle:SetDieTime(1.25)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(48)
		particle:SetEndSize(32)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-14, 14))
		local col = self.Col
		particle:SetColor(col.r, col.g, col.b)
		--self.Emitter:Finish()
		return false
	end

	self.Entity:GetPhysicsObject():SetVelocityInstantaneous((self.Entity:GetVelocity() * 0.75 + self.Speed * 0.25 * VectorRand()):GetNormal() * self.Speed)
	return true
end

function EFFECT:Render()
	local particle = self.Emitter:Add("sprites/glow04_noz", self.Entity:GetPos() + VectorRand() * 4)
	particle:SetDieTime(0.4)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	particle:SetStartSize(8)
	particle:SetEndSize(6.5)
	particle:SetRoll(math.Rand(0, 360))
	local col = self.Col
	particle:SetColor(col.r, col.g, col.b)
end
