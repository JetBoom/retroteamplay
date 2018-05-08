function EFFECT:Init(data)
	local Pos = data:GetOrigin()
	Pos.z = Pos.z + 4
	self.TimeLeft = CurTime() + 8.5

	self.Size = 15

	self.vecang = VectorRand()

	self.Position = Pos

	sound.Play("ambient/levels/labs/electric_explosion1.wav", Pos, 99, 85)

	local emitter = ParticleEmitter(Pos)
	self.Emitter = emitter
	for i=1, math.min(math.ceil(Pos:Distance(MySelf:GetShootPos()) * 2), math.random(250, 300)) do
		local heading = VectorRand():GetNormal()
		local particle = emitter:Add("effects/spark", Pos + heading * 8)
		particle:SetVelocity(heading * 500)
		particle:SetDieTime(math.Rand(0.5, 0.85))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(4, 5))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-20, 20))
		particle:SetAirResistance(300)
		particle:SetBounce(0)
		particle:SetCollide(true)
	end

	ExplosiveEffect(Pos, 64, 20, DMGTYPE_LIGHTNING)
end

function EFFECT:Think()
	local Pos = self.Position
	local timeleft = self.TimeLeft - CurTime()
	if timeleft > 0 then 
		local ftime = FrameTime()

		self.Size = self.Size + 1200 * ftime

		if self.Size < 80 then
			local spawndist = self.Size
			local NumPuffs = spawndist / 45

			local ang = self.vecang:Angle()
			for i=1, NumPuffs do
				ang:RotateAroundAxis(ang:Up(), 360 / NumPuffs)
				local newang = ang:Forward()
				local spawnpos = Pos + newang * spawndist
				local particle = self.Emitter:Add("particles/flamelet"..math.random(1,5), spawnpos)
				particle:SetVelocity(Vector(0, 0, 0))
				particle:SetDieTime(2)
				particle:SetStartAlpha(math.Rand(230, 250))
				particle:SetStartSize(20 * math.Rand(4, 6))
				particle:SetEndSize(math.Rand(2, 3))
				particle:SetRoll(math.Rand(20, 80))
				particle:SetRollDelta(math.random(-1, 1))
				particle:SetColor(20, math.random(20,60), math.random(100,255))
			end
			ang:RotateAroundAxis(ang:Forward(), 360 / NumPuffs)
			local newang = ang:Up()
			local spawnpos = Pos + newang * spawndist
			local particle2 = self.Emitter:Add("particles/flamelet"..math.random(1, 5), spawnpos)
			particle2:SetVelocity(Vector(0, 0, 0))
			particle2:SetDieTime(2)
			particle2:SetStartAlpha(math.Rand(230, 250))
			particle2:SetStartSize(20 * math.Rand(4, 6))
			particle2:SetEndSize(math.Rand(2, 3))
			particle2:SetRoll(math.Rand(20, 80))
			particle2:SetRollDelta(math.random(100, 250))
			particle2:SetColor(20, math.random(20,60), math.random(100,255))
		end
		return true
	else
		--self.Emitter:Finish()
		return false
	end
end

function EFFECT:Render()
end
