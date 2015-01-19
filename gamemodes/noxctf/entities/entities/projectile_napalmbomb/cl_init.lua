include('shared.lua')

ENT.SmokeTimer = 0
ENT.MaxTraceHUDPaintLength = 110

function ENT:Initialize()
	self:SetMaterial("models/shiny")

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self.AmbientSound = CreateSound(self, "ambient/fire/fire_med_loop1.wav")
	
	self.Col = self:GetOwner():GetPlayerColor() * 100 or color_white
end

function ENT:Think()
	if self.SmokeTimer < CurTime() then
		self.SmokeTimer = CurTime() + 0.05

		local vOffset = self:GetPos()

		local emitter = self.Emitter
		emitter:SetPos(vOffset)
		local particle = emitter:Add("sprites/flamelet"..math.random(1,4), vOffset)
		particle:SetDieTime(1)
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(60)
		particle:SetStartSize(math.Rand(16, 24))
		particle:SetEndSize(5)
		particle:SetRoll(math.Rand(-0.8, 0.8))
		for i=1, 2 do
			particle = emitter:Add("sprites/flamelet"..math.random(1,4), vOffset)
			particle:SetVelocity(self:GetVelocity() * -0.3 + VectorRand() * 100)
			particle:SetDieTime(1)
			particle:SetStartAlpha(150)
			particle:SetEndAlpha(60)
			particle:SetStartSize(math.Rand(14, 20))
			particle:SetEndSize(2)
			particle:SetRoll(math.Rand(-0.8, 0.8))
		end
	end

	self.AmbientSound:PlayEx(0.79, math.max(90, math.min(200, self:GetVelocity():Length() * 0.25)))

	if self.Thought then return end
	self.Thought = true

	self:EmitSound("weapons/flaregun/fire.wav")

	local pos = self:GetPos()
	local emitter = self.Emitter
	for i=1, 5 do
		particle = emitter:Add("sprites/flamelet"..math.random(1,4), pos)
		particle:SetVelocity(self:GetVelocity() * -1 + VectorRand() * 100)
		particle:SetDieTime(1.5)
		particle:SetStartAlpha(220)
		particle:SetEndAlpha(0)
		particle:SetStartSize(32)
		particle:SetEndSize(16)
		particle:SetRoll(math.Rand(-0.8, 0.8))
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end

local matFire = Material("effects/fire_cloud1")
local matGlow = Material("sprites/light_glow02_add")
local whiteness = Color(255, 255, 150, 200)
function ENT:Draw()
	local col = self.Col
	local r,g,b = col.r, col.g, col.b
	render.SetColorModulation(r / 255, g / 255, b / 255)
	render.SuppressEngineLighting(true)
	self:DrawModel()
	render.SuppressEngineLighting(false)
	render.SetColorModulation(1, 1, 1)

	local vOffset = self:GetPos()
	local eyepos = EyePos()
	local normal = (vOffset - eyepos):GetNormal()

	local size = math.Clamp(EyePos():Distance(vOffset) * 0.2, 2, 225)
	local size2 = math.random(16, 100)
	render.SetMaterial(matGlow)
	render.DrawSprite(vOffset, size, size, whiteness)

	render.SetMaterial(matFire)
	render.DrawSprite(vOffset, 36, 36, color_white)
end
