function EFFECT:Init(data)
	if EFFECT_QUALITY < 1 then
		self.Owner = NULL
		self.Death = 0
	else
		self.Owner = data:GetEntity()
		self.Death = RealTime() + 10
		self:SetRenderBounds(Vector(-128,-128,-128), Vector(128, 128, 128))
	end

	self.Threshold = 0
end

function EFFECT:Think()
	local ent = self.Owner

	if not (RealTime() < self.Death and ent and IsValid(ent) and not ent:Alive()) then
		self.Threshold = self.Threshold + FrameTime()
		return self.Threshold < 1
	end

	if IsValid(ent) then
		ent = ent:GetRagdollEntity()
	else
		self.Threshold = self.Threshold + FrameTime()
		return self.Threshold < 1
	end

	if ent then
		ent.Burnt = true
		self.Entity:SetPos(ent:GetPos())
		self.DoDraw = true
		self.Ent = ent
		local c = ent:GetColor()
		c.r = math.max(20, c.r - FrameTime() * 200)
		ent:SetColor(Color(c.r, c.r, c.r, c.a))
	else
		self.Threshold = self.Threshold + FrameTime()
		return self.Threshold < 1
	end

	return true
end

function EFFECT:Render()
	if self.DoDraw and IsValid(self.Ent) then
		self.DoDraw = false
		local ent = self.Ent

		local emitter = ParticleEmitter(ent:GetPos())
		emitter:SetNearClip(32, 48)

		for i=1, ent:GetPhysicsObjectCount() do
			if math.random(0, EFFECT_IQUALITY) == 0 then
				local phys = ent:GetPhysicsObjectNum(i)
				if phys and IsValid(phys) then
					if math.random(1, 5) > 1 then
						local particle = emitter:Add("effects/fire_embers"..math.random(1, 3), phys:GetPos())
						particle:SetDieTime(math.Rand(0.4, 0.6))
						particle:SetVelocity(VectorRand():GetNormal() * math.Rand(-12, 12) + Vector(0, 0, 12))
						particle:SetStartAlpha(200)
						particle:SetEndAlpha(60)
						particle:SetStartSize(math.Rand(8, 16))
						particle:SetEndSize(2)
						particle:SetRoll(math.Rand(0, 359))
						particle:SetRollDelta(math.Rand(-2, 2))
					else
						local particle = emitter:Add("particles/smokey", phys:GetPos())
						particle:SetDieTime(math.Rand(0.6, 1.0))
						particle:SetVelocity(VectorRand():GetNormal() * math.Rand(-12, 12))
						particle:SetGravity(Vector(0, 0, math.Rand(24, 32)))
						particle:SetColor(20, 20, 20)
						particle:SetStartAlpha(130)
						particle:SetEndAlpha(1)
						particle:SetStartSize(2)
						particle:SetEndSize(math.Rand(12, 17))
						particle:SetRoll(math.Rand(0, 359))
						particle:SetRollDelta(math.Rand(-2, 2))
					end
				end
			end
		end

		emitter:Finish()
	end
end
