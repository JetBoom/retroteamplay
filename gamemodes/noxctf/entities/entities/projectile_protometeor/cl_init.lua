include("shared.lua")

local matFire = Material("effects/fire_cloud1")
--local matGlow = Material("sprites/light_glow02_add")
local matGlow = Material("effects/muzzleflash2")
local whiteness = Color(255, 255, 200, 200)
function ENT:Draw()
	local owner = self:GetOwner()
	local col = team.GetColor(owner:GetTeamID()) or color_white

	local vOffset = self:GetPos()

	render.SetMaterial(matGlow)
	render.DrawSprite(vOffset, 125, 125, whiteness)
	render.SetMaterial(matFire)
	render.DrawSprite(vOffset, 125, 125, color_white)

	self:SetModelScale(10, 0)
	render.SetColorModulation(col.r/255, col.g/255, col.b/255)
		self:DrawModel()
	render.SetColorModulation(1, 1, 1)
	
	local emitter = self.Emitter
	local particle = emitter:Add("sprites/flamelet"..math.random(1,4), vOffset)
	particle:SetDieTime(2)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(0)
	particle:SetStartSize(256)
	particle:SetEndSize(5)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-0.8, 0.8))
	particle:SetColor(col.r, col.g, col.b)
	local negvel = self:GetVelocity() * -0.4
	for i=1, math.max(2, EFFECT_QUALITY * 2) do
		particle = emitter:Add("sprites/flamelet"..math.random(1,4), vOffset + VectorRand():GetNormal() * math.Rand(8, self:BoundingRadius() * 1.5))
		particle:SetVelocity(negvel + VectorRand() * 72)
		particle:SetDieTime(2)
		particle:SetStartAlpha(255)
		particle:SetStartSize(math.Rand(16, 24))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.8, 1.8))
	end
end

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self:SetColor(Color(255, 125, 75, 255))
	self:SetMaterial("models/props_wasteland/rockcliff04a")

	self.AmbientSound = CreateSound(self, "ambient/fire/fire_big_loop1.wav")
	self.AmbientSound:Play()
end

function ENT:Think()
	self.AmbientSound:PlayEx(1, 60)
end

function ENT:OnRemove()
	--self.Emitter:Finish()
	self.AmbientSound:Stop()
end
