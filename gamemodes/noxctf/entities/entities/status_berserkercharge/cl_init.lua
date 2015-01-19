include("shared.lua")

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT

ENT.RenderBoundsMin = Vector(-128, -128, -128)
ENT.RenderBoundsMax = Vector(128, 128, 128)

function ENT:StatusInitialize()
	self:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self:SetMaterial("models/shiny")
	self:SetModelScaleVector(4)

	self.Emitter = ParticleEmitter(self:GetPos())
	self.Emitter:SetNearClip(24, 32)

	self.Created = CurTime()
	self.EndTime = CurTime() + 2
end

function ENT:StatusThink(owner)
	self.Emitter:SetPos(self:GetPos())
end

function ENT:StatusOnRemove(owner)
	if owner:IsValid() then
		local particle = self.Emitter:Add("effects/select_ring", owner:LocalToWorld(owner:OBBCenter()) + owner:GetForward() * 16)
		particle:SetDieTime(0.5)
		particle:SetStartAlpha(255)
		particle:SetEndAlpha(0)
		particle:SetStartSize(4)
		particle:SetEndSize(200)
		particle:SetAngles(owner:GetAngles())
		particle:SetColor(self.TeamCol)
	end

	--self.Emitter:Finish()
end

ENT.NextEmit = 0
function ENT:DrawTranslucent()
	local owner = self:GetOwner()
	if not owner:IsValid() then return end

	local r, g, b, a = self.TeamCol.r, self.TeamCol.g, self.TeamCol.b, self.TeamCol.a
	local ct = CurTime()

	self:SetAngles(Angle(ct * 360, 0, 0))

	render.SetColorModulation(r / 255, g / 255, b / 255)
	render.SetBlend(math.min(ct - self.Created, self.EndTime - ct, 0.5))

	self:DrawModel()

	render.SetBlend(1)
	render.SetColorModulation(1, 1, 1)
end
