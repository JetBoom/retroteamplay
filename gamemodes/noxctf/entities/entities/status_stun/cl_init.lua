include("shared.lua")

function ENT:StatusInitialize()
	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(28, 32)

	self.Rotation = math.Rand(0, 180)
end

function ENT:StatusOnRemove(owner)
	owner:SetPoseParameter("head_roll", 0)
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

local matGlow = Material("sprites/glow04_noz")
function ENT:DrawTranslucent()
	local ent = self:GetOwner()
	if not ent:IsValid() then return end

	ent:SetPoseParameter("head_roll", math.sin(CurTime()*5) * 10)

	if ent:IsInvisible() then return end

	local pos

	if ent == MySelf then
		pos = ent:GetPos() + Vector(0,0,72)
	else
		local attach = ent:GetAttachment(ent:LookupAttachment("eyes"))
		if not attach then return end
		pos = attach.Pos + Vector(0,0,16)
	end

	local rot = self.Rotation
	local emitter = self.Emitter
	for i=rot, 359 + rot, 75 do
		local ang = Angle(0, 0, 0)
		ang:RotateAroundAxis(Vector(0, 0, 1), i)
		local pos2 = pos + ang:Forward() * 8
		render.SetMaterial(matGlow)
		render.DrawSprite(pos2, 3.5, 3.5, COLOR_YELLOW)
		local particle = emitter:Add("sprites/glow04_noz", pos2)
		particle:SetVelocity(Vector(0,0,0))
		particle:SetDieTime(0.2)
		particle:SetStartAlpha(254)
		particle:SetEndAlpha(50)
		particle:SetStartSize(4)
		particle:SetEndSize(1)
		particle:SetRoll(math.Rand(0, 360))
		particle:SetColor(255, 255, 0)
		particle:SetAirResistance(50)
	end

	local rot = self.Rotation
	self.Rotation = rot + FrameTime() * 120
	if 360 < self.Rotation then self.Rotation = self.Rotation - 360 end
end
