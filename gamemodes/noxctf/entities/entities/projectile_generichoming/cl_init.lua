include('shared.lua')

function ENT:Initialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)
end

function ENT:Think()
	local vPos = self:GetPos()
	self.Emitter:SetPos(vPos)

	if not self.PlayedSound then
		self:EmitSound("nox/genericprojectile.ogg")
		self.PlayedSound = true
	end
end

function ENT:OnRemove()
	--self.Emitter:Finish()
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:Draw()
	local pos = self:GetPos()
	render.SetMaterial(matGlow)
	render.DrawSprite(pos, math.Rand(32, 48), math.Rand(32, 48), color_white)

	local particle = self.Emitter:Add("sprites/glow04_noz", pos + VectorRand():GetNormal() * math.Rand(8, 12))
	particle:SetDieTime(1.25)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha(0)
	local size = math.Rand(4, 7)
	particle:SetStartSize(size)
	particle:SetEndSize(size)
	particle:SetRoll(math.Rand(0, 360))
	if self:GetSkin() == 1 then
		local ran = math.random(1, 3)
		if ran == 1 then
			particle:SetColor(200, 200, 200)
		elseif ran == 2 then
			particle:SetColor(0, 235, 235)
		else
			particle:SetColor(0, 100, 255)
		end
	else
		local ran = math.random(1, 3)
		if ran == 1 then
			particle:SetColor(200, 200, 200)
		elseif ran == 2 then
			particle:SetColor(235, 225, 0)
		else
			particle:SetColor(255, 150, 100)
		end
	end
end
