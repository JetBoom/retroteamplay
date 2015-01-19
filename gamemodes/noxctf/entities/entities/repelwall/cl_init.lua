include("shared.lua")

function ENT:Draw()
end

local matGlow = "sprites/glow04_noz"
function ENT:Initialize()
	-- abandon all hope ye who read this code

	self:DrawShadow(false)
	self.Col = team.GetColor(self:GetSkin()) or color_white
	self.AmbientSound = CreateSound(self, "ambient/levels/labs/machine_ring_resonance_loop1.wav")
	
	local topright = self:GetPos() + self:GetAngles():Right() * 127.5 + Vector(0, 0, 60)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	
	local amount = 10
	
	local ang = self:GetAngles()
	local c = self.Col
	
	-- spawn effect
	for i = 1, amount do
		local particle = self.Emitter:Add(matGlow, self:GetPos())
		particle:SetDieTime(self.LifeTime/7)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(100)
		particle:SetEndSize(0)
		particle:SetVelocity(ang:Forward() * 750)
		particle:SetColor(c.r, c.g, c.b)
		
		ang:RotateAroundAxis(ang:Up(), 360 / amount)
	end

	local ang = self:GetAngles()
	local left = ang:Right() * -25.5
	local down = Vector(0, 0, -25) / 2
	local vertmax = 9
	local hormax = 19
	
	-- right border
	local pos = topright
	for i = 1, vertmax do
		local particle = self.Emitter:Add(matGlow, pos)
		particle:SetDieTime(self.LifeTime)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(220)
		particle:SetStartSize(33)
		particle:SetEndSize(33)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(c.r, c.g, c.b)
		
		pos = pos + down
	end
	
	-- top border
	local pos = topright + left/2
	for i = 1, hormax do
		local particle = self.Emitter:Add(matGlow, pos)
		particle:SetDieTime(self.LifeTime)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(220)
		particle:SetStartSize(33)
		particle:SetEndSize(33)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(c.r, c.g, c.b)
		
		pos = pos + left/2
	end
	
	-- left border
	local pos = topright + left * 10
	for i = 1, vertmax do
		local particle = self.Emitter:Add(matGlow, pos)
		particle:SetDieTime(self.LifeTime)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(220)
		particle:SetStartSize(33)
		particle:SetEndSize(33)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(c.r, c.g, c.b)
		
		pos = pos + down
	end
	
	-- bottom border
	local pos = topright + down * (vertmax - 1) + left/2
	for i = 1, hormax do
		local particle = self.Emitter:Add(matGlow, pos)
		particle:SetDieTime(self.LifeTime)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(220)
		particle:SetStartSize(33)
		particle:SetEndSize(33)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-3, 3))
		particle:SetColor(c.r, c.g, c.b)
		
		pos = pos + left/2
	end
	
	-- draw horizontal brick lines
	local pos = topright + down * 2 + left/4
	for i = 1, 3 do
		for j = 1, hormax * 2 do
			local particle = self.Emitter:Add(matGlow, pos)
			particle:SetDieTime(self.LifeTime)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(220)
			particle:SetStartSize(16.5)
			particle:SetEndSize(16.5)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetColor(c.r, c.g, c.b)
			
			if j < hormax * 2 then
				pos = pos + left/3.9
			else
				pos = topright + down * 2 + left/4
			end
		end
		
		pos = pos + down * i * 2
	end
	
	-- draw vertical lines first row
	local pos = topright + down/4 + left*2
	for i = 1, 4 do
		for j = 1, 4 do
			local particle = self.Emitter:Add(matGlow, pos)
			particle:SetDieTime(self.LifeTime)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(220)
			particle:SetStartSize(16.5)
			particle:SetEndSize(16.5)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetColor(c.r, c.g, c.b)
			
			pos = pos + down/2
		end
		pos = topright + down/4 + left * 2 * (i + 1)
	end
	
	-- second row
	local pos = topright + down/4 + left + down*2
	for i = 1, 5 do
		for j = 1, 4 do
			local particle = self.Emitter:Add(matGlow, pos)
			particle:SetDieTime(self.LifeTime)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(220)
			particle:SetStartSize(16.5)
			particle:SetEndSize(16.5)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetColor(c.r, c.g, c.b)
			
			pos = pos + down/2
		end
		pos = topright + down/4 + left * 2 * (i + 1) + down*2 - left
	end
	
	-- third row
	local pos = topright + down/4 + left*2 + down*4
	for i = 1, 4 do
		for j = 1, 4 do
			local particle = self.Emitter:Add(matGlow, pos)
			particle:SetDieTime(self.LifeTime)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(220)
			particle:SetStartSize(16.5)
			particle:SetEndSize(16.5)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetColor(c.r, c.g, c.b)
			
			pos = pos + down/2
		end
		pos = topright + down/4 + left * 2 * (i + 1) + down*4
	end
	
	-- fourth row
	local pos = topright + down/4 + left*2 + down*6 - left
	for i = 1, 5 do
		for j = 1, 4 do
			local particle = self.Emitter:Add(matGlow, pos)
			particle:SetDieTime(self.LifeTime)
			particle:SetStartAlpha(220)
			particle:SetEndAlpha(220)
			particle:SetStartSize(16.5)
			particle:SetEndSize(16.5)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-3, 3))
			particle:SetColor(c.r, c.g, c.b)

			pos = pos + down/2
		end
		pos = topright + down/4 + left * 2 * (i + 1) + down*6 - left
	end
end

function ENT:Think()
	self.AmbientSound:PlayEx(1, 60)
	
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end
