include("shared.lua")

function ENT:DrawOffScreen()
	if self.SmokeTimer > RealTime() then return end
	self.SmokeTimer = RealTime() + 0.075 * math.max(1, EFFECT_IQUALITY)

	local vOffset = self:GetPos()

	local emitter = self.Emitter
	emitter:SetPos(vOffset)
	local c = self:GetColor()
	c.r = c.r * 0.5
	c.g = c.g * 0.5
	c.b = c.b * 0.5
	if self:GetSkin() == 1 then
		for i=0, EFFECT_QUALITY * 2.5 do
			local particle = emitter:Add("effects/yellowflare", vOffset + VectorRand():GetNormal() * math.Rand(16, 48))
			particle:SetDieTime(0.5)
			particle:SetStartAlpha(250)
			particle:SetEndAlpha(60)
			particle:SetStartSize(math.max(1, EFFECT_IQUALITY) * math.Rand(48, 64))
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-45, 45))

			local particle = emitter:Add("particles/smokey", vOffset + VectorRand():GetNormal() * math.Rand(16, 48))
			particle:SetDieTime(math.Rand(1.75, 2.75))
			particle:SetStartAlpha(math.Rand(150, 230))
			particle:SetEndAlpha(10)
			particle:SetStartSize(2)
			particle:SetEndSize(math.max(1, EFFECT_IQUALITY) * math.Rand(40, 64))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-12, 12))
			particle:SetColor(c.r * 0.5, c.g * 0.5, c.b * 0.5)
		end
	else
		for i=0, EFFECT_QUALITY * 3 do
			local particle = emitter:Add("sprites/flamelet"..math.random(1,4), vOffset + VectorRand():GetNormal() * math.Rand(16, 48))
			particle:SetDieTime(0.5)
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(60)
			particle:SetStartSize(math.max(1, EFFECT_IQUALITY) * math.Rand(16, 32))
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-15, 15))

			local particle = emitter:Add("particles/smokey", vOffset + VectorRand():GetNormal() * math.Rand(16, 48))
			particle:SetDieTime(math.Rand(1.75, 2.75))
			particle:SetStartAlpha(math.Rand(150, 230))
			particle:SetEndAlpha(10)
			particle:SetStartSize(2)
			particle:SetEndSize(math.max(1, EFFECT_IQUALITY) * math.Rand(40, 64))
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-7, 7))
			particle:SetColor(c.r, c.g, c.b, 255)
		end
	end
end

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 48)
	self.SmokeTimer = 0
	self:SetMaterial("models/antlion/antlion_innards")
	self.AmbientSound = CreateSound(self, "Missile.Ignite")
	self.AmbientSound:Play()
end

function ENT:Think()
	self:DrawOffScreen()
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

local matFire = Material("effects/fire_cloud1")
local matGlow = Material("sprites/glow04_noz")
local matBeam = Material("Effects/laser1")
function ENT:DrawTranslucent()
	local vOffset = self:GetPos()

	--local vXScale = self:GetVelocity():Length()
	--self:SetModelScale(self:GetVelocity():GetNormal() * self:GetForward())
	--self:SetAngles(self:GetVelocity():Angle())
	self:DrawModel()

	render.SetMaterial(matFire)
	render.DrawSprite(vOffset, 72, 72, color_white)

	if self:GetSkin() == 1 then
		render.SetMaterial(matGlow)
		local realtime = RealTime() * 4
		render.DrawSprite(vOffset, math.cos(realtime) * 100 + 300, math.sin(realtime) * 100 + 300, COLOR_CYAN)
		render.DrawSprite(vOffset, math.sin(realtime) * 100 + 300, math.cos(realtime) * 100 + 300, color_white)
		render.DrawSprite(vOffset, 350 + math.Rand(-128, 128), 350 + math.Rand(-128, 128), color_white)

		for i=1, math.max(10, EFFECT_QUALITY * 4) do
			local dir = VectorRand():GetNormal()

			render.SetMaterial(matBeam)
			render.StartBeam(14)
			local bpos = vOffset + dir * 9
			for x=1, 14 do
				render.AddBeam(bpos, 128 - x * 5, x, Color(100, 200, 255, 255 - x * 8))
				dir:Rotate(Angle(math.Rand(-20, 20), math.Rand(-20, 20), 0))
				bpos = bpos + dir * 22
			end
			render.EndBeam()
		end
	end
end
