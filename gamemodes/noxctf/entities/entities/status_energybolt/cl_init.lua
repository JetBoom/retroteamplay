include("shared.lua")

ENT.NextEmit = 0
ENT.NextBoltSound = 0

function ENT:StatusInitialize()
	self:SetRenderBounds(Vector(-64, -64, -16), Vector(64, 64, 72))

	local pos = self:GetPos()
	local emitter = ParticleEmitter(pos)
	emitter:SetNearClip(16, 24)
	self.Emitter = emitter

	for i=1, 40 do
		local vel = VectorRand():GetNormal() * 64
		vel.z = math.Rand(200, 400)
		local particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand():GetNormal() * 16)
		particle:SetVelocity(vel)
		particle:SetDieTime(math.Rand(1.5, 2))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(200)
		particle:SetStartSize(math.Rand(12, 15))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.8, 0.8))
		particle:SetColor(255, 255, 20)
		particle:SetCollide(true)
		particle:SetBounce(0.8)
		particle:SetGravity(Vector(0,0,-600))
		particle:SetAirResistance(40)

		local heading = VectorRand()
		heading.z = 0
		heading = heading:GetNormal()
		local particle = emitter:Add("sprites/light_glow02_add", pos)
		particle:SetVelocity(heading * math.Rand(16, 64))
		particle:SetDieTime(math.Rand(1, 1.5))
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(200)
		particle:SetStartSize(math.Rand(12, 15))
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-0.8, 0.8))
		particle:SetColor(255, 255, 20)
		particle:SetCollide(true)
		particle:SetBounce(0.8)
		particle:SetAirResistance(10)
	end

	hook.Add("TranslateActivity", self, self.TranslateActivity)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())

	local target = self:GetTarget()
	if target:IsValid() and owner:IsValid() then
		local startpos = self:GetStartPos()
		self:SetRenderBoundsWS(startpos, target:NearestPoint(startpos))
	else
		self:SetRenderBounds(Vector(-64, -64, -16), Vector(64, 64, 72))
	end
end

local matBolt = Material("Effects/laser1")
local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local fCurTime = CurTime()

	local target = self:GetTarget()
	if target:IsValid() then
		local startpos = self:GetStartPos()
		local targetpos = target:NearestPoint(startpos)
		local dir = (targetpos - startpos):GetNormal()

		local beampos = {}

		local pos
		for i=1, math.ceil(startpos:Distance(targetpos) / 40) do
			if pos then
				pos = pos + dir * 40 + VectorRand():GetNormal() * math.Rand(-8, 8)
			else
				pos = startpos
			end

			table.insert(beampos, pos)
		end

		if fCurTime >= self.NextBoltSound then
			self.NextBoltSound = fCurTime + 0.45
			target:EmitSound("nox/energybolt.ogg", 80, math.Rand(95, 105))
		end

		if not beampos[1] then return end

		render.SetMaterial(matBolt)
		local scroll = fCurTime * 20
		render.StartBeam(#beampos + 1)
		for i, pos in ipairs(beampos) do
			render.AddBeam(pos, math.sin((fCurTime + i * 0.2) * 5) * 8 + 16, scroll, COLOR_YELLOW)
		end
		render.AddBeam(targetpos, 8, scroll, COLOR_YELLOW)
		render.EndBeam()

		if fCurTime >= self.NextEmit then
			self.NextEmit = fCurTime + 0.02

			local emitter = self.Emitter
			local particle = emitter:Add("sprites/glow04_noz", targetpos)
			particle:SetVelocity(Vector(0,0,0))
			particle:SetDieTime(0.22)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(127.5)
			particle:SetStartSize(math.Rand(28, 32))
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 359))
			particle:SetRollDelta(math.Rand(-16, 16))

			for i=1, math.random(2, 4) do
				local particle = emitter:Add("effects/spark", targetpos)
				particle:SetVelocity(VectorRand():GetNormal() * math.Rand(64, 128))
				particle:SetDieTime(0.8)
				particle:SetStartAlpha(255)
				particle:SetEndAlpha(0)
				particle:SetStartSize(math.Rand(6, 8))
				particle:SetEndSize(0)
				particle:SetRoll(math.Rand(0, 359))
				particle:SetRollDelta(math.Rand(-75, 75))
				particle:SetAirResistance(50)
			end
		end
	elseif fCurTime < self:GetStartTime() and fCurTime >= self.NextEmit then
		self.NextEmit = fCurTime + 0.02

		local delta = 1 - math.Clamp((self:GetStartTime() - fCurTime) / self.StartTime, 0, 1) ^ 2
		local up = owner:GetUp()
		local basepos = owner:GetPos() + (owner:OBBMaxs().z + 8) * delta * up
		local ang = owner:GetAngles()
		ang:RotateAroundAxis(up, math.Rand(0, 360))
		local dist = (1.1 - math.abs(delta - 0.5) * 2) * 100

		for i=0, 360, 5 do
			ang:RotateAroundAxis(up, 5)
			local fwd = ang:Forward()

			local particle = self.Emitter:Add("sprites/light_glow02_add", basepos + fwd * dist)
			particle:SetVelocity(delta * 150 * up)
			particle:SetDieTime(math.Rand(0.25, 0.5))
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(200)
			particle:SetStartSize(math.Rand(5, 7))
			particle:SetEndSize(0)
			particle:SetRoll(math.Rand(0, 360))
			particle:SetRollDelta(math.Rand(-10, 10))
			particle:SetColor(255, 255, 20)
			particle:SetAirResistance(100)
		end
	end
end
