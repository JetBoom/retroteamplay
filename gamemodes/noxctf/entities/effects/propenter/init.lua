util.PrecacheSound("npc/dog/dog_playfull4.wav")
util.PrecacheSound("npc/dog/dog_playfull5.wav")

function EFFECT:Init(data)
	local target = data:GetEntity()
	self.Target = target

	if not target:IsValid() then
		return
	end

	local pos = target:GetPos()

	self.Entity:SetPos(pos)
	self.Alpha = 0.01
	
	local c = self.Target:GetColor()
	self.Target:SetColor(Color(c.r, c.g, c.b, self.Alpha * 188))

	sound.Play("npc/dog/dog_playfull"..math.random(4, 5)..".wav", pos, 85, math.random(88, 112))
end

function EFFECT:Think()
	if not self.Target:IsValid() then return false end

	local frametime = FrameTime() * 2

	if self.Invert then
		self.Alpha = self.Alpha + frametime * 0.8

		local scale = 1.35 - self.Alpha
		local c = self.Target:GetColor()
		
		self.Target:SetColor(Color(c.r, c.g, c.b, self.Alpha * 188))

		if self.Alpha >= 0.35 then
			self.Target:SetModelScale(1, 0)
			self.Target:SetColor(Color(c.r, c.g, c.b, 60))
			return false
		else
			self.Target:SetModelScale(scale, 0)
		end
	else
		self.Alpha = self.Alpha + frametime
		local scale = self.Alpha + 0.35
		local c = self.Target:GetColor()

		self.Target:SetModelScale(scale, 0)
		self.Target:SetColor(Color(c.r, c.g, c.b, self.Alpha * 188))

		if self.Alpha > 1 then
			self.Invert = true
			self.Alpha = 0
		end
	end
	
	return true
end

function EFFECT:Render()
end
