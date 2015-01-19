MARKEFFECT = nil

function EFFECT:Init(data)
	local pos = data:GetOrigin()
	local ent = data:GetEntity()

	if ent:IsPlayer() then
		self.Col = team.GetColor(ent:Team())
	else
		self.Col = color_white
	end

	self.Entity:SetRenderBounds(Vector(-256, -256, -256), Vector(256, 256, 256))

	sound.Play("weapons/physcannon/physcannon_charge.wav", pos, 74, 42)

	self.DieTime = CurTime() + data:GetMagnitude()

	self.NextEmit = 0
	self.Rotation = math.Rand(0, 360)

	self.Emitter = ParticleEmitter(pos)
	self.Emitter:SetNearClip(24, 32)

	local tr = util.TraceLine({start=pos, endpos=pos + Vector(0,0,-32), mask = MASK_SOLID_BRUSHONLY})
	if tr.HitWorld then
		self.Pos = tr.HitPos + tr.HitNormal * 4
		self.Norm = tr.HitNormal
	else
		self.Pos = pos
		self.Norm = Vector(0,0,1)
	end
end

function EFFECT:Think()
	if self.DieTime <= CurTime() then
		--self.Emitter:Finish()
		return false
	end

	return true
end

local matGlow = Material("sprites/glow04_noz")
local matWhite = Material("effects/laser1")

function EFFECT:Render()
	local pos = self.Pos

	local qsize = math.min(self.DieTime - CurTime(), 1) * 300
	if 0 < qsize then
		self.Rotation = self.Rotation + FrameTime() * qsize
		if 360 < self.Rotation then self.Rotation = self.Rotation - 360 end

		render.SetMaterial(matWhite)
		render.DrawQuadEasy(self.Pos, self.Norm, qsize * 0.15, qsize, color_white, self.Rotation)
		render.DrawQuadEasy(self.Pos, self.Norm * -1, qsize * 0.15, qsize, color_white, self.Rotation)
		render.DrawQuadEasy(self.Pos, self.Norm, qsize * 0.15, qsize, color_white, self.Rotation + 90)
		render.DrawQuadEasy(self.Pos, self.Norm * -1, qsize * 0.15, qsize, color_white, self.Rotation + 90)

		render.SetMaterial(matGlow)
		render.DrawQuadEasy(self.Pos, self.Norm, qsize, qsize, self.Col)
		render.DrawQuadEasy(self.Pos, self.Norm * -1, qsize, qsize, self.Col)

		if self.NextEmit <= CurTime() then
			local ang = self.Norm:Angle():Right():Angle()
			self.NextEmit = CurTime() + EFFECT_IQUALITY * 0.03
			local c = self.Col
			for i=1, 2 do
				ang:RotateAroundAxis(self.Norm, math.Rand(0, 360))
				local fwd = ang:Forward()
				local particle = self.Emitter:Add("effects/stunstick", pos + fwd * 32)
				particle:SetDieTime(1)
				particle:SetStartAlpha(220)
				particle:SetEndAlpha(0)
				particle:SetStartSize(1)
				particle:SetEndSize(32)
				particle:SetAirResistance(64)
				particle:SetVelocity(fwd * 128)
				particle:SetGravity(Vector(0,0,150))
				particle:SetRoll(math.Rand(0, 360))
				particle:SetRollDelta(math.Rand(-3, 3))
				particle:SetColor(c.r, c.g, c.b)
			end
		end
	end
end
