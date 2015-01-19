include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(32, 40)

	self.Rotation = 120
	self.NextEmit = 0
end

function ENT:StatusThink()
	self.Emitter:SetPos(self:GetPos())
end

function ENT:EmitParticle(pos, vel, r, g, b, mat)
	local particle = self.Emitter:Add(mat, pos)
	particle:SetVelocity(vel)
	particle:SetDieTime(math.Rand(0.1, 0.25))
	particle:SetStartAlpha(230)
	particle:SetEndAlpha(60)
	particle:SetStartSize(math.Rand(5, 8))
	particle:SetEndSize(0)
	particle:SetRoll(math.Rand(0, 360))
	particle:SetRollDelta(math.Rand(-8, 8))
	particle:SetColor(r, g, b)
	particle:SetAirResistance(10)
end

local matGlow = Material("sprites/light_glow02_add")
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() or not owner:IsVisibleTarget(MySelf) then return end

	local fCurTime = CurTime()
	local plvel = owner:GetVelocity()

	local basepos = owner:GetPos() + owner:OBBMaxs().z * 0.5 * owner:GetUp()
	local ang = Angle(0, 90, 0)
	ang:RotateAroundAxis(ang:Up(), fCurTime * 360)
	ang:RotateAroundAxis(ang:Right(), 45)
	--ang:RotateAroundAxis(ang:Forward(), math.sin(fCurTime * math.pi) * 30)

	local shouldemit = false
	if fCurTime >= self.NextEmit then
		self.NextEmit = fCurTime + 0.025
		shouldemit = true
	end

	render.SetMaterial(matGlow)
	for i=1, 3 do
		ang:RotateAroundAxis(ang:Up(), 120)
		local dir = ang:Forward()
		local baseorbpos = basepos + dir * 32

		local pos1, pos2, pos3 = baseorbpos + ang:Up() * 5, baseorbpos - ang:Up() * 5 + ang:Right() * 5, baseorbpos - ang:Up() * 5 - ang:Right() * 5

		render.DrawSprite(pos1, 16, 16, COLOR_RED)
		render.DrawSprite(pos1, 8, 8, color_white)
		render.DrawSprite(pos2, 16, 16, color_white)
		render.DrawSprite(pos2, 8, 8, color_white)
		render.DrawSprite(pos3, 16, 16, COLOR_CYAN)
		render.DrawSprite(pos3, 8, 8, color_white)

		if shouldemit then
			self:EmitParticle(pos1, plvel, 255, 180, 30, "sprites/light_glow02_add")
			self:EmitParticle(pos2, plvel, 240, 240, 255, "particle/snow")
			self:EmitParticle(pos3, plvel, 50, 100, 255, "sprites/light_glow02_add")
			self:EmitParticle(pos3, plvel, 50, 100, 255, "effects/spark")
		end
	end
end
