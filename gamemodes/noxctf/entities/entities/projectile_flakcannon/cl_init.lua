include("shared.lua")

local matBeam = Material("effects/spark")
function ENT:Draw()
	local col = team.GetColor(self:GetTeamID())
	local pos = self:GetPos()

	local emitter = self.Emitter
	for i=1, 3 + EFFECT_QUALITY * 1.5 do
		local particle = emitter:Add("sprites/light_glow02_add", pos + VectorRand():GetNormalized() * math.Rand(2, 4))
		particle:SetDieTime(math.Rand(0.6, 1))
		particle:SetStartAlpha(230)
		particle:SetEndAlpha(50)
		particle:SetStartSize(math.Rand(6, 10))
		particle:SetEndSize(0)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-8, 8))
		particle:SetColor(col.r, col.g, col.b)
		
		particle = emitter:Add("particles/smokey", pos + VectorRand():GetNormalized() * math.Rand(4, 6))
		particle:SetDieTime(math.Rand(1.6, 2))
		particle:SetStartAlpha(60)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(math.Rand(6, 8))
		particle:SetRoll(math.Rand(0, 360))
		particle:SetRollDelta(math.Rand(-2.8, 2.8))
		particle:SetColor(45, 45, 45)
	end
	
	render.SetMaterial(matBeam)
	local pos = self:GetPos()
	local norm = self:GetVelocity():GetNormal()
	render.DrawBeam(pos + norm * 10, pos - norm * 54, 32, 1, 0, col)
end

function ENT:Initialize()
	self:DrawShadow(false)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
	self:EmitSound("weapons/flaregun/fire.wav")
	self:SetRenderBounds(Vector(-36, -36, -36), Vector(36, 36, 36))
end

function ENT:Think()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end
