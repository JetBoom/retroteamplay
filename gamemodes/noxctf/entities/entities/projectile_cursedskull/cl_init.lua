include('shared.lua')

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 34)
end

function ENT:Think()
	if self.Emitter then
		self.Emitter:SetPos(self:GetPos())
	end
end

function ENT:OnRemove()
	if self.Emitter then
		--self.Emitter:Finish()
	end
end

local matGlow = Material("sprites/light_glow02_add")

function ENT:Draw()

	if not self.CurAngles then
		self.CurAngles = self:GetVelocity():Angle()
	end
	
	self.CurAngles = LerpAngle( FrameTime() * 10, self.CurAngles, self:GetVelocity():Angle() )

	self:SetAngles( self.CurAngles )

	self:DrawModel()

	
	if EFFECT_QUALITY < 2 then return end

	local emitter = self.Emitter
	
	if not emitter then return end
	
	for i=1, EFFECT_QUALITY do
		local particle = emitter:Add( math.random(2) == 2 and "sprites/glow04_noz" or "effects/fire_cloud1", self:GetPos() + VectorRand() * 4)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(2, 8))
		particle:SetLifeTime(1)
		particle:SetDieTime(2)
		particle:SetStartAlpha(150)
		particle:SetEndAlpha(255)
		particle:SetStartSize(math.Rand(2.5, 13))
		particle:SetEndSize(0)
		particle:SetColor(185, 170, 45)
		particle:SetRoll(math.Rand(0, 359))
		//particle:SetRollDelta(math.Rand(-1, 1))
		particle:SetAirResistance(20)
		particle:SetCollide(true)
		particle:SetGravity(vector_up * 100)
	end


	--[[render.SetMaterial(matBeam)
	local pos = self:GetPos()
	local norm = self:GetVelocity():GetNormal()
	local start = pos + norm * 8
	local endpos = pos - norm * 20
	render.DrawBeam(start, endpos, 10, 1, 0, COLOR_YELLOW)
	render.DrawBeam(start, endpos, 6, 1, 0, COLOR_YELLOW)]]

	--[[if EFFECT_QUALITY < 2 then return end

	local emitter = self.Emitter
	for i=1, EFFECT_QUALITY do
		local particle = emitter:Add("sprites/light_glow02_add", vOffset + VectorRand() * 4)
		particle:SetVelocity(VectorRand():GetNormal() * math.Rand(2, 8))
		particle:SetLifeTime(1)
		particle:SetDieTime(2)
		particle:SetStartAlpha(255)
		particle:SetStartSize(math.Rand(3.5, 5))
		particle:SetEndSize(0)
		particle:SetColor(255, 255, 70)
		particle:SetRoll(math.Rand(0, 359))
		particle:SetRollDelta(math.Rand(-2, 2))
		particle:SetAirResistance(30)
		particle:SetCollide(true)
		particle:SetBounce(0.5)
	end]]
end
