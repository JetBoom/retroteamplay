local matGlow = Material("sprites/light_glow02_add")

util.PrecacheSound("npc/scanner/scanner_alert1.wav")

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	self.Pos = pos
	self.EndPos = data:GetStart()
	self.Team = data:GetScale()
	self.Acceleration = self.EndPos:Distance(self.Pos) * 0.5
	self.Rotation = 0
	self.StartTime = RealTime() + 1.5
	self.Color = team.GetColor(self.Team)

	if not self.Color then self.Color = Color(255, 255, 255, 255) end
end

function EFFECT:Think()
	if RealTime() > self.StartTime then
		if not self.PlaySound then
			sound.Play("npc/scanner/scanner_alert1.wav", self.Pos, 100, 120)
			self.PlaySound = true
		end
		self.Pos = self.Pos + (self.EndPos - self.Pos):GetNormal() * self.Acceleration * FrameTime()
		self.Acceleration = math.max(32, self.Acceleration - FrameTime() * 50)
	else
		self.Pos = self.Pos + Vector(0,0,FrameTime() * 180 * (self.StartTime - RealTime()))
	end
	self.Entity:SetPos(MySelf:GetShootPos() + MySelf:GetAimVector() * 12)
	return self.Pos:Distance(self.EndPos) >= 12
end

function EFFECT:Render()
	self.Rotation = self.Rotation + FrameTime() * self.Acceleration * 0.025
	if self.Rotation > 360 then self.Rotation = 0 end
	render.SetMaterial(matGlow)
	local vOffset = Vector(16 * math.sin(self.Rotation), 16 * math.cos(self.Rotation), 0)
	local vOffset2 = Vector(0, 16 * math.cos(self.Rotation), 16 * math.sin(self.Rotation))
	local vOffset3 = Vector(16 * math.cos(self.Rotation), 0, 16 * math.sin(self.Rotation))
	render.SetMaterial(matGlow)
	local size =  math.sin(RealTime()*5)*60 + 90
	local minisize = size * 0.5
	render.DrawSprite(self.Pos, size, size, self.Color)
	render.DrawSprite(self.Pos + vOffset, minisize, minisize, self.Color)
	render.DrawSprite(self.Pos + vOffset2, minisize, minisize, self.Color)
	render.DrawSprite(self.Pos + vOffset3, minisize, minisize, self.Color)
	local emitter = ParticleEmitter(self.Pos)
		for i=1, 2 do
			local particle = emitter:Add("sprites/light_glow02_add", self.Pos + vOffset)
			particle:SetVelocity(Vector())
			particle:SetDieTime(1)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(50)
			particle:SetStartSize(14)
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(-0.8, 0.8))
			particle:SetColor(self.Color.r, self.Color.g, self.Color.b)

			particle = emitter:Add("sprites/light_glow02_add", self.Pos + vOffset2)
			particle:SetVelocity(Vector())
			particle:SetDieTime(1)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(50)
			particle:SetStartSize(14)
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(-0.8, 0.8))
			particle:SetColor(self.Color.r, self.Color.g, self.Color.b)

			particle = emitter:Add("sprites/light_glow02_add", self.Pos + vOffset3)
			particle:SetVelocity(Vector())
			particle:SetDieTime(1)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(50)
			particle:SetStartSize(14)
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(-0.8, 0.8))
			particle:SetColor(self.Color.r, self.Color.g, self.Color.b)
		end
	emitter:Finish()
end
