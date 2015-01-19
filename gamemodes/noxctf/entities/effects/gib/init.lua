function EFFECT:Init(data)
	local bTypePlayer = data:GetEntity()
	if not bTypePlayer:IsValid() then self.DeathTime = 0 return end

	self.NextEmit = 0

	local modelid = data:GetMagnitude()

	self.Entity:SetModel(GAMEMODE.GibModels[modelid])

	--self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:PhysicsInitBox(Vector(-2, -2, -2), Vector(2, 2, 2))
	self.Entity:SetCollisionGroup(COLLISION_GROUP_DEBRIS)
	self.Entity:SetCollisionBounds(Vector(-2, -2, -2), Vector(2, 2, 2))
	if modelid > 4 then
		self.Entity:SetMaterial("models/flesh")
	end

	local phys = self.Entity:GetPhysicsObject()
	if phys:IsValid() then
		phys:SetMaterial("zombieflesh")
		phys:Wake()
		--phys:SetAngle(Angle(math.Rand(0,360), math.Rand(0,360), math.Rand(0,360)))
		phys:SetVelocityInstantaneous(VectorRand() * math.Rand(200, 300) + Vector(math.Rand(5, 15), math.Rand(5, 15), 300))
	end

	self.Effects = data:GetScale()
	
	self.Time = math.Rand(5, 10)
	self.DeathTime = CurTime() + 15
end

function EFFECT:Think()
	return CurTime() <= self.DeathTime
end

function EFFECT:Render()
	self.Entity:DrawModel()

	if EFFECT_QUALITY < 1 or CurTime() < self.NextEmit then return end
	self.NextEmit = CurTime() + 0.06 * EFFECT_IQUALITY

	local vel = self.Entity:GetVelocity():Length()

	if 20 < vel or self.Effects == DMGTYPE_FIRE then
		local pos = self.Entity:GetPos()

		local emitter = ParticleEmitter(pos)
		emitter:SetNearClip(24, 32)

		if vel > 20 then
			local particle = emitter:Add("noxctf/sprite_bloodspray"..math.random(8), pos)
			particle:SetVelocity(VectorRand() * 16)
			particle:SetDieTime(0.6)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
			particle:SetStartSize(18)
			particle:SetEndSize(8)
			particle:SetRoll(180)
			particle:SetColor(255, 0, 0)
			particle:SetLighting(true)
		end

		if self.Effects == DMGTYPE_FIRE then
			local particle = emitter:Add("effects/fire_embers"..math.random(3), pos)
			particle:SetDieTime(0.5)
			particle:SetVelocity(VectorRand():GetNormal() * math.Rand(-8, 8) + Vector(0,0,8))
			particle:SetStartAlpha(200)
			particle:SetEndAlpha(60)
			particle:SetStartSize(math.Rand(8, 16))
			particle:SetEndSize(8)
			particle:SetRoll(math.random(0, 360))
		end

		emitter:Finish()
	end
end
