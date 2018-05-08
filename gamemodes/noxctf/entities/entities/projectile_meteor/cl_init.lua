include("shared.lua")

util.PrecacheSound("weapons/mortar/mortar_shell_incomming1.wav")

ENT.SmokeTimer = 0

function ENT:Initialize()
	self:DrawShadow(false)

	self.Col = team.GetColor(self:GetTeamID()) or color_white
	self:SetMaterial("models/props_wasteland/rockcliff04a")
	self:SetModelScale(2, 0)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(50, 60)
end

function ENT:Think()
	if not self.PlayedSound then
		self.PlayedSound = true
		self:EmitSound("weapons/mortar/mortar_shell_incomming1.wav")
	end
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

local matFire = Material("effects/fire_cloud1")
local matGlow = Material("effects/muzzleflash2")
local whiteness = Color(255, 255, 200, 200)
function ENT:Draw()
	local vOffset = self:GetPos()

	render.SetMaterial(matGlow)
	render.DrawSprite(vOffset, 80, 80, whiteness)
	render.SetMaterial(matFire)
	render.DrawSprite(vOffset, 80, 80, color_white)

	local col = self.Col
	local r,g,b = col.r, col.g, col.b
	render.SetColorModulation(r / 255, g / 255, b / 255)
	self:DrawModel()
	render.SetColorModulation(1, 1, 1)

	if CurTime() < self.SmokeTimer then return end
	self.SmokeTimer = CurTime() + 0.05

	local emitter = self.Emitter
	local particle = emitter:Add("sprites/flamelet"..math.random(1,4), vOffset)
	particle:SetDieTime(1)
	particle:SetStartAlpha(150)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(16, 24))
	particle:SetEndSize(5)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-0.8, 0.8))
	local negvel = self:GetVelocity() * -0.4
	for i=1, math.max(2, EFFECT_QUALITY * 2) do
		particle = emitter:Add("sprites/flamelet"..math.random(1,4), vOffset + VectorRand():GetNormalized() * math.Rand(8, self:BoundingRadius() * 2))
		particle:SetVelocity(negvel + VectorRand() * 72)
		particle:SetDieTime(2)
		particle:SetStartAlpha(255)
		particle:SetStartSize(math.Rand(16, 24))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-1.8, 1.8))
	end
end
