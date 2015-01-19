function EFFECT:Init(data)
	local dir = data:GetNormal()
	local speed = data:GetScale() * 100

	local max = Vector(3, 3, 3)
	local min = max * -1
	self.Entity:PhysicsInitBox(min, max)
	self.Entity:SetCollisionBounds(min, max) 
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:Wake()
		phys:ApplyForceCenter(dir * math.random(speed * 0.25, speed))
	end
	self.Living = CurTime() + 4

	self.NextSmoke = 0
end

function EFFECT:Think()
	local tr = util.TraceLine({start = self.Entity:GetPos(), endpos = self.Entity:GetPos() + self.Entity:GetVelocity():GetNormal() * 16, mask = MASK_NPCWORLDSTATIC})
	if tr.Hit then
		self.Living = -5
	end

	if self.Living < CurTime() then
		local pos = self.Entity:GetPos()

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)

		local particle = emitter:Add("effects/fire_cloud1", pos)
		particle:SetDieTime(1.1)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(20)
		particle:SetStartSize(90)
		particle:SetEndSize(2)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1, 1))

		emitter:Finish()

		return false
	end

	return true
end

local matFire = Material("effects/fire_cloud1")

function EFFECT:Render()
	render.SetMaterial(matFire)
	local pos = self.Entity:GetPos()
	render.DrawSprite(pos, 90, 90, color_white)

	if CurTime() < self.NextSmoke then return end
	self.NextSmoke = CurTime() + math.max(0.03, EFFECT_IQUALITY * 0.05)

	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(24, 32)

	local particle = emitter:Add("particles/smokey", pos + VectorRand() * 8)
	particle:SetVelocity(VectorRand():GetNormal() * math.Rand(8, 48))
	particle:SetDieTime(math.Rand(0.9, 1.1))
	particle:SetStartAlpha(180)
	particle:SetEndAlpha(0)
	particle:SetStartSize(1)
	particle:SetEndSize(48)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-3, 3))
	particle:SetColor(20, 20, 20)

	emitter:Finish()
end
