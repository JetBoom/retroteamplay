include("shared.lua")

function ENT:DrawTranslucent()
	local scale = math.max(0.05, self.DeathTime - CurTime())
	local icea
	if scale > 0.75 then
		local midscale = (1 - scale) * 1.6
		self:SetModelScale(midscale * (1 - scale) * 2, 0)
		icea = 1 - scale
	else
		self:SetModelScale(scale * 1.6, 0)
		icea = scale
	end
	render.SetBlend(icea)
	self:DrawModel()
	render.SetBlend(1)
end

function ENT:Initialize()
	self:DrawShadow(false)
	self.DeathTime = CurTime() + 1
	self:SetColor(Color(30, 150, 255, 255))
	self:SetMaterial("models/shadertest/shader2")
	ExplosiveEffect(self:GetPos(), 48, 30, DMGTYPE_ICE)

	self:EmitSound("physics/glass/glass_largesheet_break"..math.random(1, 3)..".wav", 80, math.random(160, 180))
end

function ENT:Think()
	self:SetAngles(Angle(0, RealTime() * 50, 0))
end

function ENT:OnRemove()
end
